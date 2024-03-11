#!/bin/bash

TARGET_DIR="./target/release"

cd $TARGET_DIR

cat >stream.sdp <<EOF
v=0
m=video 5004 RTP/AVP 96
c=IN IP4 127.0.0.1
a=rtpmap:96 VP8/90000
EOF


cat >eval.sh <<EOF
#!/bin/bash
ffmpeg -i output1.webm -i output2.webm -lavfi "[0:v][1:v]libvmaf=psnr=1:log_fmt=json:log_path=vmaf.json" -f null -
EOF

chmod +x eval.sh

./test.sh \
    "${TARGET_DIR}/live777" \
    "sleep 2"  \
    "${TARGET_DIR}/whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003" \
    "${TARGET_DIR}/whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004" \
    "ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.webm" \
    "timeout 5 ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -c:v libvpx  -quality realtime output1.webm"


# 等待./test.sh执行完成后执行./eval.sh
if [ -f "output1.webm" ] && [ -f "output2.webm" ]; then
    ./eval.sh
else
    echo "Error: output1.webm or output2.webm not generated."
fi

rm stream.sdp
rm eval.sh




