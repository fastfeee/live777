#!/bin/bash

ffmpeg -f lavfi -i testsrc=size=640x480:rate=25 -t 10 -c:v libvpx input.webm


ffmpeg -i input.webm frames_%04d.png
python3 blankInsert.py
ffmpeg -framerate 25 -i frames_%04d.png -c:v libvpx -pix_fmt yuv420p output1.webm

./e2e.sh

python3 blankCut.py output1.webm cut1.webm
python3 blankCut.py output2.webm cut2.webm

ffmpeg -i cut1.webm  -pix_fmt yuv420p cut1.yuv
ffmpeg -i cut2.webm  -pix_fmt yuv420p cut2.yuv

ffmpeg -i cut1.webm -i cut2.webm -lavfi psnr -f null -
docker run --rm -v $(pwd):/files vmaf yuv420p 640 480 /files/cut1.yuv   /files/cut2.yuv --out-fmt json
rm stream.sdp
