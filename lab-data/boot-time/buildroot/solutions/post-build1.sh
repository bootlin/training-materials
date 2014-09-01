#!/bin/bash

echo "/root/go.sh &" > ${1}/etc/init.d/S99demo
chmod +x ${1}/etc/init.d/S99demo

echo "#!/bin/sh" > ${1}/root/go.sh
echo "dmesg | grep \"AT91: Detected soc subtype: sama5d34\" > /dev/null 2>&1" >> ${1}/root/go.sh
echo "if [ $? -eq 0 ]; then" >> ${1}/root/go.sh
echo "while \`ls /dev/fb0 > /dev/null 2>&1\`" >> ${1}/root/go.sh
echo "do" >> ${1}/root/go.sh
echo "echo -e \"\\nStarting video player\"" >> ${1}/root/go.sh
echo "gst-launch-0.10 filesrc location=/root/1frame.avi ! avidemux ! mpeg2dec ! ffmpegcolorspace ! fbdevsink 2>&1 > /dev/null" >> ${1}/root/go.sh
echo "echo -e \"\\nDone playing video\"" >> ${1}/root/go.sh
echo "sleep 5" >> ${1}/root/go.sh
echo "done" >> ${1}/root/go.sh
echo "fi" >> ${1}/root/go.sh
chmod +x ${1}/root/go.sh

cat << EOF > ${1}/init
#!/bin/sh
mount -t devtmpfs none /dev
exec /linuxrc
EOF
chmod +x ${1}/init

cp board/atmel/sama5d3ek_demo/MPEG2_480_272.avi ${1}/root/MPEG2_480_272.avi
cp board/atmel/sama5d3ek_demo/1frame.avi ${1}/root/

# alsa stuff
board/atmel/sama5d3ek_demo/alsa/post-build_alsa.sh $1 board/atmel/sama5d3ek_demo
