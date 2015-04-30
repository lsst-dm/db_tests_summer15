#! /bin/bash
set -e

if [ $# -ne 1 -o -z "$1" ]
then
    echo "Please supply a table name"
    exit 1
fi
TABLE=$1

CFG_DIR=/sps/lsst/Qserv/smm/db_tests_summer15/conf
SQL_DIR=/sps/lsst/Qserv/smm/db_tests_summer15/sql
TMP_DIR=`mktemp -d`

source /qserv/stack/loadLSST.bash
setup qserv test-cms-g1db60c04f1

touch $TMP_DIR/chunk_index.bin

qserv-data-loader.py \
    --chunks-dir=$TMP_DIR \
    --config=$CFG_DIR/common.cfg \
    --config=$CFG_DIR/$TABLE.duplicate.cfg \
    --skip-partition \
    --index-db= \
    --user=qsmaster \
    --socket=/qserv/run/var/lib/mysql/mysql.sock \
    LSST $TABLE $SQL_DIR/$TABLE.sql

rm -rf $TMP_DIR
