#!/bin/bash

cat >stream.sdp <<EOF
v=0
m=video 5004 RTP/AVP 96
c=IN IP4 127.0.0.1
a=rtpmap:96 VP8/90000
EOF

# 检查是否成功创建stream.sdp文件
if [ -f "stream.sdp" ]; then
    echo "stream.sdp 文件已成功生成，路径为: $(readlink -f stream.sdp)"

else
    echo "Error: stream.sdp 文件未生成"
fi

# 定义命令列表
./live777 &
sleep 2
./whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003 &
sleep 2
./whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004 &
sleep 2
ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.webm &
ffmpeg -re -i output1.webm -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' &
sleep 10
pgrep -f "ffmpeg -re -i output1.webm -vcodec libvpx -f rtp" | xargs kill
sleep 15
pkill live777
pkill whipinto
pkill whepfrom

# 检查是否成功创建output2.webm文件
if [ -f "output2.webm" ]; then
    echo "output2.webm 文件已成功生成，路径为: $(readlink -f output2.webm)"

else
    echo "Error: output2.webm 文件未生成"
fi







