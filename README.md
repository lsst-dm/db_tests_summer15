Large Scale Database Tests, Summer 2015
---------------------------------------

This repository contains:
- scripts to dump an appropriate subset of the Winter 2013 Stripe 82 data release
- scripts that take those dumps and index/duplicate them to get to ~10% of the
  expected LSST DR1 release sizes.
- scripts to load the duplicated and partitioned raw files onto IN2P3 cluster
  nodes.
