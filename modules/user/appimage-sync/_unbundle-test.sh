# Hermetic tests for appimage-unbundle, run by the `appimage-unbundle` flake
# check (modules/user/appimage-sync/checks.nix). Can also be run by hand:
#   APPIMAGE_UNBUNDLE=/path/to/bin/appimage-unbundle bash _unbundle-test.sh
# Needs on PATH: bash, coreutils, findutils, diffutils, grep, squashfs-tools.
#
# Fake AppImages are real images: a bash "runtime" padded to exactly
# $RUNTIME_SIZE bytes followed by a squashfs. The runtime emulates the type-2
# runtime's `--appimage-offset` and `--appimage-extract` with `unsquashfs -o`;
# started any other way it extracts itself to a temp dir and runs AppRun, so a
# repacked image can be executed end to end. The payload mimics a
# linuxdeploy/Tauri AppDir: bundled libs + GTK/GIO modules, an AppRun that
# sets LD_LIBRARY_PATH and sources apprun-hooks, and AppRun.wrapped.

set -u -o pipefail

UNBUNDLE=${APPIMAGE_UNBUNDLE:-appimage-unbundle}
ROOT=$(mktemp -d "${TMPDIR:-/tmp}/appimage-unbundle-test.XXXXXX")
RUNTIME_SIZE=4096
unset LD_LIBRARY_PATH GIO_MODULE_DIR APP_EXIT

passes=0
fails=0
failed=()
current=
RC=

pass() {
    passes=$((passes + 1))
    printf '  ok    %s\n' "$1"
}
fail() {
    fails=$((fails + 1))
    failed+=("$current: $1")
    printf '  FAIL  %s\n' "$1"
}
# check <description> <command...>
check() {
    local desc=$1
    shift
    if "$@"; then pass "$desc"; else fail "$desc"; fi
}

# Fresh scenario dir; the script under test gets its own TMPDIR so leftovers
# can be detected.
new_env() {
    current=$1
    printf '\n== %s\n' "$1"
    W=$ROOT/$1
    UTMP=$W/tmp
    RC=unset
    mkdir -p "$W" "$UTMP"
}

# run_unbundle <args...>: run with a hard time limit; output in $W/last.out,
# exit code in $RC
run_unbundle() {
    timeout -k 5 60 env TMPDIR="$UTMP" "$UNBUNDLE" "$@" >"$W/last.out" 2>&1
    RC=$?
    sed 's/^/        | /' "$W/last.out"
}
rc_is() { [[ $RC -eq $1 ]]; }
output_has() { grep -qF -- "$1" "$W/last.out"; }
tmp_clean() { [[ -z $(find "$UTMP" -mindepth 1 -print -quit) ]]; }

# runtime <file>: write the fake runtime, padded to exactly $RUNTIME_SIZE bytes
runtime() {
    {
        printf '#!%s\n' "$BASH"
        printf 'off=%d\n' "$RUNTIME_SIZE"
        cat <<'EOF'
self=$(readlink -f "$0")
case ${1-} in
--appimage-offset)
    echo "$off"
    exit 0
    ;;
--appimage-extract)
    [[ $# -eq 1 ]] || { echo "fake runtime: patterns unsupported" >&2; exit 1; }
    exec unsquashfs -q -n -no-xattrs -o "$off" -d squashfs-root "$self" >/dev/null
    ;;
esac
tmp=$(mktemp -d)
unsquashfs -q -n -no-xattrs -o "$off" -d "$tmp/r" "$self" >/dev/null || exit 1
"$tmp/r/AppRun" "$@"
rc=$?
chmod -R u+w "$tmp"
rm -rf "$tmp"
exit "$rc"
EOF
    } >"$1"
    local size
    size=$(stat -c %s "$1")
    ((size < RUNTIME_SIZE)) || { echo "fake runtime too large" >&2; exit 1; }
    printf '%*s\n' $((RUNTIME_SIZE - size - 1)) '' | tr ' ' '#' >>"$1"
}

# mkimage <out> <payload dir>
mkimage() {
    mkdir -p "$(dirname "$1")"
    runtime "$W/runtime"
    mksquashfs "$2" "$W/fs" -root-owned -noappend -comp gzip -quiet -no-progress >/dev/null || exit 1
    cat "$W/runtime" "$W/fs" >"$1"
    chmod 755 "$1"
    rm "$W/fs"
}

