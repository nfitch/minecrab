#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

#if [ -z "$1" ]; then
#  REMOTE_FILE="/Joyent_Dev/public/minecraft/servers/$1/server/world.tar.gz"
#fi

#debug="yes please"

#set -x trace

function runjob {
  world=$REMOTE_FILE
  if [ -z "$world" ]; then
    fatal "Missing server name (REMOTE_FILE)"
  fi
  init_script="https://raw.github.com/joyent/minecraft/master/scripts/prepare_render.sh?token=58699__eyJzY29wZSI6IlJhd0Jsb2I6am95ZW50L21pbmVjcmFmdC9tYXN0ZXIvc2NyaXB0cy9wcmVwYXJlX3JlbmRlci5zaCIsImV4cGlyZXMiOjEzODQ5MDgzODJ9--693c6e94b5c177c6304af5c8d29585a75795c7d1"
  #   --asset $map \
  echo "Kicking off job..."
  manta_req_uuid=$(\
    echo "$world" | mjob create \
      --memory=4096 \
      --init "curl $init_script | sh | tee /init.log" \
      -m '/render.sh | tee /render.log' \
  )

  echo "Job $manta_req_uuid running!"
  if [ ! -n "$debug" ]; then
      exit 0
  fi

  job_status=$(mjob watch $manta_req_uuid)
  echo "==================================================="
  echo "status:"
  json <<<${job_status}

  job_outputs=$(mjob outputs $manta_req_uuid)
  if [ -n "$job_outputs" ]; then
    echo "==================================================="
    echo "outputs:"
    echo $job_outputs
    mget $job_outputs
    #json <<<$job_outputs
    #errobj=$(echo $job_outputs | json stderr)
    #if [ -n "$stdout_obj" ]; then
      #mget $stdout_obj
    #fi
  fi

  job_errors=$(mjob errors $manta_req_uuid)
  if [ -n "$job_errors" ]; then
    echo "==================================================="
    echo "errors:"
    json <<<$job_errors
    errobj=$(echo $job_errors | json stderr)
    if [ -n "$errobj" ]; then
      mget $errobj
    fi
  fi
}

runjob
