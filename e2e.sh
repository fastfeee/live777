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

    # 执行后续的命令
    # ...

else
    echo "Error: stream.sdp 文件未生成"
fi


gnome-terminal -- bash -c "./live777; exec bash"
gnome-terminal -- bash -c "./whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003;exec bash"
gnome-terminal -- bash -c "./whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004;exec bash"
sleep 5
gnome-terminal -- bash -c "ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.webm"
sleep 5
gnome-terminal -- bash -c "ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -c:v libvpx  -quality realtime output1.webm"
sleep 10

pgrep -f "ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30" | xargs kill
sleep 25
pkill live777
pkill whipinto
pkill whepfrom
sleep 5 
ffmpeg -i output1.webm -pix_fmt yuv420p output1.yuv
ffmpeg -i output2.webm -pix_fmt yuv420p output2.yuv
rm stream.sdp








