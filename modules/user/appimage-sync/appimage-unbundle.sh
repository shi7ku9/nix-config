# Repack an AppImage without its bundled shared libraries so it runs on the
# host's (newer) libs. Fixes linuxdeploy/Tauri AppImages built on old Ubuntu,
# e.g. "undefined symbol: g_once_init_leave_pointer" from system GStreamer.
#
# Usage: appimage-unbundle <file.AppImage> <main-binary-name>
# The original is kept next to it as <file.AppImage>.orig (not *.appimage, so
# appimage-sync ignores it). An existing .orig is never overwritten.

if [ $# -ne 2 ]; then
    echo "usage: appimage-unbundle <file.AppImage> <main-binary-name>" >&2
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
# Extracted trees may contain read-only directories.
trap 'chmod -R u+w "$work"; rm -rf "$work"' EXIT

offset=$("$src" --appimage-offset)
head -c "$offset" "$src" > "$work/runtime"

(cd "$work" && "$src" --appimage-extract >/dev/null)
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
