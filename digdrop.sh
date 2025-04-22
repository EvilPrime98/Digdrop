#!/bin/bash

declare opt_f=0 opt_c=0
declare val_opt_f opt_c
declare domain server iterations ips

uso() {
	echo "digdrop [ -f fichero ] [ -c iteraciones ] url ..."
}

while getopts :f:c: option; do
    case $option in
        f) opt_f=1 
           val_opt_f=$OPTARG;;
        c) opt_c=1
           val_opt_c=$OPTARG;;
        \?) echo "opcion no valida"; uso ;;
    esac
done

shift $((OPTIND -1))

if [ $opt_c -eq 1 ];then
	if echo "$val_opt_c" | grep -E '^[0-9]+$' &>/dev/null; then	
		iterations=$val_opt_c
	else
		echo "Error: Número de iteraciones No Válido."
		uso
		exit 1
	fi
else
	iterations=20
fi

if [ "$#" -eq 0 ]; then
	echo "Error: Se debe añadir al menos un dominio."
	uso
	exit 2
fi

domain="$1"
ips=""
server="8.8.8.8"

for ((i=0; i<$iterations; i++)); do
	ip=$(dig $domain @$server | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
	ips="$ips $ip" 
done

ips=$(echo "$ips" | tr ' ' '\n' | grep -v '8.8.8.8' | tail -n +2 | sort | uniq)

if [ $opt_f -eq 1 ];then
    for ip in $ips; do
        echo "iptables -A OUTPUT -d $ip -j DROP " >> "$val_opt_f"
    done
else
	echo -e "$ips"
fi
