#!/bin/sh

## customize these
disk=ada0
interval=3
pool="zroot"

stump_pid=$(pgrep -a -n stumpwm)

# while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    io_info=$(iostat -c2 -w ${interval} -x ${disk} | \
		     awk 'NR%6==0 {print $4 " " $5}')
    set -- ${io_info}
    read=$(scale=3;  printf $1/1024"\n" | bc -l)
    write=$(scale=3; printf $2/1024"\n" | bc -l)
    zfs_info=$(zpool list -Hp ${pool})
    set -- $zfs_info
    # pool name used total free percent read write
    printf "%s %3.0f %3.0f %3.0f %3.0f %3.1f %3.1f\n"\
	   $1 $(( $3/1024/1024/1024 )) $(( $2/1024/1024/1024 ))\
	   $(( $4/1024/1024/1024 )) $7 ${read} ${write}
done
