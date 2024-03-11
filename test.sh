ARGC=$#

if [[ ${ARGC} == 0 ]]; then
  echo -e "\033[44;37;5m INPUT \033[0m ./test.sh 'python3 -m http.server 8001' 'python3 -m http.server 8002' 'sleep 10' '<...>'"
  exit
fi

echo -e "\033[44;37;5m RUNNING \033[0m  ${ARGC} COMMANDS"

for id in $(seq 1 $ARGC); do
  ${TARGET_DIR}/$(eval echo '$'{$id}) &
  PID[id]=$!

  echo "RUN ${id} pid ${PID[id]} : ${TARGET_DIR}/$(eval echo '$'{$id})"
done

