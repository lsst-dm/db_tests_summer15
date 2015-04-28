#! /bin/bash
set -e

# Note, Kerberos authentication does not work for the qserv user, so this
# script has to be run as some other user on the czar. Otherwise, the scp
# commands below will fail.
OUT_DIR=/qserv/$USER

source /qserv/stack/loadLSST.bash
setup mysql

mkdir -p $OUT_DIR/runs $OUT_DIR/tmp

# The IN2P3 cluster seems to be on 1GbE, which is significantly slower
# than the disk subsystem. Therefore, there doesn't seem to be much point
# in parallelizing the gather.
let i=1
while [ $i -lt 25 ]
do
    node=$(printf "ccqserv1%02d" $i)
    dest=$(printf "$OUT_DIR/runs/object-%02d.tsv" $i)
    echo "`date`: copying run from $node"
    scp -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes \
        $node:/qserv/data_generation/object-locations-sorted.tsv $dest
    let i+=1
done

echo "`date`: merging sorted runs..."

sort -m -k1,1 -n -t $'\t' -S 12G -T $OUT_DIR/tmp --batch-size=50 \
    -o $OUT_DIR/object-locations-sorted.tsv \
    $OUT_DIR/runs/object-*.tsv

echo "`date`: computing check-sums ..."

sha512sum $OUT_DIR/object-locations-sorted.tsv \
        > $OUT_DIR/object-locations-sorted.tsv.sha512

echo "`date`: loading secondary index for LSST.Object"

mysql -u qsmaster -S /qserv/run/var/lib/mysql/mysql.sock -A -D qservMeta <<STATEMENTS
    DROP TABLE IF EXISTS LSST__Object;
    CREATE TABLE LSST__Object (
        deepSourceId BIGINT NOT NULL PRIMARY KEY,
        chunkId INTEGER NOT NULL,
        subChunkId INTEGER NOT NULL
    ) ENGINE=InnoDB;
    SET sql_log_bin=0;
    BEGIN;
    LOAD DATA INFILE '$OUT_DIR/object-locations-sorted.tsv' INTO TABLE LSST__Object;
    SHOW WARNINGS;
    COMMIT;
STATEMENTS

echo "`date`: done!"
