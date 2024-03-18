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

# 定义命令列表
./live777 &
sleep 2
./whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003 & 
sleep 2
./whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004 &
sleep 2
ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.webm &
ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -c:v libvpx  -quality realtime output1.webm  &
sleep 10
pgrep -f "ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30" | xargs kill
sleep 15
pkill live777
pkill whipinto
pkill whepfrom
# ffmpeg -i output1.webm -pix_fmt yuv420p output1.yuv
# ffmpeg -i output2.webm -pix_fmt yuv420p output2.yuv

# 检查是否成功创建output2.yuv文件
if [ -f "output1.webm" ] && [ -f "output2.webm" ]; then
    echo "output1.webm 和 output2.webm 文件均已成功生成"
    echo "output1.webm 文件路径为: $(readlink -f output1.webm)"
    echo "output2.webm 文件路径为: $(readlink -f output2.webm)"

    # 如果两个文件都生成成功，可以继续执行后续的命令
    # ...

else
    echo "Error: output1.yuv 或 output2.yuv 文件未完全生成"
fi

ffmpeg -i output1.webm -i output2.webm -lavfi psnr -f null -
docker run --rm -v $(pwd):/files vmaf  -r /files/output1.webm     /files/output2.webm
rm stream.sdp







