#!/usr/bin/env bash

_mac_proxy_on() {
    proxy_host="192.168.0.100"
    proxy_port="20172"
    wifi_name="Wi-Fi"

    networksetup -setwebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsecurewebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsocksfirewallproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"

    echo 'Proxy: on'
}

_mac_proxy_off() {
    # wifi_name="$(networksetup -listallhardwareports | grep Wi-Fi)"
    wifi_name="Wi-Fi"

    networksetup -setwebproxystate "${wifi_name}" off
    networksetup -setsecurewebproxystate "${wifi_name}" off
    networksetup -setsocksfirewallproxystate "${wifi_name}" off

    echo 'Proxy: off'
}

_mac_vpn_on() {
    scutil --nc start Shadowrocket
    echo 'VPN: on'
}

_mac_vpn_off() {
    scutil --nc stop Shadowrocket
    echo 'VPN: off'
}

_mac_proxy_check() {
    network_output="$(networksetup -getwebproxy 'Wi-Fi')"

    # Check proxy status
    if echo "${network_output}" | grep "Enabled: Yes" &> /dev/null; then
        echo "Proxy: on"
    else
        echo "Proxy: off"
    fi

    if scutil --nc list | grep "Connect" &> /dev/null; then
        echo "VPN: on"
    else
        echo "VPN: off"
    fi
}

# Get proxy variable
_getproxy() {
    local host_pattern
    local network_output
    local proxy_host
    local proxy_port
    local proxy

    # Get host and port
    if uname -a | grep -qEi '(microsoft|wsl)' &> /dev/null; then
        # proxy_host="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"
        proxy_host="127.0.0.1"
        proxy_port="7890"
    elif uname -a | grep -qEi 'arch' &> /dev/null; then
        proxy_host="127.0.0.1"
        proxy_port="20171"
    elif uname -a | grep -qEi 'Darwin' &> /dev/null; then
        if _mac_proxy_check | grep "Proxy: on" &> /dev/null; then
            network_output="$(networksetup -getwebproxy 'Wi-Fi')"
            host_pattern='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'

            proxy_host="$(echo "${network_output}" | grep -oE "${host_pattern}")"
            proxy_port="$(echo "${network_output}" | grep "Port" | grep -oE '[0-9]+')"
        elif _mac_proxy_check | grep "VPN: on" &> /dev/null; then
            proxy_host="127.0.0.1"
            proxy_port="1802"
        fi
    fi

    if [ -z "${proxy_host}" ] || [ -z "${proxy_port}" ]; then
        proxy=
    else
        proxy="${proxy_host}:${proxy_port}"
    fi

    echo $proxy
}

_set_git_proxy() {
    local proxy
    local proxy_pattern
    local git_config_file="$HOME/.gitconfig"

    proxy_pattern='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:[0-9]\{4,5\}'
    proxy="$1"

    if [ "$(uname -s)" = "Linux" ]; then
        sed -i "/${proxy_pattern}/d" "${git_config_file}"
        sed -i "/http/d" "${git_config_file}"
    elif [ "$(uname -s)" = "Darwin" ]; then
        sed -i "" "/${proxy_pattern}/d" "${git_config_file}"
        sed -i "" "/http/d" "${git_config_file}"
    fi

    if [ -n "${proxy}" ]; then
        echo "[http]" >> "${git_config_file}"
        echo "  proxy = http://${proxy}" >> "${git_config_file}"
    fi
}

# _set_proxychains() {
#     if [ ! -d "$HOME/.proxychains" ]; then
#         mkdir "$HOME/.proxychains"
#         # add default settings for v2raya archlinux
#         echo "[ProxyList]" > "$HOME/.proxychains/proxychains.conf"
#         echo "socks5 127.0.0.1 7890" >> "$HOME/.proxychains/proxychains.conf"
#     fi
#
#     # Set proxy for proxychains
#     if [ "$(uname -s)" = "Linux" ]; then
#         sed -i "2s/.*/socks5  ${host}  ${port}/" "$HOME/.proxychains/proxychains.conf"
#     elif [ "$(uname -s)" = "Darwin" ]; then
#         sed -i "" "2s/.*/socks5  ${host}  ${port}/" "$HOME/.proxychains/proxychains.conf"
#     fi
# }

# set global proxy
_shell_proxy_on() {
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
_shell_proxy_off() {
    unset http_proxy https_proxy ftp_proxy rsync_proxy all_proxy \
        HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY ALL_PROXY

    echo -e "Proxy environment variable removed"
    return 0
}

shellproxy() {
    if [ "$1" = "--on" ]; then
        _shell_proxy_on
    elif [ "$1" = "--off" ]; then
        _shell_proxy_off
    # elif [ "$1" = "--check" ]; then
    #     _shell_proxy_check
    else
        echo "Usage: shellproxy [--on|--off|--check]"
        return 1
    fi
}

macproxy() {
    if [ "$1" = "-v" ]; then
        _mac_vpn_on
        _mac_proxy_off

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"
    elif [ "$1" = "-p" ]; then
        _mac_vpn_off
        _mac_proxy_on

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"
    elif [ "$1" = "-c" ]; then
        _mac_proxy_check
    else
        echo "Usage: macproxy [-v|-p|-c]"
        return 1
    fi
}

proxy="$(_getproxy)"
_set_git_proxy "${proxy}"
