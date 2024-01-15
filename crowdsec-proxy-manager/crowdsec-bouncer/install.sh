#!/bin/bash

LUA_MOD_DIR="./lua-mod"
NGINX_CONF="crowdsec_nginx.conf"
NGINX_CONF_DIR="/etc/nginx/conf.d/"

LIB_PATH="/usr/local/lua/crowdsec/"
CONFIG_PATH="/etc/crowdsec/bouncers/"
DATA_PATH="/var/lib/crowdsec/lua/"
LAPI_DEFAULT_PORT="8080"

usage() {
      echo "Usage:"
      echo "    ./install.sh -h                 Display this help message."
      echo "    ./install.sh                    Install the bouncer in interactive mode"
      echo "    ./install.sh -y                 Install the bouncer and accept everything"
      exit 0  
}

gen_apikey() {
    
    type cscli > /dev/null

    if [ "$?" -eq "0" ] ; then
        SUFFIX=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
        API_KEY="cscli bouncers add crowdsec-nginx-bouncer-${SUFFIX} -o raw"
        PORT=$(cscli config show --key "Config.API.Server.ListenURI"|cut -d ":" -f2)
        if [ ! -z "$PORT" ]; then
            LAPI_DEFAULT_PORT=${PORT}
        fi
        echo "Bouncer registered to the CrowdSec Local API."
    else
        echo "cscli is not present, unable to register the bouncer to the CrowdSec Local API."
    fi
    CROWDSEC_LAPI_URL="http://127.0.0.1:${LAPI_DEFAULT_PORT}"
    mkdir -p "${CONFIG_PATH}"
    API_KEY=${API_KEY} CROWDSEC_LAPI_URL=${CROWDSEC_LAPI_URL} envsubst < ${LUA_MOD_DIR}/config_example.conf | tee -a "${CONFIG_PATH}crowdsec-nginx-bouncer.conf" >/dev/null
}

install() {
    mkdir -p ${LIB_PATH}/plugins/crowdsec/
    mkdir -p ${DATA_PATH}/templates/

    cp nginx/${NGINX_CONF} ${NGINX_CONF_DIR}/${NGINX_CONF}
    cp -r ${LUA_MOD_DIR}/lib/* ${LIB_PATH}/
    cp -r ${LUA_MOD_DIR}/templates/* ${DATA_PATH}/templates/

    luarocks install lua-resty-http
    luarocks install lua-cjson
}


gen_apikey
install


echo "crowdsec-nginx-bouncer installed successfully"