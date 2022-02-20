#!/bin/env bash

proxy="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"

# This function replace the git proxy to wsl proxy
function setGitProxy {
  pattern='s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
  sed -i "${pattern}/${proxy}/g" "$HOME/.gitconfig"
}

function setProxychain() {
  sed -i "66c socks5  ${proxy}  7890" /etc/proxychains4.conf
}

# set global proxy
function proxy_on() {
  export http_proxy="${proxy}:7890"
  export https_proxy="${proxy}:7890"
  export all_proxy="${proxy}:7890"
  echo -e "Proxy set sucessfully"
}

# unset global proxy
function proxy_off() {
    unset http_proxy
    unset https_proxy
}

if [[ $UID -ne 0 ]]; then
  setGitProxy
else
  setProxychain
fi