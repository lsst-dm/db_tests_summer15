#! /bin/bash

TABLE=$1
mkdir -p dump

cat sql/dump_$TABLE.sql | \
mysql -A \
      -h lsst10.ncsa.illinois.edu \
      -B --quick --disable-column-names \
      > dump/$TABLE.tsv
