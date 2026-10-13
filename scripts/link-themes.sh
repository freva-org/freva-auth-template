#!/bin/sh
# Link every theme of this repository into a Keycloak themes directory.
#
#   scripts/link-themes.sh [KEYCLOAK_THEMES_DIR]
#
# KEYCLOAK_THEMES_DIR defaults to the directory that contains this clone,
# which is the case when the clone itself lives inside Keycloak's themes
# directory (e.g. <keycloak>/themes/freva-auth-template).
#
# Links are relative when the clone is inside the themes directory, so they
# also resolve inside containers. Existing links are replaced. If a real
# directory has the same name as a theme, nothing is changed.
set -eu

repo=$(cd "$(dirname "$0")/.." && pwd -P)
target=${1:-$(dirname "$repo")}
target=$(cd "$target" && pwd -P)

if [ ! -d "$repo/themes" ]; then
    echo "error: $repo/themes not found" >&2
    exit 1
fi

case "$repo" in
    "$target"/*) prefix=${repo#"$target"/}/themes ;;   # relative links
    *)           prefix=$repo/themes ;;               # absolute links
esac

# Check all names first, so nothing is half-linked on a conflict
conflict=0
for dir in "$repo"/themes/*/; do
    link="$target/$(basename "$dir")"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
        echo "error: $link exists and is not a link." >&2
        echo "       Rename it (e.g. the clone itself: mv $link $target/freva-auth-template)" >&2
        echo "       and run this script from its new location." >&2
        conflict=1
    fi
done
[ "$conflict" -eq 0 ] || exit 1

for dir in "$repo"/themes/*/; do
    name=$(basename "$dir")
    link="$target/$name"
    [ -L "$link" ] && rm "$link"
    ln -s "$prefix/$name" "$link"
    echo "linked: $link -> $prefix/$name"
done
echo "Done. Restart Keycloak to pick up new themes."
