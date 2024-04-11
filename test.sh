#!/bin/bash

ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=25 -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -c:v libvpx  -quality realtime input.webm &
sleep 10

pgrep -f "ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=25" | xargs kill

# 检查是否成功创建input.webm文件
if [ -f "input.webm" ]; then
    echo "input.webm 文件已成功生成，路径为: $(readlink -f input.webm)"

else
    echo "Error: input.webm 文件未生成"
fi

# 检查blankInsert.py文件是否存在
if [ -f "blankInsert.py" ]; then
    echo "blankInsert.py 文件已成功生成，路径为: $(readlink -f blankInsert.py)"
else
    echo "Error: blankInsert.py 文件未生成"
fi

mkdir frame && cd frame
mv ../input.webm ./
mv ../blankInsert.py ./
ffmpeg -i input.webm frames_%04d.png
python3 blankInsert.py
ffmpeg -framerate 25 -i frames_%04d.png -c:v libvpx -pix_fmt yuv420p output1.webm
# 检查是否成功创建output1.webm文件
if [ -f "output1.webm" ]; then
    echo "output1.webm 文件已成功生成，路径为: $(readlink -f output1.webm)"
else
    echo "Error: output1.webm 文件未生成"
fi
mv output1.webm ../
cd ..
rm -r frame

./e2e.sh

python3 blankCut.py output1.webm cut1.webm
python3 blankCut.py output2.webm cut2.webm

ffmpeg -i cut1.webm  -pix_fmt yuv420p cut1.yuv
ffmpeg -i cut2.webm  -pix_fmt yuv420p cut2.yuv

ffmpeg -i cut1.webm -i cut2.webm -lavfi psnr -f null -
docker run --rm -v $(pwd):/files vmaf yuv420p 640 480 /files/cut1.yuv   /files/cut2.yuv --out-fmt json
rm stream.sdp
