#!/usr/bin/env bash

_mac_proxy_check() {
    network_output="$(networksetup -getwebproxy 'Wi-Fi')"

    # Check proxy status
    if echo "${network_output}" | grep "Enabled: Yes" &> /dev/null; then
        echo "Proxy is enabled"
    else
        echo "Proxy is not enabled"
    fi
}

_mac_proxy_on() {
    proxy_host="192.168.0.100"
    proxy_port="20172"
    wifi_name="Wi-Fi"

    networksetup -setwebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsecurewebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsocksfirewallproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"

    echo 'Wi-Fi proxy turned set.'
}

_mac_proxy_off() {
    # wifi_name="$(networksetup -listallhardwareports | grep Wi-Fi)"
    wifi_name="Wi-Fi"

    networksetup -setwebproxystate "${wifi_name}" off
    networksetup -setsecurewebproxystate "${wifi_name}" off
    networksetup -setsocksfirewallproxystate "${wifi_name}" off

    echo 'Wi-Fi proxy turned off.'
}

macproxy() {
    if [ "$1" = "--on" ]; then
        _mac_proxy_on
    elif [ "$1" = "--off" ]; then
        _mac_proxy_off
    elif [ "$1" = "--check" ]; then
        _mac_proxy_check
    else
        echo "Usage: macproxy [--on|--off|--check]"
        return 1
    fi
}

_mac_vpn_on() {
    scutil --nc start Shadowrocket
    echo 'VPN has been set.'
}

_mac_vpn_off() {
    scutil --nc stop Shadowrocket
    echo 'VPN has been turned off.'
}

_mac_vpn_check() {
    if scutil --nc list | grep "Connected" &> /dev/null; then
        echo "VPN is enabled"
    else
        echo "VPN is not enabled"
    fi
}

macvpn() {
    if [ "$1" = "--on" ]; then
        _mac_vpn_on
    elif [ "$1" = "--off" ]; then
        _mac_vpn_off
    elif [ "$1" = "--check" ]; then
        _mac_vpn_check
    else
        echo "Usage: macvpn [--on|--off|--check]"
        return 1
    fi
}

# Get proxy variable
_getproxy() {
    local host_pattern
    local network_output

    # Get host and port
    if uname -a | grep -qEi '(microsoft|wsl)' &> /dev/null; then
        # host="$(grep 'nameserver' /etc/resolv.conf | cut -d ' ' -f 2)"
        host="127.0.0.1"
        port="7890"
    elif uname -a | grep -qEi 'arch' &> /dev/null; then
        host="127.0.0.1"
        port="20171"
    elif uname -a | grep -qEi 'Darwin' &> /dev/null; then
        if [ "$(_mac_proxy_check)" = "Proxy is enabled" ]; then
            network_output="$(networksetup -getwebproxy 'Wi-Fi')"
            host_pattern='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'

            host="$(echo "${network_output}" | grep -oE "${host_pattern}")"
            port="$(echo "${network_output}" | grep "Port" | grep -oE '[0-9]+')"
        elif [ "$(_mac_vpn_check)" = "VPN is enabled" ]; then
            host="127.0.0.1"
            port="1802"
        fi
    fi

    if [ -z "${host}" ] || [ -z "${port}" ]; then
        proxy=
    else
        proxy="${host}:${port}"
    fi
}

_set_git_proxy() {
    local proxy_pattern
    local git_config_file="$HOME/.gitconfig"

    proxy_pattern='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:[0-9]\{4,5\}'

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

_set_proxychains() {
    if [ ! -d "$HOME/.proxychains" ]; then
        mkdir "$HOME/.proxychains"
        # add default settings for v2raya archlinux
        echo "[ProxyList]" > "$HOME/.proxychains/proxychains.conf"
        echo "socks5 127.0.0.1 7890" >> "$HOME/.proxychains/proxychains.conf"
    fi

    # Set proxy for proxychains
    if [ "$(uname -s)" = "Linux" ]; then
        sed -i "2s/.*/socks5  ${host}  ${port}/" "$HOME/.proxychains/proxychains.conf"
    elif [ "$(uname -s)" = "Darwin" ]; then
        sed -i "" "2s/.*/socks5  ${host}  ${port}/" "$HOME/.proxychains/proxychains.conf"
    fi
}

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

host=""
port=""
proxy=""
_getproxy
_set_git_proxy
_set_proxychains
