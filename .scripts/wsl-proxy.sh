#!/bin/env bash

proxy="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"

# This function replace the git proxy to wsl proxy
setGitProxy() {
	pattern='s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
	sed -i "${pattern}/${proxy}/g" "$HOME/.gitconfig"
}

setProxychain() {
	sed -i "64c socks5  ${proxy}  7890" /etc/proxychains.conf
}

if [[ $UID -ne 0 ]]; then
	setGitProxy
else
	setProxychain
fi
