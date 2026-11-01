# Repack an AppImage without its bundled shared libraries so it runs on the
# host's (newer) libs. Fixes linuxdeploy/Tauri AppImages built on old Ubuntu,
# e.g. "undefined symbol: g_once_init_leave_pointer" from system GStreamer.
#
# Usage: appimage-unbundle <file.AppImage> <main-binary-name>
# The original is kept next to it as <file.AppImage>.orig (not *.appimage, so
# appimage-sync ignores it). An existing .orig is never overwritten.
# APPIMAGE_UNBUNDLE_TIMEOUT: positive whole seconds per runtime call (default
# 30), followed by a 5-second SIGTERM grace period before SIGKILL.

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "usage: appimage-unbundle <file.AppImage> <main-binary-name>" >&2
    exit 2
fi

runtime_timeout=${APPIMAGE_UNBUNDLE_TIMEOUT:-30}
if [[ ! $runtime_timeout =~ ^[1-9][0-9]*$ ]]; then
    echo "APPIMAGE_UNBUNDLE_TIMEOUT must be a positive whole number of seconds" >&2
    exit 2
fi

src=$(readlink -f "$1")
bin=$2
case $bin in
    */*) echo "binary name must not contain '/': $bin" >&2; exit 1 ;;
esac
# A second run would otherwise replace the only copy of the real original.
if [ -e "$src.orig" ] || [ -L "$src.orig" ]; then
    echo "already exists: $src.orig" >&2
    exit 1
fi

work=$(mktemp -d)
runtime_pid=
cleanup() {
    local status=$?
    trap - EXIT HUP INT TERM
    if [[ -n $runtime_pid ]]; then
        # timeout owns a process group, including runtime children. Stop all
        # writers before removing the tree, even if they ignore SIGTERM.
        kill -KILL -- "-$runtime_pid" 2>/dev/null || true
        kill -KILL "$runtime_pid" 2>/dev/null || true
        wait "$runtime_pid" 2>/dev/null || true
    fi
    # Extracted trees may contain read-only directories.
    chmod -R u+w "$work" || true
    rm -rf "$work"
    exit "$status"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

run_runtime() {
    local status
    # Background + wait lets shell traps run promptly. Keep stdout in a file:
    # command substitution could wait forever on a pipe inherited by a child.
    (cd "$work" && exec timeout -k 5 "$runtime_timeout" "$src" "$1") \
        </dev/null >"$2" &
    runtime_pid=$!
    if wait "$runtime_pid"; then status=0; else status=$?; fi
    # A runtime may leave children behind even after it exits.
    kill -KILL -- "-$runtime_pid" 2>/dev/null || true
    runtime_pid=
    if ((status != 0)); then
        case $status in
            124|137) echo "AppImage runtime $1 timed out or was killed (status $status)" >&2 ;;
            *) echo "AppImage runtime $1 failed (status $status)" >&2 ;;
        esac
        exit "$status"
    fi
}

run_runtime --appimage-offset "$work/offset"
offset=$(cat "$work/offset")
if [[ ! $offset =~ ^[0-9]+$ || ! $offset =~ [1-9] ]]; then
    echo "invalid AppImage offset: $offset" >&2
    exit 1
fi
head -c "$offset" "$src" > "$work/runtime"

run_runtime --appimage-extract /dev/null
root="$work/squashfs-root"
find "$root" -type d ! -perm -u+w -exec chmod u+w {} +
[ -x "$root/usr/bin/$bin" ] || { echo "not found: usr/bin/$bin" >&2; exit 1; }

# Drop bundled libs and the GTK/GIO/pixbuf modules built against them.
find "$root/usr/lib" -maxdepth 1 -name '*.so*' -delete
rm -rf "$root/usr/lib/gtk-3.0" "$root/usr/lib/gio" "$root/usr/lib/gdk-pixbuf-2.0" \
       "$root/usr/lib/girepository-1.0" "$root/usr/lib/x86_64-linux-gnu" \
       "$root/apprun-hooks" "$root/AppRun.wrapped" "$root/AppRun"

# Single-quote the name for sh so nothing in it is expanded.
quoted="'${bin//\'/\'\\\'\'}'"
cat > "$root/AppRun" <<EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\$0")")"
exec "\$HERE/usr/bin/"$quoted "\$@"
EOF
chmod +x "$root/AppRun"

mksquashfs "$root" "$work/fs.squashfs" -root-owned -noappend -comp zstd -b 131072 -quiet

cat "$work/runtime" "$work/fs.squashfs" > "$work/out.AppImage"
chmod +x "$work/out.AppImage"

mv "$src" "$src.orig"
mv "$work/out.AppImage" "$src"
echo "done: $src (original: $src.orig)"
