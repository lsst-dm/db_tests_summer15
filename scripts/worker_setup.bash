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

# Use the mysql root user to create the LSST database and
# GRANT necessary permissions.
mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A <<STATEMENTS
    DELETE FROM mysql.tables_priv
        WHERE Host = 'localhost' AND
              Db = 'scisql' AND
              User = 'qsmaster' AND
              Table_name = 'Region';
    FLUSH PRIVILEGES;
    CALL scisql.scisql_grantPermissions('qsmaster', 'localhost');
    CREATE DATABASE IF NOT EXISTS LSST;
    GRANT ALL ON LSST.* TO 'qsmaster'@'localhost';
    GRANT ALL ON \`Subchunks\\_%\`.* TO 'qsmaster'@'localhost';
    GRANT FILE ON *.* TO 'qsmaster'@'localhost';
STATEMENTS
