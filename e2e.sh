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
ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -c:v libvpx -b:v 1M -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200' -an output1.webm
EOF

chmod +x out1.sh

cat >whip.sh <<EOF
#!/bin/bash
${TARGET_DIR}/whipinto -c vp8 -u http://localhost:7777/whip/777 
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

cat >push.sh <<EOF
#!/bin/bash
ffmpeg -re -f lavfi -i testsrc=size=640x480:rate=30 -vcodec libvpx -f rtp 'rtp://127.0.0.1:5003?pkt_size=1200'
EOF

chmod +x push.sh

./multirun.sh \
    "${TARGET_DIR}/live777" \
    "./push.sh" \
    "./whip.sh" \
    "./whep.sh" &

# 等待5秒
sleep 5

# 中断 push.sh 进程
if [ -n "$(ps -p ${PID[2]} -o pid=)" ]; then
  echo "Stopping push.sh pid ${PID[2]}"
  kill ${PID[2]}
fi

# 继续开启两个终端执行 ./out2.sh 和 ./out1.sh
./out2.sh &
./out1.sh &  
rm stream.sdp
rm whip.sh
rm whep.sh
rm pull.sh
rm out1.sh
rm out2.sh


