#!/bin/sh
# Package all themes into one Keycloak theme JAR.
#
#   scripts/build-jar.sh [VERSION] [OUTPUT_DIR]
#   THEMES_REPO=/other/checkout scripts/build-jar.sh ...   # themes from elsewhere
#
# Produces OUTPUT_DIR/freva-auth-themes-VERSION.jar (default: dist/,
# version from `git describe`). Deploy by copying the JAR into Keycloak's
# providers/ directory and restarting Keycloak. All themes (dkrz, freva,
# ...) are in the same JAR, so child themes always find their parent.
#
# Layout inside the JAR, as Keycloak expects it:
#   META-INF/keycloak-themes.json        list of themes and their types
#   theme/<name>/<type>/theme.properties
#   theme/<name>/<type>/...
set -eu

# Repository with the themes/ folder; defaults to the one this script is in.
repo=$(cd "${THEMES_REPO:-$(dirname "$0")/..}" && pwd -P)
version=${1:-$(git -C "$repo" describe --tags --always --dirty 2>/dev/null || echo dev)}
version=${version#v}
outdir=${2:-$repo/dist}
mkdir -p "$outdir"
outdir=$(cd "$outdir" && pwd -P)
jar="$outdir/freva-auth-themes-$version.jar"

build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT
mkdir -p "$build/META-INF" "$build/theme"

# Copy themes and collect their names and types for the descriptor.
entries=""
for themedir in "$repo"/themes/*/; do
    name=$(basename "$themedir")
    types=""
    for typedir in "$themedir"*/; do
        [ -f "$typedir/theme.properties" ] || continue
        type=$(basename "$typedir")
        types="$types${types:+, }\"$type\""
    done
    [ -n "$types" ] || continue
    cp -R "$themedir" "$build/theme/$name"
    entries="$entries${entries:+,
}    { \"name\": \"$name\", \"types\": [$types] }"
done

if [ -z "$entries" ]; then
    echo "error: no themes found in $repo/themes" >&2
    exit 1
fi

cat > "$build/META-INF/keycloak-themes.json" <<EOF
{
  "themes": [
$entries
  ]
}
EOF

# Plain zip with stable ordering and timestamps; a JAR is a zip file.
rm -f "$jar"
find "$build" -exec touch -h -d '1980-01-01 00:00:00' {} +
(cd "$build" && find META-INF theme -type f | LC_ALL=C sort | zip -q -X -D "$jar" -@)

echo "built $jar"
cat "$build/META-INF/keycloak-themes.json"
