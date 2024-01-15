#!/bin/bash

NGINX_CONF="crowdsec_nginx.conf"
BOUNCER_PATH="/tmp/crowdsec-bouncer"
NGINX_CONF_DIR="/etc/nginx/conf.d/"

LIB_PATH="/usr/local/lua/crowdsec/"
CONFIG_PATH="/etc/crowdsec/bouncers/"
DATA_PATH="/var/lib/crowdsec/lua/"
LAPI_DEFAULT_PORT="8080"

gen_apikey() {
    
    SUFFIX=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
    API_KEY="cscli bouncers add crowdsec-nginx-bouncer-${SUFFIX} -o raw"
    PORT=$(cscli config show --key "Config.API.Server.ListenURI"|cut -d ":" -f2)
    if [ -n "$PORT" ]; then
        LAPI_DEFAULT_PORT=${PORT}
    fi
    
    CROWDSEC_LAPI_URL="http://127.0.0.1:${LAPI_DEFAULT_PORT}"
    mkdir -p "${CONFIG_PATH}"
    API_KEY=${API_KEY} CROWDSEC_LAPI_URL=${CROWDSEC_LAPI_URL} envsubst < ${BOUNCER_PATH}/lua-mod/config_example.conf | tee -a "${CONFIG_PATH}crowdsec-nginx-bouncer.conf" >/dev/null
}

install() {
    mkdir -p ${LIB_PATH}/plugins/crowdsec/
    mkdir -p ${DATA_PATH}/templates/

    cp ${BOUNCER_PATH}/nginx/${NGINX_CONF} ${NGINX_CONF_DIR}/${NGINX_CONF}
    cp -r ${BOUNCER_PATH}/lua-mod/lib/* ${LIB_PATH}/
    cp -r ${BOUNCER_PATH}/lua-mod/templates/* ${DATA_PATH}/templates/

    luarocks install lua-resty-http
    luarocks install lua-cjson
}


gen_apikey
install