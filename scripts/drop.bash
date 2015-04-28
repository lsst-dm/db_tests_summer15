#! /bin/bash
set -e

if [ $# -ne 1 -o -z "$1" ]
then
    echo "Please supply the mysql root password"
    exit 1
fi

PASSWORD=$1

source /qserv/stack/loadLSST.bash
setup mysql

mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -e "DROP DATABASE IF EXISTS LSST"
