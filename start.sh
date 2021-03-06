#!/usr/bin/env bash

show_help() {
  echo "Usage: ./start.sh"
  echo ""
  echo "-d or --down delete all container"
  echo "-wp or --windows-path convert to Windows path"
  echo "-wt or --wait-time wait for backend in s. <= 0 no wait at all. Default 500s"
  echo "-h or --help"
}

set_windows_path(){
  export COMPOSE_CONVERT_WINDOWS_PATHS=1
}

down(){
  docker-compose down
  exit 0
}

set_wait_time(){
  WAIT_TIME=$1
}

set_host(){
  SERVER_HOST=$1
}

set_port(){
  SERVER_PORT=$1
}

set_protocol(){
  PROTOCOL=$1
}

# Defaults
WAIT_TIME=500
SERVER_HOST="localhost"
SERVER_PORT="80"
PROTOCOL="http"

while [[ $1 == -* ]]; do
  case "$1" in
    -h|--help|-\?) show_help; exit 0;;
    -wp|--windows-path)  set_windows_path; shift;;
    -d|--down)  down; shift;;
    -wt|--wait-time)  set_wait_time $2; shift 2;;
    -sh|--server-host)  set_host $2; shift 2;;
    -sp|--server-port)  set_port $2; shift 2;;
    -spr|--set-protocol)  set_protocol $2; shift 2;;
    -*) echo "invalid option: $1" 1>&2; show_help; exit 1;;
  esac
done

echo "Start docker compose"
export SERVER_HOST
export SERVER_PORT
export PROTOCOL
docker-compose up -d

sleep 5

# sudo chown -R 33007 data/solr-data
# sudo chown -R 999 logs

if [[ $WAIT_TIME -gt 0 ]]; then
  echo "Waiting for alfresco to boot ..."
  WAIT_TIME=$(( ${WAIT_TIME} * 1000 ))
  npx wait-on "${PROTOCOL}://${SERVER_HOST}:${SERVER_PORT}/alfresco/" -t "${WAIT_TIME}" -i 10000 -v
  if [ $? == 1 ]; then
    echo "Waiting failed -> exit 1"
    exit 1
  fi
fi
