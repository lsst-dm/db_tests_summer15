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

# Use the mysql root user to grant the SUPER privilege to qsmaster. This
# privilege is needed to SET sql_log_bin=0 for the current session. This mess 
# needs to be revisited later...
mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A <<STATEMENTS
    UPDATE mysql.user SET Super_Priv='Y'
        WHERE user = 'qsmaster' AND host = 'localhost';
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS LSST;
    GRANT ALL ON LSST.* TO 'qsmaster'@'localhost';
    GRANT FILE ON *.* TO 'qsmaster'@'localhost';
STATEMENTS
