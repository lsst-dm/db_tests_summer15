#!/usr/bin/python

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
This module implements a script for generating schema of the Object table
for large scale tests, based on DC_W13_Stripe82 schema.

@author  Jacek Becla, SLAC
"""

import MySQLdb
import re

DEFAULTS_FILE = '/home/becla/.lsst/dbAuth-W13.txt'

colsToSkip = ("deepCoaddId", "x", "y", "xVar", "yVar", "xyCov")

colsToSkipPerFilter = (
    "deepSourceId", "parentDeepSourceId", "filterId",
    "ra", "decl", "raVar", "declVar", "radeclCov", "htmId20")


con = MySQLdb.connect(read_default_file=DEFAULTS_FILE,
                      read_default_group="mysql")

# find the type for all columns in RunDeepSource table
colTypes = {}
cursor = con.cursor()
query = "select column_name, column_type from information_schema.columns where table_schema='DC_W13_Stripe82' and table_name='RunDeepSource'"
cursor.execute(query)
rows = cursor.fetchall()
for row in rows:
    colTypes[row[0]] = row[1]
cursor.close()

# get the schema for the DeepSource view (which is based on RunDeepSource)
cursor = con.cursor()
cursor.execute("show create view DeepSource")
ret = cursor.fetchone()
tableName, schema, v3, v4 = ret
rdsColumns = schema.split(',')
cursor.close()

# build an array containing:
# - name of source column (from RunDeepSource)
# - name of destination column (in Object, same as what we have in DeepSource)
# - the type of the column

class ColInfo:
    def __init__(self, srcCol_, destCol_, colType_):
        self.srcCol = srcCol_
        self.destCol = destCol_
        self.colType = colType_

allCols = []
for c in rdsColumns:
    m = re.search(r'`(\w+)`.`(\w+)` AS `(\w+)`', c)
    sourceTable = m.group(1)
    sourceCol = m.group(2)
    destCol = m.group(3)
    if sourceTable != 'RunDeepSource':
        sys.exit(1)
    if destCol not in colsToSkip:
        allCols.append(ColInfo(sourceCol, destCol, colTypes[sourceCol]))

# produce strings that will be needed to generate:
# a) "create table Object (<column definitions>)"
# b) "insert into Object(<column names>) select <columns> from RunDeepSource"
createTableStr = ""
insertIntoStr = ""
selectFromStr = ""

for c in allCols:
    createTableStr += '''  %s %s,
''' % (c.destCol, c.colType)
    insertIntoStr += "%s, " % c.destCol
    selectFromStr += "%s, " % c.srcCol

for filterName in ('u', 'g', 'r', 'i', 'z', 'y'):
    for c in allCols:
        if c.destCol not in colsToSkipPerFilter:
            createTableStr += '''  %s_%s %s,
''' % (filterName, c.destCol, c.colType)
            insertIntoStr += "%s_%s, " % (filterName, c.destCol)
            selectFromStr += "%s, " % c.srcCol
# remove the trailing ',' and the endl
createTableStr = createTableStr[:-2]
insertIntoStr = insertIntoStr[:-2]
selectFromStr = selectFromStr[:-2]

# produce the final output
print '''CREATE TABLE Object (
%s
) ENGINE=MyISAM;

INSERT INTO Object(%s)
SELECT %s FROM RunDeepSource;
''' % (createTableStr, insertIntoStr, selectFromStr)
