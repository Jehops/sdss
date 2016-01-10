#!/bin/sh

interval=3 # customize this
stump_pid=$(pgrep -a -n stumpwm)

# while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    echo $(/usr/sbin/mixer -s vol | sed 's/vol [0-9]*://')
    sleep ${interval}
done
