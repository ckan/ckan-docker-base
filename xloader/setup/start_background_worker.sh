#!/bin/bash

if [[ $CKAN__PLUGINS == *"xloader"* ]]; then
    # Add ckan.xloader.api_token to the CKAN config file (updated with corrected value later)
    echo "Setting a temporary value for ckan.xloader.api_token"
    ckan config-tool $CKAN_INI ckan.xloader.api_token=xxx
fi

if grep -qE "beaker.session.secret ?= ?$" ckan.ini
then
    echo "Setting beaker.session.secret in ini file"
    ckan config-tool $CKAN_INI "beaker.session.secret=$(python3 -c 'import secrets; print(secrets.token_urlsafe())')"
    ckan config-tool $CKAN_INI "WTF_CSRF_SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe())')"
    JWT_SECRET=$(python3 -c 'import secrets; print("string:" + secrets.token_urlsafe())')
    ckan config-tool $CKAN_INI "api_token.jwt.encode.secret=${JWT_SECRET}"
    ckan config-tool $CKAN_INI "api_token.jwt.decode.secret=${JWT_SECRET}"
fi

echo "Set up ckan.xloader.api_token in the CKAN config file"
   ckan config-tool $CKAN_INI "ckan.xloader.api_token=$(ckan -c $CKAN_INI user token add ckan_admin xloader | tail -n 1 | tr -d '\t')"

# Run any startup scripts provided by images extending this one
if [[ -d "/docker-entrypoint.d" ]]
then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: Running init file $f"; . "$f" ;;
            *.py)     echo "$0: Running init file $f"; python3 "$f"; echo ;;
            *)        echo "$0: Ignoring $f (not an sh or py file)" ;;
        esac
    done
fi

# Run the background worker
ckan -c $CKAN_INI jobs worker