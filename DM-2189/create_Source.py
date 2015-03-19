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
This module implements a script for generating schema of the Source table
for large scale tests, based on DC_W13_Stripe82 schema.

@author  Jacek Becla, SLAC
"""

import MySQLdb

DEFAULTS_FILE = '/home/becla/.lsst/dbAuth-W13.txt'

# decide on the brightness of measurements we want
fluxLimit = 200000

# produce the final output
print '''CREATE TABLE Source LIKE RunDeepForcedSource;

INSERT INTO Source
SELECT * FROM RunDeepForcedSource
WHERE flux_psf > %d;
''' %  fluxLimit
