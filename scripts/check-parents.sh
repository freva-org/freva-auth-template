#!/bin/sh
# Fail if a theme in themes/ names a parent theme that is not in themes/.
#
#   scripts/check-parents.sh [REPO_DIR]
#
# Parents that ship with Keycloak itself (base, keycloak, keycloak.v2,
# keycloak.v3) are fine.
set -eu
cd "${1:-$(dirname "$0")/..}"

status=0
for props in themes/*/*/theme.properties; do
    parent=$(sed -n 's/^parent=//p' "$props")
    type=$(basename "$(dirname "$props")")
    case "$parent" in ""|base|keycloak|keycloak.v2|keycloak.v3) continue ;; esac
    if [ -f "themes/$parent/$type/theme.properties" ]; then
        echo "ok:      $props -> $parent"
    else
        echo "::error file=$props::parent theme '$parent' ($type) is missing"
        status=1
    fi
done
exit $status
