#!/bin/sh

## customize these
## use host=. for local host
ap="/usr/local/bin/mpg123"
nms="${HOME}/files/media/audio/chime.mp3"
count=0
host=.
newcount=0
path=~/mail/new
port=22
user=me
interval=10

stump_pid=$(pgrep -a -n stumpwm)

## while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    if [ ${host} = '.' ]; then
	newcount=$(ls ${path} | wc -l)
	#echo $(ls ${path} | wc -l)
    else
	newcount=$(/usr/bin/ssh -p ${port} -x -o ConnectTimeout=1
		   ${user}@${host} "ls ${path} | wc -l")
	#echo $(/usr/bin/ssh -p ${port} -x -o ConnectTimeout=1 ${user}@${host} \
	#		    "ls ${path} | wc -l")
    fi
    [ ${newcount} -gt ${count} ] && ${ap} ${nms} > /dev/null 2>&1
    count=${newcount}
    echo $count
    sleep ${interval}
done