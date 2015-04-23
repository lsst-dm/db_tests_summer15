#! /bin/sh
mkdir -p dump
cat sql/dump_Source.sql | \
mysql -A \
      -h lsst10.ncsa.illinois.edu \
      -B --quick --disable-column-names \
      > dump/Source.tsv
