#! /bin/bash
set -e

TABLE=$1
PASSWORD=$2

SQL_DIR=/sps/lsst/Qserv/smm/db_tests_summer15/sql
CHUNKS_DIR=/qserv/data_generation/chunks

source /qserv/stack/loadLSST.bash
setup mysql

# Obtain the list of chunks owned by this node.
CHUNKS=`/sps/lsst/Qserv/smm/db_tests_summer15/my_chunks.py`

# First, create the LSST database if it does not already exist.
mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A \
      -e "CREATE DATABASE IF NOT EXISTS LSST"

# Next, create the table we want to create.
mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -D LSST \
      < $SQL_DIR/$TABLE.sql

# Remove the local portion of the deepSourceId to partition
# mapping if we are loading Objects (we are about to recompute it).
if [ $TABLE == Object ]
then
    rm -f /qserv/data_generation/object-locations.tsv
fi

for C in $CHUNKS ; do
    echo "`date`: loading chunk $C ..."

    CHUNK_FILE=$CHUNKS_DIR/$TABLE/chunk_$C.txt
    CHUNK_TABLE=${TABLE}_${C}

    # Create the chunk table.
    mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -D LSST \
          -e "CREATE TABLE $CHUNK_TABLE LIKE $TABLE"

    if [ -s $CHUNK_FILE ]
    then
        # Load the chunk table, with the usual optimizations.
        mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -D LSST <<SQL
            SET myisam_sort_buffer_size = 4294967296;
            ALTER TABLE $CHUNK_TABLE DISABLE KEYS;
            LOAD DATA INFILE '$CHUNK_FILE' INTO TABLE $CHUNK_TABLE;
            SHOW WARNINGS;
            ALTER TABLE $CHUNK_TABLE ENABLE KEYS;
SQL
            if [ $TABLE == Object ]
            then
                # If this is the Object table, extract the local portion of the
                # deepSourceId to partition mapping.
                mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock \
                      -A -D LSST -B --quick --disable-column-names \
                      -e "SELECT deepSourceId, chunkId, subChunkId FROM $CHUNK_TABLE" \
                      >> /qserv/data_generation/object-locations.tsv
            fi
    fi

    if [ $TABLE == Object ]
    then
        # For the Object table, additionally create and load overlap chunks.
        CHUNK_FILE=$CHUNKS_DIR/$TABLE/chunk_${C}_overlap.txt
        CHUNK_TABLE=${TABLE}FullOverlap_${C}

        # Drop the PK, because a single Object can be in the overlap region
        # of more than one chunk.
        mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -D LSST <<SQL
            CREATE TABLE $CHUNK_TABLE LIKE $TABLE;
            ALTER TABLE $CHUNK_TABLE DROP PRIMARY KEY;
SQL
        if [ -s $CHUNK_FILE ]
        then
            mysql -u root -p$PASSWORD -S /qserv/run/var/lib/mysql/mysql.sock -A -D LSST <<SQL
                SET myisam_sort_buffer_size = 4294967296;
                ALTER TABLE $CHUNK_TABLE DISABLE KEYS;
                LOAD DATA INFILE '$CHUNK_FILE' INTO TABLE $CHUNK_TABLE;
                SHOW WARNINGS;
                ALTER TABLE $CHUNK_TABLE ENABLE KEYS;
SQL
        fi
    fi

done

echo "`date`: finished loading $TABLE chunks"
