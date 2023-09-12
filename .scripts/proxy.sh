#!/usr/bin/env bash


# Get proxy variable
_getproxy() {
  local host_pattern
  local network_output

  # Get host and port
  if uname -a | grep -qEi '(microsoft|wsl)' &>/dev/null; then
    host="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"
    port="7890"
  elif uname -a | grep -qEi 'arch' &>/dev/null; then
    host="127.0.0.1"
    port="20171"
  elif uname -a | grep -qEi 'Darwin' &>/dev/null; then
    network_output="$(networksetup -getwebproxy 'Wi-Fi')"

    # Check proxy status
    if echo "${network_output}" | grep "Enabled: Yes" &>/dev/null; then
      host_pattern='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'

      host="$(echo "${network_output}" | grep -oE "${host_pattern}")"
      port="$(echo "${network_output}" | grep "Port" | grep -oE '[0-9]+')"
    fi
  fi

  proxy="${host}:${port}"
}

_set_git_proxy() {
  local proxy_pattern
  local git_config_file="$HOME/.gitconfig"

  proxy_pattern='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:[0-9]\{4,5\}'
  sed -i '' "/${proxy_pattern}/d" "${git_config_file}"
  sed -i '' "/http/d" "${git_config_file}"

  echo "[http]" >> "${git_config_file}"
  echo "  proxy = http://${proxy}" >> "${git_config_file}"
}

_set_proxychains() {
  if [[ ! -d "$HOME/.proxychains" ]]; then
    mkdir "$HOME/.proxychains"
    # add default settings for v2raya archlinux
    echo "[ProxyList]" > "$HOME/.proxychains/proxychains.conf"
    echo "socks5 127.0.0.1 7890" >> "$HOME/.proxychains/proxychains.conf"
  fi

  # Set proxy for proxychains
  sed -i '' "2s/.*/socks5  ${host}  ${port}/"  "$HOME/.proxychains/proxychains.conf"
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

host=""
port=""
proxy=""
_getproxy
_set_git_proxy
_set_proxychains
