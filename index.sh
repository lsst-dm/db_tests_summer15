#! /bin/sh

TABLE=$1
CFG_DIR=/sps/lsst/Qserv/smm/db_tests_summer15/conf
INDEX_DIR=/qserv/data_generation/index
DUMP_DIR=/qserv/data_generation/dump

source /qserv/stack/loadLSST.bash
setup partition

mkdir -p $INDEX_DIR

sph-htm-index \
    --config-file=$CFG_DIR/common.cfg \
    --config-file=$CFG_DIR/$TABLE.index.cfg \
    --in.csv.null=NULL \
    --in.csv.delimiter=$'\t' \
    --in.csv.escape=\\ \
    --in.csv.quote='"' \
    --in=$DUMP_DIR/$TABLE.tsv \
    --verbose \
    --mr.num-workers=8 \
    --mr.pool-size=8192 \
    --mr.block-size=16 \
    --out.dir=$INDEX_DIR/$TABLE
