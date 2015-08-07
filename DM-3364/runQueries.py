#!/usr/bin/env python

# LSST Data Management System
# Copyright 2015 AURA/LSST.
#
# This product includes software developed by the
# LSST Project (http://www.lsst.org/).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the LSST License Statement and
# the GNU General Public License along with this program.  If not,
# see <http://www.lsstcorp.org/LegalNotices/>.

"""
A test program that runs queries in parallel. The queries will run
with the database we have on the IN2P3 cluster for the Summer 2015
test.

@author  Jacek Becla, SLAC
"""

import commands
import logging
import pprint
import random
import threading
import time

import MySQLdb

###############################################################################
# Queries to run, grouped into different pools of queries
###############################################################################

queryPools = {}

# Low Volume Queries
queryPools["LV"] = []
for i in range(0, 10):
    # single object
    queryPools["LV"].append("SELECT ra, decl FROM Object WHERE deepSourceId = %d" % random.randint(2251799813685248, 4503595332407303))

    # small area selection
    raMin = random.uniform(0, 350)
    declMin = random.uniform(-87, 45)
    raDist = random.uniform(0.01, 0.2)
    declDist = random.uniform(0.01, 0.2)
    queryPools["LV"].append("SELECT ra, decl FROM Object WHERE qserv_areaspec_box(%f, %f, %f, %f)" % (raMin, declMin, raMin+raDist, declMin+declDist))

    # small area join
    raMin = random.uniform(0, 350)
    declMin = random.uniform(-87, 45)
    raDist = random.uniform(0.01, 0.1)
    declDist = random.uniform(0.01, 0.2)
    queryPools["LV"].append("SELECT o.deepSourceId FROM Object o, Source s WHERE qserv_areaspec_box(%f, %f, %f, %f) and o.deepSourceId = s.objectId" % (raMin, declMin, raMin+raDist, declMin+declDist))



# Full-table-scans on Object
queryPools["FTSObj"] = [
    "SELECT COUNT(*) FROM Object WHERE y_instFlux > 5",
    "SELECT MIN(ra), MAX(ra) FROM Object WHERE decl > 3",
    "SELECT MIN(ra), MAX(ra), MIN(decl), MAX(decl) FROM Object",
    "SELECT COUNT(*) AS n, AVG(ra), AVG(decl), chunkId FROM Object GROUP BY chunkId"
]

# Full-table-scans on Source
queryPools["FTSSrc"] = [
    "SELECT COUNT(*) FROM Source WHERE flux_sinc BETWEEN 1 AND 2"
]

# Full-table-scans on ForcedSource
queryPools["FTSFSrc"] = [
    "SELECT COUNT(*) FROM ForcedSource WHERE psfFlux BETWEEN 0.1 AND 0.2"
]

# Object-Source Joins
queryPools["joinObjSrs"] = [
    "SELECT o.deepSourceId, s.objectId, s.id, o.ra, o.decl FROM Object o, Source s WHERE o.deepSourceId=s.objectId AND s.flux_sinc BETWEEN 0.3 AND 0.31"
]

pp = pprint.PrettyPrinter(indent=4)
pp.pprint(queryPools)

###############################################################################
# Definition of how many queries from each pool we want to run simultaneously
###############################################################################

concurrency = {
    "LV": 10,
    "FTSObj": 2,
    "FTSSrc": 2,
    "FTSFSrc": 0,
    "joinObjSrs": 1
}

###############################################################################
# Function that is executed inside a thread. It runs one query at a time.
# The query is picked randomly from the provided pool of queries.
###############################################################################

def runQueries(qPoolId):
    #sleepTime = {"LV":3,"FTSObj":7, "FTSSrc":8, "FTSFSrc":5, "joinObjSrs":15 }
    time.sleep(random.randint(0,10)) # comment this out to skip staggering
    logging.debug("My query pool: %s", qPoolId)
    qPool = queryPools[qPoolId]
    conn = MySQLdb.connect(host='ccqserv100',
                           port=4040,
                           user='qsmaster',
                           passwd='',
                           db='LSST')
    cursor = conn.cursor()
    while (1):
        q = random.choice(qPool)
        logging.debug("Running: %s", q)
        startTime = time.time()
        #time.sleep(sleepTime[qPoolId])
        cursor.execute(q)
        rows = cursor.fetchall()
        f = open("/tmp/%s_%s" % (qPoolId,threading.current_thread().ident), 'a')
        f.write("\n*************************************************\n")
        f.write("%s\n---\n" % q)
        for row in rows:
            for col in row:
                f.write("%s, " % col)
            f.write("\n")
        f.close()
        elapsedTime = time.time() - startTime
        logging.info('QTYPE_%s: %s %s', qPoolId, elapsedTime, q)

###############################################################################
# Main. Starts all the threads. The threads will keep running for up to 24 h,
# or until the program gets interrupted (e.g. with Ctrl-C). Logging goes to a
# file in /tmp
###############################################################################

def main():
    logging.basicConfig(format="%(thread)d: %(message)s",
                        filename='/tmp/qservMTest.log',
                        level=logging.DEBUG)
    random.seed(123)

    for queryPoolId in queryPools:
        qCount = concurrency[queryPoolId]
        for i in range(0, qCount):
            t = threading.Thread(target=runQueries, args=(queryPoolId,))
            t.daemon = True
            t.start()
            t.join

    time.sleep(60*60*24)

if __name__ == "__main__":
    main()
