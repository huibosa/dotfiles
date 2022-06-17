#!/usr/bin/env bash


setProxychains() {
  if [[ ! -d "$HOME/.proxychains" ]]; then
    mkdir "$HOME/.proxychains"
    # add default settings for v2raya archlinux
    echo "[ProxyList]" > "$HOME/.proxychains/proxychains.conf"
    echo "socks5 127.0.0.1 20170" >> "$HOME/.proxychains/proxychains.conf"
  fi
}


# Get proxy variable
getproxy() {
  if uname -a | grep -qEi '(microsoft|wsl)' &>/dev/null; then
    proxy="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"
    proxy+=":7890"

    local ipAddr="${proxy%:*}"
    local port="${proxy#*:}"

    # Set proxy for git
    local pattern='s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:[0-9]\{4,5\}'
    sed -i "${pattern}/${proxy}/g" "$HOME/.gitconfig"

    # Set proxy for proxychains
    sed -i "2c socks5  ${ipAddr}  ${port}"  "$HOME/.proxychains/proxychains.conf"
  elif uname -a | grep -qEi 'arch' &>/dev/null; then
    proxy="127.0.0.1"
    proxy+=":20171"
  fi
}

# set global proxy
proxy() {
	export http_proxy="${proxy}" \
         https_proxy="${proxy}" \
         ftp_proxy="${proxy}" \
         rsync_proxy="${proxy}" \
         HTTP_PROXY="${proxy}" \
         HTTPS_PROXY="${proxy}" \
         FTP_PROXY="${proxy}" \
         RSYNC_PROXY="${proxy}" \
         all_proxy="${proxy}" \
         ALL_PROXY="${proxy}"
  echo -e "Proxy environment variable set."
  return 0
}

# unset global proxy
noproxy() {
	unset http_proxy https_proxy ftp_proxy rsync_proxy all_proxy \
	      HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY ALL_PROXY
        
	echo -e "Proxy environment variable removed"
  return 0
}

proxy=""
setProxychains
getproxy
