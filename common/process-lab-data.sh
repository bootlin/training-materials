#!/bin/sh
# This script is called under fakeroot

OUT_LAB_DATA=$1

tarball_extracted=no
for f in `find ${OUT_LAB_DATA} -name "*.tar.xz"`; do
	tar -C `dirname $f` -Jxf $f
	rm -f $f
	tarball_extracted=yes
done

if test "${tarball_extracted}" = "yes"; then
    chown -R $USER.$USER ${OUT_LAB_DATA}
fi
