#! /bin/sh
mkdir -p dump
cat sql/dump_Object.sql | \
mysql -A \
      -h lsst10.ncsa.illinois.edu \
      -B --quick --disable-column-names \
      > dump/Object.tsv
