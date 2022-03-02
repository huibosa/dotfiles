#!/usr/bin/env bash

proxy=""

get_proxy() {
	if uname -a | grep -qEi '(microsoft|wsl)' &>/dev/null; then
		proxy="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"
		proxy+=":7890"
	elif uname -a | grep -qEi 'arch' &>/dev/null; then
		proxy="127.0.0.1"
		proxy+=":20171"
	fi
}

# set global proxy
proxy_on() {
	get_proxy
	export http_proxy="${proxy}"
	export https_proxy="${proxy}"
	export all_proxy="${proxy}"
	echo -e "Proxy set sucessfully"
}

# unset global proxy
proxy_off() {
	unset http_proxy
	unset https_proxy
	echo -e "Unset all proxy"
}
