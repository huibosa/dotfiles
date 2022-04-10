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
	export http_proxy="${proxy}" \
         https_proxy="${proxy}" \
         ftp_proxy="${proxy}" \
         rsync_proxy="${proxy}" \
         HTTP_PROXY="${proxy}" \
         HTTPS_PROXy="${proxy}" \
         FTP_PROXY="${proxy}" \
         RSYNC_PROXy="${proxy}" \
         all_proxy="${proxy}" \
         ALL_PROXY="${proxy}"
  echo -e "Proxy environment variable set."
  return 0
}

# unset global proxy
proxy_off() {
	unset http_proxy https_proxy ftp_proxy rsync_proxy all_proxy \
	      HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY ALL_PROXY
        
	echo -e "Proxy environment variable removed"
}
