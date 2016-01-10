#!/bin/sh

interval=3 # customize this
mem_tot=$(awk '/real memory/ {print $4;exit}' /var/run/dmesg.boot)
mem_tot=$(( ${mem_tot}/1024/1024 ))
stump_pid=$(pgrep -a -n stumpwm)

# while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    mem_info=$(/sbin/sysctl -n \
			    hw.pagesize \
			    vm.stats.vm.v_inactive_count \
			    vm.stats.vm.v_free_count vm.stats.vm.v_cache_count)
    set -- $mem_info;
    printf "%3.1f\n" $(echo "scale=3;
(${mem_tot}-($2+$3+$4)*$1/1024/1024)/${mem_tot}*100" | bc -l)
    sleep ${interval}
done
