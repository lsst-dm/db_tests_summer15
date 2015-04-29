#! /bin/bash
set -e

if [ $# -ne 1 -o -z "$1" ]
then
    echo "Please supply the mysql root password"
    exit 1
fi

PASSWORD=$1
MYSQL="mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A"

source /qserv/stack/loadLSST.bash
setup mysql

# Use the mysql root user to create the LSST database and
# GRANT necessary permissions.
$MYSQL <<STATEMENTS
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

count_lsst=`$MYSQL -B --disable-column-names -e "SELECT COUNT(*) FROM qservw_worker.Dbs WHERE db='LSST'"`
if [ $count_lsst -eq 0 ]
then
    $MYSQL -e "INSERT INTO qservw_worker.Dbs VALUES ('LSST')"
fi
