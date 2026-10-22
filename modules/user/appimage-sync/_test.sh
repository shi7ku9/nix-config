# Hermetic tests for appimage-sync, run by the `appimage-sync` flake check
# (modules/user/appimage-sync/checks.nix). Can also be run by hand:
#   APPIMAGE_SYNC=/path/to/bin/appimage-sync bash _test.sh
# Needs on PATH: bash, coreutils, findutils, grep, gawk, desktop-file-validate, gio.
#
# Fake AppImages are small bash scripts that emulate the type-2 runtime's
# `--appimage-extract <pattern>`: every path in a payload dir is matched like
# fnmatch(pattern, path, FNM_PATHNAME | FNM_LEADING_DIR) (so `*` does not cross
# `/`, and a directory pattern pulls in its contents) and extracted into
# ./squashfs-root, symlinks as symlinks. That matches what the real runtime did
# for the AppImage in ~/Appimage: `*.desktop` extracted only the top-level
# symlink, not its target under usr/share/applications. Started any other way
# they append "$0" to $LAUNCH_LOG, so the tests can (a) prove the sync never
# launches an app and (b) launch the generated entries through GLib
# (`gio launch`) to check that Exec= really runs the right file.

set -u -o pipefail

SYNC=${APPIMAGE_SYNC:-appimage-sync}
ROOT=$(mktemp -d "${TMPDIR:-/tmp}/appimage-sync-test.XXXXXX")
MARK=X-AppImage-Sync-Source
# Per-call extraction timeout (proposed APPIMAGE_SYNC_TIMEOUT knob, see hang case).
export APPIMAGE_SYNC_TIMEOUT=3
# Keep gio from trying to autolaunch a session bus.
export DBUS_SESSION_BUS_ADDRESS=unix:path=/nonexistent

PNG_B64='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='

passes=0
fails=0
failed=()
current=

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

# Fresh, isolated HOME / XDG_DATA_HOME / APPIMAGE_DIR for one scenario.
new_env() {
    current=$1
    printf '\n== %s\n' "$1"
    W=$ROOT/$1
    mkdir -p "$W"
    export HOME=$W/home
    export XDG_DATA_HOME=$HOME/.local/share
    export APPIMAGE_DIR=$HOME/Appimage
    APPS=$XDG_DATA_HOME/applications
    ICONS=$XDG_DATA_HOME/icons/appimage-sync
    PAYLOADS=$W/payloads
    LAUNCH_LOG=$W/launch.log
    mkdir -p "$APPIMAGE_DIR" "$PAYLOADS"
    : >"$LAUNCH_LOG"
}

# Run the sync with a hard upper bound so a hang fails the test instead of the build.
run_sync() {
    local limit=${1:-120} rc
    timeout -k 5 "$limit" "$SYNC" >"$W/last.out" 2>&1
    rc=$?
    sed 's/^/        | /' "$W/last.out"
    return "$rc"
}

# payload <id>: create (and print) an empty payload dir
payload() {
    mkdir -p "$PAYLOADS/$1"
    printf '%s' "$PAYLOADS/$1"
}
png() { base64 -d <<<"$PNG_B64" >"$1"; }
svg() { printf '<?xml version="1.0"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>\n' >"$1"; }
desktop() { # desktop <file> <Name> [Categories] [StartupWMClass]
    {
        echo "[Desktop Entry]"
        echo "Type=Application"
        echo "Name=$2"
        echo "Exec=AppRun %U"
        [[ -n ${3-} ]] && echo "Categories=$3"
        [[ -n ${4-} ]] && echo "StartupWMClass=$4"
        echo "[Desktop Action new]"
        echo "Name=Not the app name"
    } >"$1"
}

