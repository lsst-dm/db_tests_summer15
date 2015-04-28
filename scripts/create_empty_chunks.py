#! /usr/bin/env python
from __future__ import division, print_function, with_statement

import json
import re
import subprocess
import sys

# Get IDs of populated chunks
stats = json.loads(subprocess.check_output([
    'ssh', '-K', 'ccqserv101.in2p3.fr',
    'cat', '/qserv/data_generation/stats/Object/stats.json'
]))
chunk_ids = set(c['id'] for c in stats['chunks'])

# Get number of stripes
numStripes = None
with open('/sps/lsst/Qserv/smm/db_tests_summer15/conf/common.cfg') as f:
    for line in f:
        m = re.match(r'\s*num-stripes\s*=\s*(\d+)', line)
        if m:
            numStripes = int(m.group(1))
            break

if numStripes is None:
    print('Unable to determine number of stripes', file=sys.stderr)
    sys.exit(1)

for c in xrange(2 * numStripes**2):
    if c not in chunk_ids:
        print(c)