# payload <dir> <binary name>: linuxdeploy-style AppDir. Bundled libs set
# APP_LIB=bundled when "loaded" (the hook is the stand-in for that).
payload() {
    local d=$1 bin=$2
    mkdir -p "$d/usr/bin" "$d/usr/share/icons/hicolor/32x32/apps" "$d/apprun-hooks" \
        "$d/usr/lib/gtk-3.0/3.0.0/immodules" "$d/usr/lib/gio/modules" \
        "$d/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders" "$d/usr/lib/girepository-1.0" \
        "$d/usr/lib/x86_64-linux-gnu" "$d/usr/lib/$bin-res/plugins"
    cat >"$d/usr/bin/$bin" <<'EOF'
#!/bin/sh
printf 'argc=%s\n' "$#"
for a; do printf 'arg=[%s]\n' "$a"; done
printf 'ld=[%s]\n' "${LD_LIBRARY_PATH-unset}"
printf 'gio=[%s]\n' "${GIO_MODULE_DIR-unset}"
exit "${APP_EXIT:-0}"
EOF
    printf '#!/bin/sh\necho helper\n' >"$d/usr/bin/helper"
    chmod 755 "$d/usr/bin/$bin" "$d/usr/bin/helper"
    cat >"$d/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib"
for h in "$HERE"/apprun-hooks/*; do . "$h"; done
exec "$HERE/AppRun.wrapped" "$@"
EOF
    printf '#!/bin/sh\nHERE="$(dirname "$(readlink -f "$0")")"\nexec "$HERE/usr/bin/%s" "$@"\n' "$bin" >"$d/AppRun.wrapped"
    printf 'export GIO_MODULE_DIR="$APPDIR/usr/lib/gio/modules"\n' >"$d/apprun-hooks/linuxdeploy-plugin-gtk.sh"
    chmod 755 "$d/AppRun" "$d/AppRun.wrapped"
    for f in libfoo.so.1.2.3 libgstreamer-1.0.so.0 libwebkit2gtk-4.1.so.0 libssl.so; do
        echo "lib $f" >"$d/usr/lib/$f"
    done
    ln -s libfoo.so.1.2.3 "$d/usr/lib/libfoo.so.1"
    ln -s libfoo.so.1 "$d/usr/lib/libfoo.so"
    echo im >"$d/usr/lib/gtk-3.0/3.0.0/immodules/im-ibus.so"
    echo gio >"$d/usr/lib/gio/modules/libgiognutls.so"
    echo loader >"$d/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-png.so"
    echo cache >"$d/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    echo typelib >"$d/usr/lib/girepository-1.0/Gtk-3.0.typelib"
    echo z >"$d/usr/lib/x86_64-linux-gnu/libz.so.1"
    # Must survive: app resources (incl. a .so one level down) and non-.so files.
    echo '{"res":1}' >"$d/usr/lib/$bin-res/resources.json"
    echo plugin >"$d/usr/lib/$bin-res/plugins/libplugin.so"
    echo notes >"$d/usr/lib/README"
    echo png >"$d/usr/share/icons/hicolor/32x32/apps/app.png"
    printf '[Desktop Entry]\nType=Application\nName=App\nExec=%s\nIcon=app\n' "$bin" >"$d/app.desktop"
    ln -s usr/share/icons/hicolor/32x32/apps/app.png "$d/app.png"
    ln -s app.png "$d/.DirIcon"
}

REMOVED=(
    AppRun.wrapped apprun-hooks
    usr/lib/libfoo.so usr/lib/libfoo.so.1 usr/lib/libfoo.so.1.2.3
    usr/lib/libgstreamer-1.0.so.0 usr/lib/libwebkit2gtk-4.1.so.0 usr/lib/libssl.so
    usr/lib/gtk-3.0 usr/lib/gio usr/lib/gdk-pixbuf-2.0 usr/lib/girepository-1.0
    usr/lib/x86_64-linux-gnu
)

# extract <image> <dir>
extract() { unsquashfs -q -n -no-xattrs -o "$RUNTIME_SIZE" -d "$2" "$1" >/dev/null; }
# tree_listing <dir>: everything except AppRun, with type, mode, symlink target
tree_listing() {
    (cd "$1" && find . -mindepth 1 ! -path ./AppRun -printf '%P %y %m %l\n' | sort)
}
# expected <payload> <dir>: what the repacked tree must look like (minus AppRun)
expected() {
    cp -a "$1" "$2"
    local p
    for p in "${REMOVED[@]}"; do rm -rf "${2:?}/$p"; done
    rm -f "$2/AppRun"
}
same_tree() { # same_tree <expected> <actual>
    [[ $(tree_listing "$1") == "$(tree_listing "$2")" ]] &&
        diff -r --no-dereference -x AppRun "$1" "$2" >/dev/null
}
removed_gone() {
    local p
    for p in "${REMOVED[@]}"; do [[ ! -e $1/$p && ! -L $1/$p ]] || return 1; done
}
root_owned() { # every entry in the image is 0/0
    unsquashfs -lln -o "$RUNTIME_SIZE" "$1" | awk 'NR > 3 && $2 != "0/0" { bad = 1 } END { exit bad }'
}
same_file() { cmp -s "$1" "$2"; }
no_orig() { [[ ! -e $1.orig && ! -L $1.orig ]]; }

# runs_unbundled <image> <expected argv...>: running the image passes the
# arguments through untouched and no bundled-lib environment is set up
runs_unbundled() {
    local img=$1 out want a
    shift
    out=$(timeout 30 "$img" "$@" 2>&1) || { printf '        > %s\n' "$out"; return 1; }
    want="argc=$#"
    for a; do want+=$'\n'"arg=[$a]"; done
    want+=$'\n'"ld=[unset]"$'\n'"gio=[unset]"
    [[ $out == "$want" ]] || {
        printf '        > got:\n%s\n' "$out" | sed 's/^/        > /'
        return 1
    }
}

# ---------------------------------------------------------------------------
new_env usage
img=$W/App.AppImage
payload "$W/payload" app
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
run_unbundle
check "no arguments: exit 2" rc_is 2
check "no arguments: prints usage" output_has "usage: appimage-unbundle"
run_unbundle "$img"
check "one argument: exit 2" rc_is 2
run_unbundle "$img" app extra
check "three arguments: exit 2" rc_is 2
check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'

# ---------------------------------------------------------------------------
new_env basic
img=$W/Apps/App.AppImage
payload "$W/payload" app
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
check "fixture: original runs with bundled-lib environment" \
    eval '"$img" | grep -qx "ld=\[.*/usr/lib\]"'
