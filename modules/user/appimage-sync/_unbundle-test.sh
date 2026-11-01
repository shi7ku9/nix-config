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
unset TEST_RUNTIME_FLAG TEST_RUNTIME_MODE TEST_RUNTIME_PIDS
unset APPIMAGE_UNBUNDLE_TIMEOUT

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
    timeout -k 5 "${TEST_LIMIT:-60}" env TMPDIR="$UTMP" "$UNBUNDLE" "$@" >"$W/last.out" 2>&1
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
if [[ ${1-} == "${TEST_RUNTIME_FLAG-}" ]]; then
    # Leave a partial, read-only extraction behind before hanging/failing.
    if [[ $1 == --appimage-extract ]]; then
        mkdir -p squashfs-root/partial
        echo partial >squashfs-root/partial/file
        chmod 555 squashfs-root/partial
    fi
    case ${TEST_RUNTIME_MODE-} in
        fail) exit 42 ;;
        invalid-offset) echo invalid; exit 0 ;;
        hang|ignore-term|orphan)
            [[ $TEST_RUNTIME_MODE != ignore-term ]] || trap '' TERM
            sleep 300 &
            printf '%s\n%s\n' "$BASHPID" "$!" >"$TEST_RUNTIME_PIDS"
            [[ $TEST_RUNTIME_MODE != orphan ]] || exit 42
            wait
            exit 0
            ;;
    esac
fi
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

# Killed descendants may briefly remain as zombies until init reaps them.
# Poll only for a bounded interval; kill leftovers so a regression cannot
# leave a 300-second fixture behind after the test itself finishes.
runtime_stopped() {
    local pid state attempt live
    [[ -s $TEST_RUNTIME_PIDS ]] || return 1
    for ((attempt = 0; attempt < 50; attempt++)); do
        live=0
        while read -r pid; do
            state=$(cat "/proc/$pid/stat" 2>/dev/null) || state=
            state=${state##*) }
            [[ -z $state || $state == Z* ]] || live=1
        done <"$TEST_RUNTIME_PIDS"
        ((live)) || return 0
        sleep 0.1
    done
    while read -r pid; do kill -KILL "$pid" 2>/dev/null || true; done <"$TEST_RUNTIME_PIDS"
    return 1
}

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
# Both calls execute arbitrary runtime code. Assert the tool's own deadline
# fires, rather than accepting a kill by run_unbundle's outer safety net.
for flag in --appimage-offset --appimage-extract; do
    for mode in hang ignore-term fail orphan; do
        new_env "runtime-${flag#--appimage-}-$mode"
        img=$W/App.AppImage
        payload "$W/payload" app
        mkimage "$img" "$W/payload"
        cp "$img" "$W/backup"
        export TEST_RUNTIME_FLAG=$flag TEST_RUNTIME_MODE=$mode TEST_RUNTIME_PIDS=$W/pids
        export APPIMAGE_UNBUNDLE_TIMEOUT=1
        TEST_LIMIT=12 run_unbundle "$img" app
        case $mode in
            hang) check "runtime deadline: exit 124" rc_is 124 ;;
            ignore-term) check "SIGKILL escalation: exit 137" rc_is 137 ;;
            fail|orphan) check "runtime failure status preserved" rc_is 42 ;;
        esac
        check "reports the failed runtime operation" output_has "AppImage runtime $flag"
        check "no success message" eval '! output_has "done:"'
        check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'
        [[ $mode == fail ]] || check "runtime and child stopped" runtime_stopped
        check "partial extraction and temp dir cleaned" tmp_clean
        unset TEST_RUNTIME_FLAG TEST_RUNTIME_MODE TEST_RUNTIME_PIDS APPIMAGE_UNBUNDLE_TIMEOUT
    done
done

# ---------------------------------------------------------------------------
new_env invalid-offset
img=$W/App.AppImage
payload "$W/payload" app
mkimage "$img" "$W/payload"
cp "$img" "$W/backup"
export TEST_RUNTIME_FLAG=--appimage-offset TEST_RUNTIME_MODE=invalid-offset
run_unbundle "$img" app
check "non-numeric offset rejected" rc_is 1
check "offset diagnostic" output_has "invalid AppImage offset"
check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'
check "temp dir cleaned" tmp_clean
unset TEST_RUNTIME_FLAG TEST_RUNTIME_MODE

for value in 0 -1 invalid; do
    APPIMAGE_UNBUNDLE_TIMEOUT=$value run_unbundle "$img" app
    check "invalid timeout $value rejected" rc_is 2
    check "invalid timeout explained" output_has "APPIMAGE_UNBUNDLE_TIMEOUT must be"
    check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'
    check "temp dir cleaned" tmp_clean
done

# ---------------------------------------------------------------------------
# Send each signal to the tool alone, not the runtime's separate process
# group. The outer timeout is only a safety net; preserve-status lets us
# assert the script's signal exit status and cleanup.
for flag in --appimage-offset --appimage-extract; do
    for spec in HUP:129 INT:130 TERM:143; do
        new_env "interrupt-${flag#--appimage-}-${spec%:*}"
        img=$W/App.AppImage
        payload "$W/payload" app
        mkimage "$img" "$W/payload"
        cp "$img" "$W/backup"
        export TEST_RUNTIME_FLAG=$flag TEST_RUNTIME_MODE=ignore-term TEST_RUNTIME_PIDS=$W/pids
        export APPIMAGE_UNBUNDLE_TIMEOUT=30
        timeout -k 2 15 timeout --foreground --preserve-status -s "${spec%:*}" -k 10 1 \
            env TMPDIR="$UTMP" "$UNBUNDLE" "$img" app >"$W/last.out" 2>&1
        RC=$?
        check "signal status preserved" rc_is "${spec#*:}"
        check "runtime and child stopped" runtime_stopped
        check "image untouched, no .orig" eval 'same_file "$img" "$W/backup" && no_orig "$img"'
        check "temp dir cleaned" tmp_clean
        unset TEST_RUNTIME_FLAG TEST_RUNTIME_MODE TEST_RUNTIME_PIDS APPIMAGE_UNBUNDLE_TIMEOUT
    done
done

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
