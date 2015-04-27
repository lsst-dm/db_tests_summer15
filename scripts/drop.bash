#! /bin/bash
set -e

PASSWORD=$1

source /qserv/stack/loadLSST.bash
setup mysql

mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -e "DROP DATABASE LSST"
