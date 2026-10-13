#!/bin/sh
# Create one test realm per theme in themes/ (realm "test-<theme>") with
# login and account theme set, passkeys enabled and a user test/test.
#
#   KCADM="docker exec kc /opt/keycloak/bin/kcadm.sh" scripts/test/setup-realms.sh
#
# Environment:
#   KCADM        command that runs kcadm.sh (default: the container above)
#   KC_SERVER    Keycloak URL as seen by kcadm (default http://localhost:8080)
#   KC_ADMIN     admin user and password (default admin/admin)
set -eu
cd "$(dirname "$0")/../.."

KCADM=${KCADM:-docker exec kc /opt/keycloak/bin/kcadm.sh}
KC_SERVER=${KC_SERVER:-http://localhost:8080}
KC_ADMIN=${KC_ADMIN:-admin}

# kcadm keeps its login in ~/.keycloak/kcadm.config of whoever runs it
$KCADM config credentials --server "$KC_SERVER" --realm master \
    --user "$KC_ADMIN" --password "${KC_ADMIN_PASSWORD:-admin}"

for dir in themes/*/; do
    theme=$(basename "$dir")
    realm="test-$theme"
    login=$theme; account=$theme
    [ -f "$dir/login/theme.properties" ] || login=keycloak.v2
    [ -f "$dir/account/theme.properties" ] || account=keycloak.v3

    $KCADM delete "realms/$realm" >/dev/null 2>&1 || true
    $KCADM create realms -s realm="$realm" -s enabled=true \
        -s loginTheme="$login" -s accountTheme="$account" \
        -s webAuthnPolicyPasswordlessPasskeysEnabled=true \
        -s webAuthnPolicyPasswordlessRpEntityName="$theme"
    $KCADM create users -r "$realm" -s username=test -s enabled=true \
        -s firstName=Test -s lastName=User -s email=test@example.org \
        -s emailVerified=true
    $KCADM set-password -r "$realm" --username test --new-password test
    echo "realm $realm: login=$login account=$account"
done
