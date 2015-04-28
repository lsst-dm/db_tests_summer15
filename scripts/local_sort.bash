#! /bin/bash
set -e

DATA_DIR=/qserv/data_generation/

mkdir -p $DATA_DIR/tmp

sort -k1,1 -n -t $'\t' -S 12G -T $DATA_DIR/tmp \
    -o $DATA_DIR/object-locations-sorted.tsv \
    $DATA_DIR/object-locations.tsv

sha512sum $DATA_DIR/object-locations-sorted.tsv \
        > $DATA_DIR/object-locations-sorted.tsv.sha512
