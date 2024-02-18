#!/usr/bin/env bash

tart run --dir=dart:~/src/dart ubuntu &

echo "to suspend"
echo "tart suspend ubuntu"
sleep 10

ssh admin@$(tart ip ubuntu)
