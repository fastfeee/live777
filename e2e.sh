#!/bin/bash

cat >stream.sdp <<EOF
v=0
m=video 5004 RTP/AVP 96
c=IN IP4 127.0.0.1
a=rtpmap:96 VP8/90000
EOF

# Define command list
./live777/target/release/live777 &
sleep 2
./live777/target/release/whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003 &
sleep 2
./live777/target/release/whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004 &
sleep 2
ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.webm &
ffmpeg -re -i output1.webm -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' &
sleep 15
pkill live777
pkill whipinto
pkill whepfrom