run_unbundle "$img" app
check "exit 0" rc_is 0
check "reports done" output_has "done: $img (original: $img.orig)"
check ".orig is the byte-identical original" same_file "$img.orig" "$W/backup"
check "repacked image is executable" eval '[[ -x $img && -x $img.orig ]]'
check "runtime header kept byte for byte" cmp -s -n "$RUNTIME_SIZE" "$img" "$W/backup"
extract "$img" "$W/out"
check "bundled libs, GTK/GIO modules, hooks, AppRun.wrapped removed" removed_gone "$W/out"
expected "$W/payload" "$W/expected"
check "everything else kept (content, modes, symlinks)" same_tree "$W/expected" "$W/out"
check "new AppRun is executable" test -x "$W/out/AppRun"
check "image is root-owned" root_owned "$img"
check "runs the binary, args intact, no LD_LIBRARY_PATH" \
    runs_unbundled "$img" a "b c" '$HOME' '' '*' "-x"
check "exit status of the binary propagates" eval 'APP_EXIT=7 "$img" >/dev/null; [[ $? -eq 7 ]]'
check "temp dir cleaned up" tmp_clean

# ---------------------------------------------------------------------------
new_env existing-orig
# Running twice (or over an old backup) must never overwrite the only copy of
# the real original.
img=$W/App.AppImage
payload "$W/payload" app
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
run_unbundle "$img" app
check "first run exits 0" rc_is 0
cp "$img" "$W/unbundled"
run_unbundle "$img" app
check "second run refuses" eval '! rc_is 0'
check "second run says why" output_has "already exists: $img.orig"
check ".orig still the real original" same_file "$img.orig" "$W/backup"
check "image unchanged by second run" same_file "$img" "$W/unbundled"
ln -s /nonexistent "$W/Dangling.AppImage.orig"
mkimage "$W/Dangling.AppImage" "$W/payload"
cp "$W/Dangling.AppImage" "$W/backup2"
run_unbundle "$W/Dangling.AppImage" app
check "dangling .orig symlink also refuses" eval '! rc_is 0'
check "and leaves both alone" \
    eval 'same_file "$W/Dangling.AppImage" "$W/backup2" && [[ -L $W/Dangling.AppImage.orig ]]'
check "temp dir cleaned up" tmp_clean

