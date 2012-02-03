#! /bin/sh
split -b 2K x-load.bin.ift split-
for file in `ls split-a?`; do
    cat $file >> x-load-ddp.bin.ift
    cat $file >> x-load-ddp.bin.ift
done
rm -f split-*