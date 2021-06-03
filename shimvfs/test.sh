#!/bin/bash

set -e

HERE=$(dirname $(readlink -f "$0"))

VFS_FILE=${1:-"$HERE/shimvfs.c"}
VFS_DIR=$(dirname "$VFS_FILE")
VFS_BASE=$(basename "$VFS_FILE")
VFS=$(basename "$VFS_FILE" ".c")

if [ "$#" -gt 0 ];
then
    shift
fi

OPTS="-I'$VFS_DIR' -I'$VFS_DIR/../include' -DTEST_VFS -DSQLITE_EXTRA_INIT=sqlite3_${VFS}_register -DSQLITE_MAX_MMAP_SIZE=0 -DSQLITE_OMIT_WAL"

make clean

make "OPTS=$OPTS" sqlite3.c

echo "#line 1 \"$VFS_BASE\"" >> sqlite3.c
cat "$VFS_FILE" >> sqlite3.c

# Other interesting targets:
#  mptest: multi-process locks
#  fulltestonly, fulltest, soaktest: more extensive tests
#  valgrindtest
make "OPTS=$OPTS" test "$@"