# mkfake <path> <payload-dir or ""> [normal|hang|late <src> <dst>]
#   hang: ignores --appimage-extract, blocks, ignores SIGTERM
#   late: while being extracted, moves <src> to <dst> (a download that
#         completes while the sync is busy)
mkfake() {
    local path=$1 pl=$2 mode=${3:-normal} late_src=${4-} late_dst=${5-}
    mkdir -p "$(dirname "$path")"
    {
        printf '#!%s\n' "$BASH"
        printf 'payload=%q\nmode=%q\nlaunchlog=%q\n' "$pl" "$mode" "$LAUNCH_LOG"
        printf 'late_src=%q\nlate_dst=%q\n' "$late_src" "$late_dst"
        cat <<'EOF'
if [[ ${1-} == --appimage-extract ]]; then
    if [[ $mode == late && -e $late_src ]]; then
        # Let the small source-directory listing finish before the new file
        # arrives, so picking it up requires a fresh scan.
        sleep 0.2
        mv "$late_src" "$late_dst"
    fi
    if [[ $mode == hang ]]; then
        # Behaves like an AppImage that ignores the flag and blocks (e.g. starts
        # its GUI) - and also ignores SIGTERM. Self-limits so it never outlives the test.
        trap '' TERM INT HUP
        for ((i = 0; i < 60; i++)); do sleep 1; done
        exit 0
    fi
    pat=${2-*}
    dest=$PWD/squashfs-root
    # fnmatch(pat, path, FNM_PATHNAME | FNM_LEADING_DIR), component by component
    matches() {
        local -a p s
        local i
        IFS=/ read -ra p <<<"$pat"
        IFS=/ read -ra s <<<"$1"
        ((${#p[@]} > 0 && ${#s[@]} >= ${#p[@]})) || return 1
        for i in "${!p[@]}"; do
            # shellcheck disable=SC2053
            [[ ${s[i]} == ${p[i]} ]] || return 1
        done
    }
    [[ -n $payload ]] || exit 0
    cd "$payload" || exit 1
    while IFS= read -r -d '' rel; do
        rel=${rel#./}
        matches "$rel" || continue
        mkdir -p "$dest/$(dirname "$rel")"
        if [[ -d $rel && ! -L $rel ]]; then mkdir -p "$dest/$rel"; else cp -P "$rel" "$dest/$rel"; fi
    done < <(find . -mindepth 1 -print0)
    exit 0
fi
printf '%s\n' "$0" >>"$launchlog"
EOF
    } >"$path"
    chmod 644 "$path"
}

# entries_for <appimage>: managed entries whose source marker is this AppImage
entries_for() {
    local p
    p=$(readlink -f -- "$1")
    grep -lFx -- "$MARK=$p" "$APPS"/appimage-sync-*.desktop 2>/dev/null
}
# entry_for <appimage>: the single managed entry for it (fails if 0 or >1)
entry_for() {
    local e
    e=$(entries_for "$1") || return 1
    [[ $(wc -l <<<"$e") -eq 1 ]] || return 1
    printf '%s' "$e"
}
has_entry() { entry_for "$1" >/dev/null; }
no_entry() { [[ -z $(entries_for "$1") ]]; }
managed_count() {
    local n=0 f
    for f in "$APPS"/appimage-sync-*.desktop; do [[ -e $f ]] && n=$((n + 1)); done
    printf '%s' "$n"
}
count_is() { [[ $(managed_count) -eq $1 ]]; }
icon_files_count() { find "$ICONS" -mindepth 1 2>/dev/null | wc -l; }

# dget <desktop file> <key>: value from the [Desktop Entry] group
dget() {
    awk -F= -v k="$2" '
        /^\[/ { in_de = ($0 == "[Desktop Entry]"); next }
        in_de && $1 == k { sub(/^[^=]*=/, ""); print; exit }
    ' "$1"
}
key_is() { # key_is <appimage> <key> <expected>
    local e
    e=$(entry_for "$1") || return 1
    [[ $(dget "$e" "$2") == "$3" ]]
}
icon_of() {
    local e
    e=$(entry_for "$1") || return 1
    dget "$e" Icon
}
icon_matches() { # icon_matches <appimage> <expected icon content file> <ext>
    local i
    i=$(icon_of "$1") || return 1
    [[ $i == "$ICONS"/*."$3" && -f $i ]] && cmp -s "$i" "$2"
}
icon_file_exists() {
    local i
    i=$(icon_of "$1") || return 1
    [[ $i == /* && -f $i ]]
}
is_exec() { [[ -x $1 ]]; }
not_exec() { [[ ! -x $1 ]]; }

valid() { # desktop-file-validate must report no errors
    local out
    out=$(desktop-file-validate "$1" 2>&1)
    [[ -n $out ]] && printf '%s\n' "$out" | sed 's/^/        > /'
    ! grep -q 'error' <<<"$out"
}
entry_valid() {
    local e
    e=$(entry_for "$1") || return 1
    valid "$e"
}
all_valid() {
    local f ok=0
    for f in "$APPS"/appimage-sync-*.desktop; do
        [[ -e $f ]] || continue
        valid "$f" || ok=1
    done
    return "$ok"
}

# launches <appimage>: `gio launch` the generated entry; the fake must log exactly its own path
launches() {
    local e want got i
    e=$(entry_for "$1") || return 1
    want=$(readlink -f -- "$1")
    : >"$LAUNCH_LOG"
    timeout 10 gio launch "$e" >"$W/gio.out" 2>&1 || {
        sed 's/^/        > /' "$W/gio.out"
        return 1
    }
    for ((i = 0; i < 50; i++)); do
        [[ -s $LAUNCH_LOG ]] && break
        sleep 0.1
    done
    got=$(cat "$LAUNCH_LOG")
    [[ $got == "$want" ]] || {
        printf '        > launched %q, wanted %q\n' "$got" "$want"
        return 1
    }
}
nothing_launched() { [[ ! -s $LAUNCH_LOG ]]; }
output_has() { grep -q -- "$1" "$W/last.out"; }
output_empty() { [[ ! -s $W/last.out ]]; }

snapshot() { # metadata + content of everything under XDG_DATA_HOME
    (
        cd "$XDG_DATA_HOME" || exit 1
        find . -printf '%p %y %s %T@ %m\n' | sort
        find . -type f -exec sha256sum {} + | sort
    )
}

# ---------------------------------------------------------------------------
new_env basic

pl=$(payload foo)
desktop "$pl/foo.desktop" "Foo App" "Graphics;Viewer;" foo-wm
png "$pl/foo.png"
ln -s foo.png "$pl/.DirIcon"
mkfake "$APPIMAGE_DIR/Foo.AppImage" "$pl"

# .DirIcon -> svg symlink -> real file deeper in the tree (two levels)
pl=$(payload svgapp)
desktop "$pl/svgapp.desktop" "Svg App" "Development;"
mkdir -p "$pl/usr/share/icons/hicolor/scalable/apps"
svg "$pl/usr/share/icons/hicolor/scalable/apps/svgapp.svg"
ln -s usr/share/icons/hicolor/scalable/apps/svgapp.svg "$pl/svgapp.svg"
ln -s svgapp.svg "$pl/.DirIcon"
mkfake "$APPIMAGE_DIR/SvgApp.AppImage" "$pl"

# icon but no embedded .desktop
pl=$(payload iconly)
png "$pl/.DirIcon"
mkfake "$APPIMAGE_DIR/IconOnly.AppImage" "$pl"

mkfake "$APPIMAGE_DIR/Bare.AppImage" ""          # no metadata at all
mkfake "$APPIMAGE_DIR/lower.appimage" ""         # case-insensitive extension
mkfake "$APPIMAGE_DIR/sub/Nested.AppImage" ""    # not top level -> ignored
mkfake "$APPIMAGE_DIR/notes.txt" ""              # not an AppImage -> ignored

# Files the user owns that must never be touched
mkdir -p "$APPS/sub" "$XDG_DATA_HOME/icons/hicolor/48x48/apps"
desktop "$APPS/my-own.desktop" "Mine"
desktop "$APPS/appimage-sync.desktop" "Lookalike (no dash)"
desktop "$APPS/sub/appimage-sync-nested.desktop" "Lookalike in subdir"
png "$XDG_DATA_HOME/icons/hicolor/48x48/apps/user.png"
user_files=("$APPS/my-own.desktop" "$APPS/appimage-sync.desktop"
    "$APPS/sub/appimage-sync-nested.desktop" "$XDG_DATA_HOME/icons/hicolor/48x48/apps/user.png")
user_sums=$(sha256sum "${user_files[@]}")
user_untouched() { [[ $(sha256sum "${user_files[@]}" 2>&1) == "$user_sums" ]]; }

check "first run exits 0" run_sync
check "chmod +x applied to top-level AppImages" \
    eval 'is_exec "$APPIMAGE_DIR/Foo.AppImage" && is_exec "$APPIMAGE_DIR/Bare.AppImage" && is_exec "$APPIMAGE_DIR/lower.appimage"'
check "nested AppImage and non-AppImage left alone" \
    eval 'not_exec "$APPIMAGE_DIR/sub/Nested.AppImage" && not_exec "$APPIMAGE_DIR/notes.txt" && no_entry "$APPIMAGE_DIR/sub/Nested.AppImage"'
check "exactly 5 managed entries" count_is 5
check "sync never launched an AppImage" nothing_launched
check "Foo: Name from embedded .desktop" key_is "$APPIMAGE_DIR/Foo.AppImage" Name "Foo App"
check "Foo: Categories from embedded .desktop" key_is "$APPIMAGE_DIR/Foo.AppImage" Categories "Graphics;Viewer;"
check "Foo: StartupWMClass from embedded .desktop" key_is "$APPIMAGE_DIR/Foo.AppImage" StartupWMClass foo-wm
check "Foo: Exec line" key_is "$APPIMAGE_DIR/Foo.AppImage" Exec "\"$APPIMAGE_DIR/Foo.AppImage\" %U"
check "Foo: icon copied (png via .DirIcon symlink)" icon_matches "$APPIMAGE_DIR/Foo.AppImage" "$PAYLOADS/foo/foo.png" png
check "SvgApp: icon copied (svg via 2-level symlink)" \
    icon_matches "$APPIMAGE_DIR/SvgApp.AppImage" "$PAYLOADS/svgapp/usr/share/icons/hicolor/scalable/apps/svgapp.svg" svg
check "IconOnly: fallback Name, real icon" \
    eval 'key_is "$APPIMAGE_DIR/IconOnly.AppImage" Name IconOnly && icon_matches "$APPIMAGE_DIR/IconOnly.AppImage" "$PAYLOADS/iconly/.DirIcon" png'
check "Bare: fallback Name/Icon/Categories" \
    eval 'key_is "$APPIMAGE_DIR/Bare.AppImage" Name Bare && key_is "$APPIMAGE_DIR/Bare.AppImage" Icon application-x-executable && key_is "$APPIMAGE_DIR/Bare.AppImage" Categories "Utility;"'
check "lower.appimage: entry with fallback Name" key_is "$APPIMAGE_DIR/lower.appimage" Name lower
check "all entries pass desktop-file-validate" all_valid
check "Foo entry launches Foo via gio" launches "$APPIMAGE_DIR/Foo.AppImage"
check "user files untouched" user_untouched

before=$(snapshot)
check "second run exits 0" run_sync
check "second run is silent (nothing re-synced)" output_empty
check "second run changed nothing on disk" eval '[[ $(snapshot) == "$before" ]]'

foo_icon=$(icon_of "$APPIMAGE_DIR/Foo.AppImage")
svg_icon=$(icon_of "$APPIMAGE_DIR/SvgApp.AppImage")
rm "$APPIMAGE_DIR/Foo.AppImage"
check "run after deleting Foo exits 0" run_sync
check "Foo entry removed" no_entry "$APPIMAGE_DIR/Foo.AppImage"
check "Foo icon removed" eval '[[ -n $foo_icon && ! -e $foo_icon ]]'
check "other entries kept (4 left)" count_is 4
check "SvgApp entry and icon kept" eval 'has_entry "$APPIMAGE_DIR/SvgApp.AppImage" && [[ -f $svg_icon ]]'
check "user files untouched" user_untouched

rm -rf "$APPIMAGE_DIR"
check "run with ~/Appimage deleted exits 0" run_sync
check "all managed entries removed" count_is 0
check "all managed icons removed" eval '[[ $(icon_files_count) -eq 0 ]]'
check "user files untouched" user_untouched

mkdir -p "$APPIMAGE_DIR"
mkfake "$APPIMAGE_DIR/Bare.AppImage" ""
check "run after recreating ~/Appimage exits 0" run_sync
check "entry re-created" eval 'count_is 1 && has_entry "$APPIMAGE_DIR/Bare.AppImage"'

# ---------------------------------------------------------------------------
new_env exec-quoting
# Exec= must survive the Desktop Entry string-escape rule *and* the quoting
# rule (a literal backslash needs 4 backslashes in the file), and a literal %
# must not be read as a field code. Checked syntactically (desktop-file-validate)
# and semantically (GLib actually launches the right file).
names=(
    'sp ace & (x);semi'
    "single'quote"
    'dollar $HOME'
    'double"quote'
    'back`tick'
    'back\slash'
    'percent %f 100%'
)
for n in "${names[@]}"; do mkfake "$APPIMAGE_DIR/$n.AppImage" ""; done
check "run exits 0" run_sync
for n in "${names[@]}"; do
    a=$APPIMAGE_DIR/$n.AppImage
    check "[$n] entry exists" has_entry "$a"
    check "[$n] entry passes desktop-file-validate" entry_valid "$a"
    check "[$n] gio launch runs exactly this AppImage" launches "$a"
done

# ---------------------------------------------------------------------------
new_env symlinked-embedded-desktop
# Layout produced by linuxdeploy-style builds: the top-level .desktop is a
# symlink into usr/share/applications, .DirIcon -> top-level png.
pl=$(payload osu)
mkdir -p "$pl/usr/share/applications"
desktop "$pl/usr/share/applications/osu!.desktop" "osu!" "Game;" "osu!"
ln -s "usr/share/applications/osu!.desktop" "$pl/osu!.desktop"
png "$pl/osu!.png"
ln -s "osu!.png" "$pl/.DirIcon"
osu=$APPIMAGE_DIR/osu.AppImage
mkfake "$osu" "$pl"
check "run exits 0" run_sync
check "Name from the symlinked .desktop" key_is "$osu" Name "osu!"
check "Categories from the symlinked .desktop" key_is "$osu" Categories "Game;"
check "icon copied" icon_matches "$osu" "$pl/osu!.png" png

# ---------------------------------------------------------------------------
new_env metadata-without-icon
# Embedded .desktop present but no .DirIcon: icon field is empty.
pl=$(payload noicon)
desktop "$pl/noicon.desktop" "Proper Name" "Office;"
mkfake "$APPIMAGE_DIR/NoIcon.AppImage" "$pl"
check "run exits 0" run_sync
check "Name comes from embedded .desktop" key_is "$APPIMAGE_DIR/NoIcon.AppImage" Name "Proper Name"
check "Icon falls back to application-x-executable" key_is "$APPIMAGE_DIR/NoIcon.AppImage" Icon application-x-executable
check "Categories from embedded .desktop" key_is "$APPIMAGE_DIR/NoIcon.AppImage" Categories "Office;"

# ---------------------------------------------------------------------------
new_env absolute-diricon
# .DirIcon is an absolute symlink: absolute inside the image, not on the host.
pl=$(payload abs)
mkdir -p "$pl/usr/share/icons"
png "$pl/usr/share/icons/abs.png"
ln -s /usr/share/icons/abs.png "$pl/.DirIcon"
mkfake "$APPIMAGE_DIR/Abs.AppImage" "$pl"
check "run exits 0" run_sync
check "icon resolved inside the image" icon_matches "$APPIMAGE_DIR/Abs.AppImage" "$pl/usr/share/icons/abs.png" png

# ---------------------------------------------------------------------------
new_env icon-prefix
# Slugs "Tool" and "Tool.beta": removing Tool must not delete Tool.beta's icon.
for n in Tool Tool.beta; do
    pl=$(payload "$n")
    png "$pl/.DirIcon"
    mkfake "$APPIMAGE_DIR/$n.AppImage" "$pl"
done
check "run exits 0" run_sync
check "Tool.beta has an icon" icon_file_exists "$APPIMAGE_DIR/Tool.beta.AppImage"
rm "$APPIMAGE_DIR/Tool.AppImage"
check "run after deleting Tool exits 0" run_sync
check "Tool entry removed" no_entry "$APPIMAGE_DIR/Tool.AppImage"
check "Tool.beta icon still exists" icon_file_exists "$APPIMAGE_DIR/Tool.beta.AppImage"

# ---------------------------------------------------------------------------
new_env slug-collision
# "My App" and "My_App" both slugify to My_App.
for n in "My App:Alpha" "My_App:Beta"; do
    pl=$(payload "${n#*:}")
    desktop "$pl/x.desktop" "${n#*:}"
    png "$pl/.DirIcon"
    mkfake "$APPIMAGE_DIR/${n%%:*}.AppImage" "$pl"
done
check "run exits 0" run_sync
check "'My App' has its own entry" key_is "$APPIMAGE_DIR/My App.AppImage" Name Alpha
check "'My_App' has its own entry" key_is "$APPIMAGE_DIR/My_App.AppImage" Name Beta
check "second run exits 0" run_sync
check "second run is silent (no flip-flopping)" output_empty

# ---------------------------------------------------------------------------
new_env long-file-names
# Both source names occupy NAME_MAX (255 bytes) and share the readable prefix
# that has to be truncated to leave room for the managed prefix/hash/suffix.
printf -v long_prefix '%*s' 245 ''
long_prefix=${long_prefix// /L}
long_a=$APPIMAGE_DIR/${long_prefix}A.AppImage
long_b=$APPIMAGE_DIR/${long_prefix}B.AppImage
pl=$(payload long-a)
desktop "$pl/x.desktop" "Long A"
png "$pl/.DirIcon"
mkfake "$long_a" "$pl"
pl=$(payload long-b)
desktop "$pl/x.desktop" "Long B"
svg "$pl/.DirIcon"
mkfake "$long_b" "$pl"
check "run with NAME_MAX source names exits 0" run_sync
check "both long-named AppImages get entries" count_is 2
check "truncated names retain distinct entries" \
    eval '[[ -n $(entry_for "$long_a") && -n $(entry_for "$long_b") && $(entry_for "$long_a") != $(entry_for "$long_b") ]]'
check "Long A keeps its metadata" key_is "$long_a" Name "Long A"
check "Long B keeps its metadata" key_is "$long_b" Name "Long B"
check "Long A keeps its PNG icon" icon_matches "$long_a" "$PAYLOADS/long-a/.DirIcon" png
check "Long B keeps its SVG icon" icon_matches "$long_b" "$PAYLOADS/long-b/.DirIcon" svg
check "long-name entries pass desktop-file-validate" all_valid
check "Long A entry launches the right image" launches "$long_a"
check "Long B entry launches the right image" launches "$long_b"
before=$(snapshot)
check "second run exits 0" run_sync
check "second run is silent" output_empty
check "second run changed nothing on disk" eval '[[ $(snapshot) == "$before" ]]'
rm "$long_a"
check "run after deleting Long A exits 0" run_sync
check "Long A entry removed" no_entry "$long_a"
check "Long B entry survives shared-prefix cleanup" \
    eval 'count_is 1 && has_entry "$long_b" && icon_matches "$long_b" "$PAYLOADS/long-b/.DirIcon" svg'

# ---------------------------------------------------------------------------
new_env symlinked-dir
# ~/Appimage is a symlink to a directory elsewhere (e.g. a data disk).
real=$W/data/Appimage
mkdir -p "$real"
rmdir "$APPIMAGE_DIR"
ln -s "$real" "$APPIMAGE_DIR"
mkfake "$real/Linked.AppImage" ""
check "run exits 0" run_sync
check "AppImage in symlinked dir gets an entry" has_entry "$real/Linked.AppImage"
check "and is chmod +x" is_exec "$real/Linked.AppImage"

# ---------------------------------------------------------------------------
new_env symlinked-appimage
pl=$(payload linked-v1)
desktop "$pl/x.desktop" "Linked v1"
png "$pl/.DirIcon"
mkfake "$W/store/real-1.0.AppImage" "$pl"
ln -s "$W/store/real-1.0.AppImage" "$APPIMAGE_DIR/Real.AppImage"
check "run exits 0" run_sync
check "symlinked AppImage gets an entry" has_entry "$APPIMAGE_DIR/Real.AppImage"
check "entry launches the target" launches "$APPIMAGE_DIR/Real.AppImage"
check "initial target metadata is read" key_is "$APPIMAGE_DIR/Real.AppImage" Name "Linked v1"
pl=$(payload linked-v2)
desktop "$pl/x.desktop" "Linked v2"
svg "$pl/.DirIcon"
mkfake "$W/store/real-1.0.AppImage" "$pl"
check "run after changing the external target exits 0" run_sync
check "external target metadata is refreshed" key_is "$APPIMAGE_DIR/Real.AppImage" Name "Linked v2"
check "external target icon is refreshed" icon_matches "$APPIMAGE_DIR/Real.AppImage" "$pl/.DirIcon" svg
rm "$W/store/real-1.0.AppImage" # symlink now dangles
check "run with dangling symlink exits 0" run_sync
check "no entry for a dangling symlink" count_is 0
check "no icons for a dangling symlink" eval '[[ $(icon_files_count) -eq 0 ]]'

# ---------------------------------------------------------------------------
new_env replaced-with-older-mtime
# An AppImage replaced by a file with an older mtime (mv of an old download,
# cp -p, unpacked from an archive) must still refresh the entry.
pl=$(payload v1)
desktop "$pl/x.desktop" "Old Name"
png "$pl/.DirIcon"
mkfake "$APPIMAGE_DIR/App.AppImage" "$pl"
check "run exits 0" run_sync
check "v1 synced" key_is "$APPIMAGE_DIR/App.AppImage" Name "Old Name"
pl=$(payload v2)
desktop "$pl/x.desktop" "New Name"
png "$pl/.DirIcon"
mkfake "$W/Downloads/App.AppImage" "$pl"
touch -d '2001-01-01' "$W/Downloads/App.AppImage"
mv "$W/Downloads/App.AppImage" "$APPIMAGE_DIR/App.AppImage"
check "run after replacement exits 0" run_sync
check "entry refreshed to v2" key_is "$APPIMAGE_DIR/App.AppImage" Name "New Name"

# ---------------------------------------------------------------------------
new_env newline-in-filename
# A newline in the file name must not inject extra keys into the entry.
mkfake "$APPIMAGE_DIR/Evil"$'\n'"Exec=false"$'\n'"X-Y=z.AppImage" ""
mkfake "$APPIMAGE_DIR/Good.AppImage" ""
check "run exits 0" run_sync
check "Good still synced" has_entry "$APPIMAGE_DIR/Good.AppImage"
check "no managed entry has more than one Exec= line" eval '(
    for f in "$APPS"/appimage-sync-*.desktop; do
        [[ $(grep -c "^Exec=" "$f") -le 1 ]] || exit 1
    done
)'
check "all managed entries pass desktop-file-validate" all_valid

# ---------------------------------------------------------------------------
new_env hanging-appimage
# An "AppImage" that ignores --appimage-extract, blocks, and ignores SIGTERM.
# Needs the proposed APPIMAGE_SYNC_TIMEOUT knob + `timeout -k`; the outer
# 25 s limit turns a hang into a test failure.
mkfake "$APPIMAGE_DIR/Hang.AppImage" "" hang
mkfake "$APPIMAGE_DIR/Good.AppImage" ""
start=$SECONDS
check "run finishes (no hang)" run_sync 25
printf '        (took %ss)\n' $((SECONDS - start))
check "Good synced despite the hanging one" has_entry "$APPIMAGE_DIR/Good.AppImage"
check "Hang gets a fallback entry" key_is "$APPIMAGE_DIR/Hang.AppImage" Icon application-x-executable

# ---------------------------------------------------------------------------
new_env change-during-run
# The systemd path watch is inactive while the oneshot runs (verified with a
# transient path unit), so an AppImage that lands after the directory was
# listed must still be picked up by the same run.
mkfake "$W/dl/Late.AppImage" ""
mkfake "$APPIMAGE_DIR/First.AppImage" "" late "$W/dl/Late.AppImage" "$APPIMAGE_DIR/Late.AppImage"
check "run exits 0" run_sync
check "First synced" has_entry "$APPIMAGE_DIR/First.AppImage"
check "Late (arrived mid-run) synced by the same run" has_entry "$APPIMAGE_DIR/Late.AppImage"

# ---------------------------------------------------------------------------
new_env changes-through-five-passes
# Each newly discovered image delivers the next download after enumeration.
# A fixed scan count can strand later arrivals even once the directory settles.
chain=(First Second Third Fourth Fifth)
for ((i = ${#chain[@]} - 1; i >= 0; i--)); do
    n=${chain[i]}
    pl=$(payload "$n")
    desktop "$pl/x.desktop" "$n App"
    png "$pl/.DirIcon"
    image=$W/dl/$n.AppImage
    if ((i == ${#chain[@]} - 1)); then
        mkfake "$image" "$pl"
    else
        next=${chain[i + 1]}
        mkfake "$image" "$pl" late "$W/dl/$next.AppImage" "$APPIMAGE_DIR/$next.AppImage"
    fi
done
mv "$W/dl/First.AppImage" "$APPIMAGE_DIR/First.AppImage"
check "run with changes through five passes exits 0" run_sync
check "all five arrivals are synced by the same run" count_is 5
for n in "${chain[@]}"; do
    check "$n metadata is synced" key_is "$APPIMAGE_DIR/$n.AppImage" Name "$n App"
done
check "Fifth icon is extracted" icon_matches "$APPIMAGE_DIR/Fifth.AppImage" "$PAYLOADS/Fifth/.DirIcon" png
check "all five entries pass desktop-file-validate" all_valid
check "Fifth entry launches the right image" launches "$APPIMAGE_DIR/Fifth.AppImage"
check "no pending download was left behind" \
    eval '[[ -z $(find "$W/dl" -maxdepth 1 -type f -print -quit) ]]'
before=$(snapshot)
check "second run exits 0" run_sync
check "second run is silent" output_empty
check "second run changed nothing on disk" eval '[[ $(snapshot) == "$before" ]]'

# ---------------------------------------------------------------------------
printf '\n%d passed, %d failed\n' "$passes" "$fails"
if ((fails)); then
    printf 'Failed:\n'
    printf '  - %s\n' "${failed[@]}"
    exit 1
fi
