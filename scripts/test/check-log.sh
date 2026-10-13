#!/bin/sh
# Fail if a Keycloak log contains theme or template errors.
#
#   docker logs kc 2>&1 | scripts/test/check-log.sh
set -eu

log=$(cat)
pattern='Failed to find .* theme|Not found parent theme|Failed to process template|FreeMarker template error|freemarker\.core\.|Error processing theme|ThemeNotFound'

if printf '%s\n' "$log" | grep -E -i "$pattern"; then
    echo "::error::Keycloak log contains theme errors (see above)"
    exit 1
fi
echo "Keycloak log: no theme errors"
