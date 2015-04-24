#! /usr/bin/env python
from __future__ import division, print_function, with_statement

import json
import re
import socket

# This script outputs a list of the chunk IDs belonging to the host it is
# run on. Recognized workers are ccqserv101 .. ccqserv124. Chunks are
# assigned to workers in round robin order, and available chunk numbers
# are extracted from the Object table size estimates produced by
# sph-estimate-stats.

hostname = socket.gethostname()
m = re.match(r'ccqserv1(\d\d)', socket.gethostname())
if m:
    worker_id = int(m.group(1))
    if worker_id >= 1 and worker_id <= 24:
        with open('/qserv/data_generation/stats/Object/stats.json') as f:
            stats = json.load(f)
        chunk_ids = sorted(c['id'] for c in stats['chunks'])
        for i, c in enumerate(chunk_ids):
            if i % 24 == worker_id - 1:
                print(c)

