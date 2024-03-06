#!/usr/bin/env bash

_mac_proxy_on() {
    proxy_host="192.168.0.100"
    proxy_port="20172"
    wifi_name="Wi-Fi"

    networksetup -setwebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsecurewebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsocksfirewallproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
}

_mac_proxy_off() {
    # wifi_name="$(networksetup -listallhardwareports | grep Wi-Fi)"
    wifi_name="Wi-Fi"

    networksetup -setwebproxystate "${wifi_name}" off
    networksetup -setsecurewebproxystate "${wifi_name}" off
    networksetup -setsocksfirewallproxystate "${wifi_name}" off
}

_mac_proxy_check() {
    proxy_on="$(networksetup -getwebproxy 'Wi-Fi' | grep 'Enabled: Yes')"
    shadow_on="$(scutil --nc list | grep "Connect.*Shadowrocket")"
    quant_on="$(scutil --nc list | grep "Connect.*Quantumult")"

    if [ -n "${quant_on}" ]; then
        echo "Quantumult X"
    fi

    if [ -n "${shadow_on}" ]; then
        echo "Shadowrocket"
    fi

    if [ -n "${proxy_on}" ]; then
        echo "Proxy"
    fi

    if [ -z "${proxy_on}" ] && [ -z "${quant_on}" ] && [ -z "${shadow_on}" ]; then
        echo "No proxy"
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
            proxy_port="1082"
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
    case "$1" in
    "--vpn=shadow")
        scutil --nc stop 'Quantumult X'
        _mac_proxy_off
        scutil --nc start Shadowrocket

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"

        echo "Shadowrocket"
        ;;
    "--vpn=quant")
        scutil --nc stop Shadowrocket
        _mac_proxy_off
        scutil --nc start 'Quantumult X'

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"

        echo "Quantumult X"
        ;;
    "-p" | "--proxy")
        scutil --nc stop Shadowrocket
        scutil --nc stop 'Quantumult X'
        _mac_proxy_on

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"
        echo "Proxy"
        ;;
    "-n" | "--noproxy")
        scutil --nc stop Shadowrocket
        scutil --nc stop 'Quantumult X'
        _mac_proxy_off

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"

        echo "No proxy"
        ;;
    "-c" | "--check")
        _mac_proxy_check
        ;;
    *)
        echo "Usage: macproxy [-p|-q|-s|-c-n]"
        return 1
        ;;
    esac
}

proxy="$(_getproxy)"
_set_git_proxy "${proxy}"
