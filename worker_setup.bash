#! /bin/bash
set -e

PASSWORD=$1

source /qserv/stack/loadLSST.bash
setup mysql

# Use the mysql root user to create the LSST database and
# GRANT necessary permissions.
mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A <<STATEMENTS
    CALL scisql.scisql_grantPermissions('qsmaster', 'localhost');
    CREATE DATABASE LSST;
    GRANT ALL ON LSST.* TO 'qsmaster'@'localhost';
    GRANT ALL ON \`Subchunks\\_%\`.* TO 'qsmaster'@'localhost';
STATEMENTS
