#! /bin/sh

TABLE=$1
MAX_LATITUDE=$2

CFG_DIR=/sps/lsst/Qserv/smm/db_tests_summer15/conf
INDEX_DIR=/qserv/data_generation/index
STATS_DIR=/qserv/data_generation/stats/$TABLE

source /qserv/stack/loadLSST.bash
setup partition

mkdir -p $STATS_DIR

sph-estimate-stats \
    --config-file=$CFG_DIR/common.cfg \
    --config-file=$CFG_DIR/$TABLE.duplicate.cfg \
    --index=$INDEX_DIR/$TABLE/htm_index.bin \
    --verbose \
    --lon-min=0 --lon-max=360 --lat-min=-90 --lat-max=$MAX_LATITUDE \
    --out.dir=$STATS_DIR \
    > $STATS_DIR/stats.json
