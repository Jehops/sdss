#!/bin/sh

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
   (TTL).  TTL is of the form [0-9]{1,4}[dwmy].

   -d   Delete expired snapshots.

EXAMPLES
   Create snapshots that will last for 1 day, 3 weeks, 6 months, and 1 year:
      $ ${0##*/} 1d zroot/ROOT/default
      $ ${0##*/} 3w tank/backup1 zroot/usr/home
      $ ${0##*/} 6m zpool/filesystem1 zpool/filesystem2
      $ ${0##*/} 1y tank/backup
   Delete snapshots past expiration:
      $ ${0##*/} -d

VERSION
   ${0##*/} version ${version}

EOF
    exit 0
}

is_pint () {
    case $1 in
        ''|*[!0-9]*|0*)
            return 1;;
    esac

    return 0
}

safe () {
    # ensure the pool isn't scubbing, resilvering or in a degraded state
    echo $1 | cut -f1 -d'/' | \
        egrep -qv "scan: (resilver|scrub) in progress|state: DEGRADED"
}

ss_ts () {
    case $os in
        'Darwin'|'FreeBSD')
            date -j -f'%Y-%m-%dT%H:%M:%S%z' "$1" +%s
            ;;
        'Linux')
            date --date=$1 +%s
            ;;
    esac
}

ttl2s () {
    # convert TTL string like 2d, 3w, 6m, or 1y to seconds
    echo $1 | sed 's/d/*86400/;s/w/*604800/;s/m/*2592000/;s/y/*31536000/' | bc
}

warn () {
    echo "WARN: $*" > /dev/stderr
}

#===============================================================================

create () {
    ttl="$1"
    shift
    p=$*
    date=$(date '+%Y-%m-%dT%H:%M:%S%z')
    for i in $p; do
        if ! safe $i; then continue; fi
        # get value of name,written properties for most recent snapshot created
        # by this script and matching this dataset,ttl
        r=$(zfs list -rHo name,written -t snap -S name $i | \
                egrep "${i}${zptn}" | egrep -e "--${ttl}[[:space:]]" -m1)
        set -- $r
        if [ "$2" != "0" ]; then
	    zfs snapshot "${i}@ZAP_${date}--${ttl}"
        else
            zfs rename "$1" "${i}@ZAP_${date}--${ttl}"
        fi
    done
}

delete () {
    now_ts=$(date '+%s')
    for i in `zfs list -H -t snap -o name`; do
        if ! safe $i; then continue; fi
	if $(echo $i | egrep -q -e $zptn); then
	    create_time=$(echo $i | \
                              sed -r 's/^.+@ZAP_//;s/--[0-9]{1,4}[dwmy]$//')
            create_ts=$(ss_ts ${create_time})
	    ttls=$(ttl2s $(echo $i | egrep -o '[0-9]{1,4}[dwmy]$'))
            if ! is_pint $create_ts || ! is_pint $ttls; then
                warn "Skipping $i. Could not determine its expiration time."
            else
	        expire_ts=$(($create_ts + $ttls))
	        [ ${now_ts} -gt ${expire_ts} ] && zfs destroy $i
            fi
	fi
    done
}

#===============================================================================

# egrep pattern matching zap snapshot names
zptn='@ZAP_.+--[0-9]{1,4}[dwmy]'

os=$(uname)
case $os in
    'Darwin'|'FreeBSD'|'Linux')
    ;;
    *)
        fatal "${0##*/} has not be tested on $os.
       Feedback and patches are welcome."
        ;;
esac

if echo "$1" | egrep -q -e "^[0-9]{1,4}[dwmy]$" && [ $# -gt 1 ]; then
    create $*
elif [ "$1" = '-d' ]; then
    delete
else
    help
fi
