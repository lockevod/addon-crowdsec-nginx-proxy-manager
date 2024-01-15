#!/bin/bash

REQUIRE_SCRIPT="./lua-mod/uninstall.sh"
NGINX_CONF="crowdsec_nginx.conf"
NGINX_CONF_DIR="/etc/nginx/conf.d/"
ACCESS_FILE="access.lua"
LIB_PATH="/usr/local/lua/crowdsec/"
DATA_PATH="/var/lib/crowdsec/lua/"
SILENT="false"

usage() {
      echo "Usage:"
      echo "    ./uninstall.sh -h                 Display this help message."
      echo "    ./uninstall.sh                    Uninstall the bouncer in interactive mode"
      echo "    ./uninstall.sh -y                 Uninstall the bouncer and accept everything"
      exit 0  
}

#Accept cmdline arguments to overwrite options.
while [[ $# -gt 0 ]]
do
    case $1 in
        -y|--yes)
            SILENT="true"
            shift
        ;;
        -h|--help)
            usage
        ;;
    esac
    shift
done


requirement() {
    if [ -f "$REQUIRE_SCRIPT" ]; then
        bash $REQUIRE_SCRIPT
    fi
}


remove_nginx_dependency() {
    DEPENDENCY=(
        "libnginx-mod-http-lua"
        "luarocks"
        "lua5.1"
        "gettext-base"
    )
    for dep in ${DEPENDENCY[@]};
    do
        dpkg -l | grep ${dep} > /dev/null
        if [[ $? == 0 ]]; then
            if [[ ${SILENT} == "true" ]]; then
                sudo apt-get install -y -qq ${dep} > /dev/null && echo "${dep} successfully removed"
            else
                echo "${dep} found, do you want to remove it (Y/n)? "
                read answer
                if [[ ${answer} == "" ]]; then
                    answer="y"
                fi
                if [ "$answer" != "${answer#[Yy]}" ] ;then
                    apt-get remove --purge -y -qq ${dep} > /dev/null && echo "${dep} successfully removed"
                fi
            fi
        fi
    done
}


uninstall() {
	rm ${NGINX_CONF_DIR}/${NGINX_CONF}
    rm -rf ${DATA_PATH}
    rm -rf ${LIB_PATH}
}

if ! [ $(id -u) = 0 ]; then
    log_err "Please run the uninstall script as root or with sudo"
    exit 1
fi
requirement
remove_nginx_dependency
uninstall
echo "crowdsec-nginx-bouncer uninstalled successfully"