# ---------------------------------------------------------------------------
new_env odd-paths
# Spaces and shell metacharacters in the directory and file name, relative path.
dir="$W/my dir \$x 'q'"
img="$dir/Odd \"name\" & (1).AppImage"
payload "$W/payload" app
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
cd "$dir" && run_unbundle "./$(basename "$img")" app
cd "$ROOT" || exit 1
check "exit 0" rc_is 0
check ".orig next to it is the original" same_file "$img.orig" "$W/backup"
check "repacked image runs" runs_unbundled "$img" x

# ---------------------------------------------------------------------------
new_env symlinked-image
# The argument is a symlink: the target is replaced, the link keeps working.
real=$W/store/App-1.0.AppImage
payload "$W/payload" app
mkimage "$real" "$W/payload"
cp "$real" "$W/backup"
mkdir -p "$W/Appimage"
ln -s "$real" "$W/Appimage/App.AppImage"
run_unbundle "$W/Appimage/App.AppImage" app
check "exit 0" rc_is 0
check "link is still a link to the same target" eval '[[ $(readlink "$W/Appimage/App.AppImage") == "$real" ]]'
check ".orig sits next to the target" same_file "$real.orig" "$W/backup"
check "no .orig next to the link" no_orig "$W/Appimage/App.AppImage"
check "running through the link uses the repacked image" runs_unbundled "$W/Appimage/App.AppImage" y

# ---------------------------------------------------------------------------
new_env odd-binary-name
# The binary name is written into AppRun: it must be quoted, not interpreted.
bin="my app's \"x\" \$HOME \`id\` \$(touch pwned)!"
img=$W/App.AppImage
payload "$W/payload" "$bin"
mkimage "$img" "$W/payload"
run_unbundle "$img" "$bin"
check "exit 0" rc_is 0
check "repacked image runs that binary" eval '(cd "$W" && runs_unbundled "$img" "a b")'
check "no command substitution happened" eval '[[ ! -e $W/pwned ]]'

# ---------------------------------------------------------------------------
new_env missing-binary
img=$W/App.AppImage
payload "$W/payload" app
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
run_unbundle "$img" nope
check "exit 1" rc_is 1
check "says what is missing" output_has "not found: usr/bin/nope"
check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'
check "temp dir cleaned up" tmp_clean
run_unbundle "$img" ../bin/app
check "binary name with a slash refused" eval '! rc_is 0 && same_file "$img" "$W/backup" && no_orig "$img"'

# ---------------------------------------------------------------------------
new_env non-executable-binary
img=$W/App.AppImage
payload "$W/payload" app
chmod 644 "$W/payload/usr/bin/app"
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
run_unbundle "$img" app
check "exit 1" rc_is 1
check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'

# ---------------------------------------------------------------------------
new_env not-an-appimage
printf '#!/bin/sh\nexit 1\n' >"$W/fail.AppImage"
chmod 755 "$W/fail.AppImage"
echo text >"$W/plain.AppImage"
for f in fail plain; do
    cp "$W/$f.AppImage" "$W/$f.backup"
    run_unbundle "$W/$f.AppImage" app
    check "$f: fails" eval '! rc_is 0'
    check "$f: untouched, no .orig" eval 'same_file "$W/$f.AppImage" "$W/$f.backup" && no_orig "$W/$f.AppImage"'
done
run_unbundle "$W/missing.AppImage" app
check "missing file: fails" eval '! rc_is 0'
check "temp dir cleaned up" tmp_clean

# ---------------------------------------------------------------------------
new_env read-only-dirs
# Directories without the write bit inside the image must neither abort the
# job nor leave the extracted tree behind in TMPDIR.
img=$W/App.AppImage
payload "$W/payload" app
chmod 555 "$W/payload/usr/lib" "$W/payload/usr/lib/gio/modules" "$W/payload/usr/lib/app-res"
mkimage "$img" "$W/payload"
chmod -R u+w "$W/payload"
run_unbundle "$img" app
check "exit 0" rc_is 0
extract "$img" "$W/out"
check "bundled libs removed" removed_gone "$W/out"
check "resources kept" cmp -s "$W/out/usr/lib/app-res/resources.json" "$W/payload/usr/lib/app-res/resources.json"
check "repacked image runs" runs_unbundled "$img" z
check "temp dir cleaned up" tmp_clean
chmod -R u+w "$W/out"

# ---------------------------------------------------------------------------
chmod -R u+w "$ROOT"
printf '\n%d passed, %d failed\n' "$passes" "$fails"
if ((fails)); then
    printf 'Failed:\n'
    printf '  - %s\n' "${failed[@]}"
    exit 1
fi
