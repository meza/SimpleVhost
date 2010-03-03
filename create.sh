#! /bin/bash

# Script to easily deploy new websites
#
# @author meza <meza@meza.hu>
#

APACHE_SITE_AVAILABLE="/etc/apache2/sites-available"
APACHE_SITE_ENABLED="/etc/apache2/sites-enabled"
APACHE_LOG_DIR="/var/log/apache2"

site=$1
config="config.template"

function fetchName {
    if [ -z $site ]; then
	printf "%s" "Please specify a site name: "
	read site
	echo "Emty string recieved"
	fetchName
    fi
}

function checkConfig {

    if [ -a $config ]; then
	echo ""
    else
	echo "Config is not here"
	exit 1
    fi
}

function checkPermission {
    if [ -w $1 ]; then
	echo ""
    else
	echo "$2 Try sudo"
	exit 2
    fi
}

function checkPermissions {
    checkPermission $APACHE_SITE_AVAILABLE "Apache config dir is not wirtable by the current user"
    checkPermission $APACHE_LOG_DIR "Apache log dir is not wirtable by the current user"
}

function createTmpFile {
    cp $config $1
    chmod 666 $1
}

function editConfig {
    sed -i "s/$1/$2/g" $3
}

function createLogFiles {
    mkdir -p $1
    touch "$1/error.log"
    touch "$1/access.log"
}

function deployConfig {
    mv $1 "$APACHE_SITE_AVAILABLE/$1"
    chmod 644 "$APACHE_SITE_AVAILABLE/$1"
    a2ensite $1
}


function reloadApache {
    echo `/etc/init.d/apache2 reload`
}

checkPermissions
checkConfig
fetchName

TMPFILE="$site.conf"
createTmpFile $TMPFILE
editConfig "_SITE_" $site $TMPFILE
createLogFiles "$APACHE_LOG_DIR/$site"
deployConfig $TMPFILE
reloadApache


