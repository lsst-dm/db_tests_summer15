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
This module implements a script for generating schema of the ForcedSource
table for large scale tests, based on DC_W13_Stripe82 schema.

@author  Jacek Becla, SLAC
"""

# decide which columns we want. The set below matches our baseline schema
# in terms of size (we will use coord_htmId20 to fake planned procHistoryId)
class ColInfo:
    def __init__(self, colName_, colType_):
        self.colName = colName_
        self.colType = colType_

allCols = [
    ColInfo("id", "BIGINT"),
    ColInfo("parent", "BIGINT"),
    ColInfo("coord_htmId20", "BIGINT"),
    ColInfo("flux_psf", "FLOAT"),
    ColInfo("flux_psf_err", "FLOAT"),
    ColInfo("flux_psf_flags", "TINYINT")
]

# produce strings that will be needed to generate:
# a) "create table Source (<column definitions>)"
# b) "insert into ForcedSource(<column names>) select <columns>
#    from RunDeepForcedSource"
createTableStr = ""
colStr = ""
for c in allCols:
    createTableStr += '''  %s %s,
''' % (c.colName, c.colType)
    colStr += "%s, " % c.colName

# remove the trailing ',' and the endl
createTableStr = createTableStr[:-2]
colStr = colStr[:-2]

# produce the final output
print '''CREATE TABLE ForcedSource (
%s
) ENGINE=MyISAM;

INSERT INTO ForcedSource(%s)
SELECT %s FROM RunDeepForcedSource;
''' % (createTableStr, colStr, colStr)
