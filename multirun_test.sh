#!/bin/bash

ARGC=$#

if [[ ${ARGC} == 0 ]]; then
  echo -e "\033[44;37;5m INPUT \033[0m ./multirun.sh 'command1' 'command2' 'command3'"
  exit
fi

echo -e "\033[44;37;5m RUNNING \033[0m  ${ARGC} COMMANDS"

# 定义一个数组用于存储进程ID
declare -a PID

for id in $(seq 1 $ARGC); do
  eval ${id} &  # 不使用 $()，直接后台执行
  PID[id]=$!

  echo "RUN ${id} pid ${PID[id]} : $(eval echo '$'{$id})"
done

# 等待 15 秒
sleep 15

# 中断 out1.sh
if [ -n "$(ps -p ${PID[3]} -o pid=)" ]; then
  echo "Stopping out1.sh pid ${PID[3]}"
  kill ${PID[3]}
fi

# 等待 out2.sh 完成
wait ${PID[2]}

# 执行 ./vmaf.sh
"./vmaf.sh"

# 输出停止信息
echo -e "\033[41;37;5m STOP \033[0m  ${ARGC} COMMANDS"

# 停止所有正在运行的命令
for id in $(seq 1 $ARGC); do
  if [ -n "$(ps -p ${PID[id]} -o pid=)" ]; then
    echo "STOP ${id} pid ${PID[id]}"
    kill ${PID[id]}
  fi
done

exit
