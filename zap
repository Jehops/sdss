#!/bin/sh

############################################################
#===============================================================================

fatal () {
    echo "FATAL: $*" > /dev/stderr
    exit 1
}

help () {
    readonly version=0.1

    cat <<EOF
NAME
   ${0##*/} - manage Zfs snAPshots

SYNOPSIS
   ${0##*/} TTL pool/filesystem ...
   ${0##*/} -d

DESCRIPTION
   Create snapshots of ZFS filesystems with the specified time to live
   (TTL).  TTL is of the form [0-9]{1,3}[dwm].

   -d   Delete expired snapshots.

EXAMPLES
   Create snapshots that will last for 1 day, 3 weeks, or 6 months:
      $ ${0##*/} 1d zroot/ROOT/default
      $ ${0##*/} 3w tank/backup1 zroot/usr/home
      $ ${0##*/} 6m zpool/filesystem1 zpool/filesystem2
   Delete snapshots past expiration:
      $ ${0##*/} -d

VERSION
   ${0##*/} version ${version}

EOF
    exit 0
}

ttl2s () {
    # convert string TTL like 2d, 3w, and 6m to seconds
    echo "$1" | sed -e 's/d/*86400/; s/w/*604800/; s/m/*2592000/' | bc
}

format () {
    echo "$1" | egrep -q -e "^.+@[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\.[0-9]{2}\.[0-9]{2}--[0-9]{1,3}[dwm]$"
}

create () {
    ttl="$1"
    shift
    p=$*
    date=$(date "+%Y-%m-%d_%H.%M.%S")
    for i in $p; do
        # get the value of the name and written properties for the most recent
        # snapshot created by this script and matching this dataset and ttl
        r=$(zfs list -rHo name,written -t snap -S name $i | \
                egrep -e "^.+@[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\.[0-9]{2}\.[0-9]{2}--$ttl" \
                      -m1)
        set -- $r
        if [ "$2" != "0" ]; then
	    zfs snapshot "${i}@${date}--${ttl}"
        else
            zfs rename "$1" "${i}@${date}--${ttl}"
        fi
    done
}

delete () {
    now_ts=$(date "+%s")
    for i in `zfs list -H -t snap -o name`; do
	if format $i; then
	    create_time=$(echo "$i" | \
                              sed -E -e 's/.*@//' -e 's/--[0-9]{1,3}[dwm]$//')
	    create_ts=$(date -j -f "%Y-%m-%d_%H.%M.%S" "${create_time}" "+%s")
	    ttl=$(echo $i | egrep -o -e "[0-9]{1,3}[dwm]$")
	    expire_ts=$((${create_ts} + `ttl2s $ttl`))
	    [ ${now_ts} -gt ${expire_ts} ] && zfs destroy $i
	fi
    done
}

############################################################

if echo "$1" | egrep -q -e "^[0-9]{1,3}[dwm]$" && [ $# -gt 1 ]; then
    create $*
elif [ "$1" = '-d' ]; then
    delete
else
    help
fi
