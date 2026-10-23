# Manually sync AppImages in ~/Appimage to desktop entries for app launchers.
#  - chmod +x every AppImage
#  - create/update ~/.local/share/applications/appimage-sync-<name>.desktop
#  - extract the embedded icon (and Name/Categories) when possible
#  - remove desktop entries / icons whose AppImage no longer exists
#    (also when ~/Appimage itself is gone)

SRC_DIR="${APPIMAGE_DIR:-$HOME/Appimage}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/appimage-sync"
PREFIX="appimage-sync-"
MARK="X-AppImage-Sync-Source"
STAMP="X-AppImage-Sync-Stamp"
# Per-call limit for `<appimage> --appimage-extract ...`; an AppImage that
# ignores the flag would otherwise start its GUI or block the sync forever.
EXTRACT_TIMEOUT="${APPIMAGE_SYNC_TIMEOUT:-30}"

mkdir -p "$APP_DIR" "$ICON_DIR"

log() { printf '%s\n' "$*"; }

# Desktop Entry `string` value. Newlines never get here (skipped below), so
# only the backslash needs escaping.
desktop_string() { printf '%s' "${1//\\/\\\\}"; }

# Exec= argument per the Desktop Entry spec: inside "..." escape \ " ` $,
# write a literal % as %%, then apply the general string escape (\ -> \\) on
# top, so e.g. a literal backslash ends up as four.
exec_quote() {
    local s=$1
    s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//\`/\\\`}; s=${s//\$/\\\$}
    s=${s//\%/%%}
    s=${s//\\/\\\\}
    printf '"%s"' "$s"
}

# Readable name + hash of the full path: "My App" / "My_App" and
# "Foo.AppImage" / "Foo.appimage" must not share one entry.
slugify() {
    local s=${1%.*} h max
    s=$(printf '%s' "$s" | tr -c 'A-Za-z0-9._-' '_')
    # Reserve bytes for PREFIX, the hash suffix (-12345678), and .desktop.
    # The readable portion is ASCII, so truncating characters also bounds bytes.
    max=$((255 - ${#PREFIX} - 9 - 8))
    s=${s:0:max}
    h=$(printf '%s' "$2" | sha256sum | cut -c1-8)
    printf '%s-%s' "$s" "$h"
}

# Read Key= from the [Desktop Entry] group of a .desktop file
desktop_get() {
    awk -F= -v k="$2" '
        /^\[/ { in_de = ($0 == "[Desktop Entry]") ; next }
        in_de && $1 == k { sub(/^[^=]*=/, ""); print; exit }
    ' "$1"
}

# `$app --appimage-extract <pattern>` inside $tmp, bounded in time
# (-k: also SIGKILL whatever ignores SIGTERM).
extract() {
    (cd "$tmp" && timeout -k 5 "$EXTRACT_TIMEOUT" "$app" --appimage-extract "$1") \
        </dev/null >/dev/null 2>&1
}

# Extract <path> and follow symlinks *inside* the image (absolute targets are
# relative to the image root, never the host). Prints the final path relative
# to squashfs-root if it is a regular file.
extract_resolved() {
    local rel=$1 t i
    extract "$rel"
    for ((i = 0; i < 8; i++)); do
        [[ -L $tmp/squashfs-root/$rel ]] || break
        t=$(readlink "$tmp/squashfs-root/$rel")
        [[ $t == /* ]] || t="$(dirname "$rel")/$t"
        # normalise ./ and .. lexically; clamps at the image root
        rel=$(realpath -m -s --relative-to=/ "/$t")
        extract "$rel"
    done
    [[ -f $tmp/squashfs-root/$rel && ! -L $tmp/squashfs-root/$rel ]] || return 1
    printf '%s' "$rel"
}

# Sets meta_icon / meta_name / meta_cats / meta_wmclass for $app.
extract_meta() {
    local slug=$1 tmp f rel ext
    meta_icon="" meta_name="" meta_cats="" meta_wmclass=""
    tmp=$(mktemp -d) || return

    # The top-level .desktop is often a symlink into usr/share/applications.
    extract '*.desktop'
    f=$(find "$tmp/squashfs-root" -maxdepth 1 -name '*.desktop' 2>/dev/null | head -n1)
    if [[ -n $f ]] && rel=$(extract_resolved "${f##*/}"); then
        f="$tmp/squashfs-root/$rel"
        meta_name=$(desktop_get "$f" Name)
        meta_cats=$(desktop_get "$f" Categories)
        meta_wmclass=$(desktop_get "$f" StartupWMClass)
    fi

    if rel=$(extract_resolved .DirIcon); then
        f="$tmp/squashfs-root/$rel"
        case "$(file -b --mime-type "$f" 2>/dev/null)" in
            image/svg*) ext=svg ;;
            *) ext=png ;;
        esac
        rm -f "$ICON_DIR/$slug.png" "$ICON_DIR/$slug.svg"
        cp -f "$f" "$ICON_DIR/$slug.$ext" && meta_icon="$ICON_DIR/$slug.$ext"
    fi
    rm -rf "$tmp"
}

declare -A keep=()
changed=0

# AppImages as (name, inode, size, mtime), to notice changes made while we run.
dir_sig() {
    find -H "$SRC_DIR" -maxdepth 1 \( -type f -o -type l \) -iname '*.appimage' \
        -printf '%f\t%i\t%s\t%T@\n' 2>/dev/null | sort
}
start_sig=$(dir_sig)

# ---- add / update ----
if [[ -d $SRC_DIR ]]; then
    # -H: also descend when ~/Appimage itself is a symlink to a directory
    while IFS= read -r -d '' app; do
        app=$(readlink -f "$app")
        # dangling symlink, symlink to a directory, ...: no entry (old one is removed below)
        [[ -f $app ]] || continue
        if [[ $app == *[$'\n\r']* ]]; then
            log "skip    newline in file name: ${app@Q}"
            continue
        fi
        base=$(basename "$app")
        slug=$(slugify "$base" "$app")
        desktop="$APP_DIR/$PREFIX$slug.desktop"
        keep["$desktop"]=1

        [[ -x $app ]] || { chmod +x "$app" && log "chmod +x $base"; }

        # Skip if the entry was generated from this very file (inode, size,
        # mtime - an older mtime after `mv` still counts as a change) and its
        # icon is still there.
        stamp=$(stat -c '%d:%i:%s:%.9Y' "$app")
        if [[ -f $desktop && "$(desktop_get "$desktop" "$MARK")" == "$app" &&
            "$(desktop_get "$desktop" "$STAMP")" == "$stamp" ]]; then
            icon=$(desktop_get "$desktop" Icon)
            [[ $icon != /* || -f $icon ]] && continue
        fi

        extract_meta "$slug"
        name=${meta_name:-$(desktop_string "${base%.*}")}
        icon=${meta_icon:-application-x-executable}
        cats=${meta_cats:-Utility;}
        exec_line="$(exec_quote "$app") %U"
        # GLib checks that the Exec= program exists *before* turning %% into %,
        # so a path containing % has to be an argument (of env) instead.
        [[ $app == *%* ]] && exec_line="env -- $exec_line"

        {
            echo "[Desktop Entry]"
            echo "Type=Application"
            echo "Name=$name"
            echo "Comment=AppImage: $(desktop_string "$base")"
            echo "Exec=$exec_line"
            echo "TryExec=$(desktop_string "$app")"
            echo "Icon=$icon"
            echo "Categories=$cats"
            [[ -n $meta_wmclass ]] && echo "StartupWMClass=$meta_wmclass"
            echo "Terminal=false"
            echo "$MARK=$app"
            echo "$STAMP=$stamp"
        } > "$desktop"
        changed=1
        log "synced  $base -> $(basename "$desktop")"
    done < <(find -H "$SRC_DIR" -maxdepth 1 \( -type f -o -type l \) -iname '*.appimage' -print0)
else
    log "note: $SRC_DIR does not exist, removing all managed entries"
fi

# ---- remove stale ----
shopt -s nullglob
for desktop in "$APP_DIR/$PREFIX"*.desktop; do
    [[ -n ${keep["$desktop"]+x} ]] && continue
    slug=$(basename "$desktop" .desktop); slug=${slug#"$PREFIX"}
    rm -f "$desktop" "$ICON_DIR/$slug.png" "$ICON_DIR/$slug.svg"
    changed=1
    log "removed $(basename "$desktop")"
done

if (( changed )); then
    command -v update-desktop-database >/dev/null && update-desktop-database -q "$APP_DIR" 2>/dev/null
    command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1
fi

# Include AppImages that arrive during this manual invocation by rescanning
# until the source directory settles.
if [[ $(dir_sig) != "$start_sig" ]]; then
    log "rescan  $SRC_DIR changed during the run"
    exec "$0"
fi
exit 0
