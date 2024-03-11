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
ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -c:v libvpx  -quality realtime output1.webm
EOF

chmod +x out1.sh

cat >whip.sh <<EOF
#!/bin/bash
${TARGET_DIR}/whipinto -c vp8 -u http://localhost:7777/whip/777 --port 5003
EOF

chmod +x whip.sh
chmod +x ${TARGET_DIR}/whipinto

cat >whep.sh <<EOF
#!/bin/bash
${TARGET_DIR}/whepfrom -c vp8 -u http://localhost:7777/whep/777 -t localhost:5004
EOF

chmod +x whep.sh
chmod +x ${TARGET_DIR}/whepfrom

cat >out2.sh <<EOF
#!/bin/bash
ffmpeg -protocol_whitelist rtp,file,udp -i stream.sdp -c:v copy -an output2.webm
EOF

chmod +x out2.sh

cat >eval.sh <<EOF
#!/bin/bash
ffmpeg -i output1.webm -i output2.webm -lavfi "[0:v][1:v]libvmaf=psnr=1:log_fmt=json:log_path=vmaf.json" -f null -
EOF

chmod +x eval.sh

./test.sh \
    "${TARGET_DIR}/live777" \
    "./whip.sh" \
    "./whep.sh" \
    "./out2.sh" \
    "./out1.sh" \
# 等待5秒
sleep 5

# 中断 push.sh 进程
if [ -n "$(ps -p ${PID[5]} -o pid=)" ]; then
  echo "Stopping out1.sh pid ${PID[5]}"
  kill ${PID[5]}
fi

# 继续./eval.sh
./eval.sh 
 
rm stream.sdp
rm whip.sh
rm whep.sh
rm eval.sh
rm out1.sh
rm out2.sh


