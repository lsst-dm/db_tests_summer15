#! /bin/bash
set -e

if [ $# -ne 1 -o -z "$1" ]
then
    echo "Please supply a table name"
    exit 1
fi
TABLE=$1

# Copy the dump file to local disk of all workers
echo "[INFO] `date`: copy dump file to local disk ..."
ansible workers -a "sudo -u qserv mkdir -p /qserv/data_generation/dump"
ansible workers -a "sudo -u qserv cp /sps/lsst/Qserv/smm/db_tests_summer15/dump/$TABLE.tsv /qserv/data_generation/dump/"

# HTM index the table
echo "[INFO] `date`: HTM index ..."
ansible workers -a "sudo -u qserv /sps/lsst/Qserv/smm/db_tests_summer15/scripts/index.bash $TABLE"

# Remove the dump, since it is no longer needed
echo "[INFO] `date`: remove dump file ..."
ansible workers -a "sudo -u qserv rm /qserv/data_generation/dump/$TABLE.tsv"

if [ "$TABLE" = Object ]
then
    # Estimate population of each chunk
    echo "[INFO] `date`: estimate chunk populations ..."
    ansible workers -a "sudo -u qserv /sps/lsst/Qserv/smm/db_tests_summer15/scripts/estimate.bash Object 45"
fi

# Duplicate and partition the table.
echo "[INFO] `date`: duplicate and partition ..."
ansible workers -a "sudo -u qserv /sps/lsst/Qserv/smm/db_tests_summer15/scripts/duplicate.bash $TABLE"

# Load chunks
echo "[INFO] `date`: load chunks ..."
ansible workers -a "sudo -u qserv /sps/lsst/Qserv/smm/db_tests_summer15/scripts/load.bash $TABLE"

# Remove the LOAD DATA INFILE inputs, which are no longer required
echo "[INFO] `date`: removing duplicated TSV files ..."
ansible workers -a "sudo -u qserv rm -rf /qserv/data_generation/chunks/$TABLE/"

if [ "$TABLE" = Object ]
then
    # Sort the local portions of the Object ID -> chunk/sub-chunk mapping
    echo "[INFO] `date`: sort secondary index pieces locally ..."
    ansible workers -a "sudo -u qserv /sps/lsst/Qserv/smm/db_tests_summer15/scripts/local_sort.bash"

    # Gather and merge-sort pieces of the mapping, then load it on the czar
    echo "[INFO] `date`: load secondary index ..."
    ansible czar -a "/sps/lsst/Qserv/smm/db_tests_summer15/scripts/load_object_index.bash"

    # Generate the empty-chunk list and copy it to the czar
    ansible czar -m shell -a '/sps/lsst/Qserv/smm/db_tests_summer15/scripts/create_empty_chunks.py | sudo -u qserv sh -c "cat > /qserv/run/var/lib/qserv/empty_LSST.txt"'
fi

# Update the CSS
ansible czar -a "sudo -u qserv /sps/lsst/Qserv/smm/db_tests_summer15/scripts/update_css.bash $TABLE"

echo "[INFO] `date`: done!"
