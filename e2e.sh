#!/bin/bash

TARGET_DIR="./target/release"

cat >stream.sdp <<EOF
v=0
m=video 5004 RTP/AVP 96
c=IN IP4 127.0.0.1
a=rtpmap:96 VP8/90000
EOF

cat >out1.sh <<EOF
#!/bin/bash
ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -c:v libvpx -b:v 1M -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -an output1.yuv
EOF

chmod +x out1.sh

cat >whip.sh <<EOF
#!/bin/bash
${TARGET_DIR}/whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003 --command "ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -vcodec libvpx -cpu-used 5 -deadline 1 -g 10 -error-resilient 1 -auto-alt-ref 1 -f rtp 'rtp://127.0.0.1:{port}?pkt_size=1200'"
EOF

chmod +x whip.sh
chmod +x ${TARGET_DIR}/whipinto

cat >whep.sh <<EOF
#!/bin/bash
sleep 10
${TARGET_DIR}/whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004 --command "ffplay -protocol_whitelist rtp,file,udp -i stream.sdp"
EOF

chmod +x whep.sh
chmod +x ${TARGET_DIR}/whepfrom

cat >out2.sh <<EOF
#!/bin/bash
ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.yuv
EOF

chmod +x out2.sh

cat >vmaf.sh <<EOF
#!/bin/bash
docker run --rm -v $(pwd):/files vmaf     yuv420p 640 480     /files/output1.yuv     /files/output2.yuv     --out-fmt json
EOF

chmod +x vmaf.sh

./multirun.sh \
    "${TARGET_DIR}/live777" \
    "./out2.sh" \
    "./out1.sh" \
    "./whip.sh" \
    "./whep.sh" \
    "sleep 30"  \
    "killall 'out1.sh' " \
    "./vmaf.sh "

rm stream.sdp
rm whip.sh
rm whep.sh
rm out1.sh
rm out2.sh
rm vmaf.sh

