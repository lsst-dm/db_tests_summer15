#! /bin/sh
mkdir -p dump
cat sql/dump_ForcedSource.sql | \
mysql -A \
      -h lsst10.ncsa.illinois.edu \
      -B --quick --disable-column-names \
      > dump/ForcedSource.tsv
