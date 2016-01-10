#!/bin/sh

fqdn=`hostname`
fqdn_e=`printf ${fqdn} | sed -e 's|\.|\\.|g'`
hostname=`hostname -s`
ip_file="/tmp/.ip"
ip_regex="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
remote_host="gly"

valid_ip()
{
    printf $1 | egrep -q ${ip_regex}

    return $?
}

ip=`host myip.opendns.com resolver1.opendns.com | awk '/^myip.opendns.com has address / {print $4}'`
last_known_ip=`cat ${ip_file} 2>/dev/null | egrep ${ip_regex}`

if valid_ip ${ip} && [ "${ip}" != "${last_known_ip}" ]; then
    printf "${ip}\n" > ${ip_file}
    command="sudo sed -i '' -e 's/.*${fqdn_e}/${ip}		${hostname} ${fqdn}/' /etc/hosts"
    ssh ${remote_host} ${command}
fi
