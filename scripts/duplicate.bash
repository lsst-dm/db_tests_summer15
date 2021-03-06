#! /bin/bash

if [ $# -ne 1 -o -z "$1" ]
then
    echo "Please supply a table name"
    exit 1
fi

TABLE=$1
CFG_DIR=/sps/lsst/Qserv/smm/db_tests_summer15/conf
INDEX_DIR=/qserv/data_generation/index
CHUNKS_DIR=/qserv/data_generation/chunks

source /qserv/stack/loadLSST.bash
setup partition

# Generate a config file containing the list of chunks to
# generate data for.
echo "chunk-id = [" > /tmp/chunks.cfg
/sps/lsst/Qserv/smm/db_tests_summer15/scripts/my_chunks.py >> /tmp/chunks.cfg
echo "]" >>  /tmp/chunks.cfg

mkdir -p $CHUNKS_DIR

sph-duplicate \
    --verbose \
    --config-file=$CFG_DIR/common.cfg \
    --config-file=$CFG_DIR/$TABLE.duplicate.cfg \
    --config-file=/tmp/chunks.cfg \
    --index=$INDEX_DIR/$TABLE/htm_index.bin \
    --part.index=$INDEX_DIR/Object/htm_index.bin \
    --mr.num-workers=8 \
    --mr.pool-size=8192 \
    --mr.block-size=16 \
    --out.dir=$CHUNKS_DIR/$TABLE \
    > $CHUNKS_DIR/$TABLE.log 2>&1
