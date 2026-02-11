#!/usr/bin/env bash

MAC_WIFI_NAME="${PROXY_WIFI_NAME:-Wi-Fi}"
MAC_PROXY_HOST="${PROXY_HOST:-192.168.0.100}"
MAC_PROXY_PORT="${PROXY_PORT:-20172}"
WSL_PROXY_HOST="${WSL_PROXY_HOST:-127.0.0.1}"
WSL_PROXY_PORT="${WSL_PROXY_PORT:-7897}"
SHADOWROCKET_SERVICE="${SHADOWROCKET_SERVICE:-Shadowrocket}"
QUANTUMULT_SERVICE="${QUANTUMULT_SERVICE:-Quantumult X 2}"

_mac_proxy_on() {
    local proxy_host="${MAC_PROXY_HOST}"
    local proxy_port="${MAC_PROXY_PORT}"
    local wifi_name="${MAC_WIFI_NAME}"

    networksetup -setwebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsecurewebproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
    networksetup -setsocksfirewallproxy "${wifi_name}" "${proxy_host}" "${proxy_port}"
}

_mac_proxy_off() {
    local wifi_name="${MAC_WIFI_NAME}"

    networksetup -setwebproxystate "${wifi_name}" off
    networksetup -setsecurewebproxystate "${wifi_name}" off
    networksetup -setsocksfirewallproxystate "${wifi_name}" off
}

_mac_get_proxy_endpoint() {
    local service_output
    local enabled
    local proxy_host
    local proxy_port

    service_output="$(networksetup -getwebproxy "${MAC_WIFI_NAME}" 2> /dev/null)"
    enabled="$(echo "${service_output}" | awk -F': ' '/Enabled/ { print $2 }')"

    if [ "${enabled}" != "Yes" ]; then
        service_output="$(networksetup -getsocksfirewallproxy "${MAC_WIFI_NAME}" 2> /dev/null)"
        enabled="$(echo "${service_output}" | awk -F': ' '/Enabled/ { print $2 }')"
    fi

    if [ "${enabled}" != "Yes" ]; then
        return 1
    fi

    proxy_host="$(echo "${service_output}" | awk -F': ' '/Server/ { print $2 }')"
    proxy_port="$(echo "${service_output}" | awk -F': ' '/Port/ { print $2 }')"

    if [ -n "${proxy_host}" ] && [ -n "${proxy_port}" ]; then
        echo "${proxy_host}:${proxy_port}"
        return 0
    fi

    return 1
}

_mac_proxy_check() {
    local proxy_on
    local shadow_on
    local quant_on

    proxy_on="$(networksetup -getwebproxy "${MAC_WIFI_NAME}" | grep 'Enabled: Yes')"
    shadow_on="$(scutil --nc list | grep "Connect.*${SHADOWROCKET_SERVICE}")"
    quant_on="$(scutil --nc list | grep 'Connect.*Quantumult')"

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
    local endpoint
    local proxy_host
    local proxy_port

    # Get host and port
    if uname -a | grep -qEi '(microsoft|wsl)' &> /dev/null; then
        proxy_host="${WSL_PROXY_HOST}"
        proxy_port="${WSL_PROXY_PORT}"
    elif uname -a | grep -qEi 'Darwin' &> /dev/null; then
        if endpoint="$(_mac_get_proxy_endpoint)"; then
            proxy_host="${endpoint%:*}"
            proxy_port="${endpoint##*:}"
        fi
    fi

    if [ -z "${proxy_host}" ] || [ -z "${proxy_port}" ]; then
        echo ""
    else
        echo "${proxy_host}:${proxy_port}"
    fi
}

_set_git_proxy() {
    local proxy="$1"

    if [ -n "${proxy}" ]; then
        git config --global http.proxy "http://${proxy}"
    else
        git config --global --unset http.proxy > /dev/null 2>&1 || true
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
    local proxy="$1"

    if [ -z "${proxy}" ]; then
        echo "No active proxy endpoint detected"
        return 1
    fi

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
    local proxy

    if [ "$1" = "on" ]; then
        proxy="$(_getproxy)"
        _shell_proxy_on "${proxy}"
    elif [ "$1" = "off" ]; then
        _shell_proxy_off
    # elif [ "$1" = "--check" ]; then
    #     _shell_proxy_check
    else
        echo "Usage: shellproxy [on|off]"
        return 1
    fi
}

macproxy() {
    case "$1" in
    "--vpn=shadow")
        local proxy

        scutil --nc stop "${QUANTUMULT_SERVICE}"
        _mac_proxy_off
        scutil --nc start "${SHADOWROCKET_SERVICE}"

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"

        echo "Shadowrocket"
        ;;
    "--vpn=quant")
        local proxy

        scutil --nc stop "${SHADOWROCKET_SERVICE}"
        _mac_proxy_off
        scutil --nc start "${QUANTUMULT_SERVICE}"

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"

        echo "Quantumult X"
        ;;
    "-p" | "--proxy")
        local proxy

        scutil --nc stop "${SHADOWROCKET_SERVICE}"
        scutil --nc stop "${QUANTUMULT_SERVICE}"
        _mac_proxy_on

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"
        echo "Proxy"
        ;;
    "-n" | "--noproxy")
        local proxy

        scutil --nc stop "${SHADOWROCKET_SERVICE}"
        scutil --nc stop "${QUANTUMULT_SERVICE}"
        _mac_proxy_off

        proxy="$(_getproxy)"
        _set_git_proxy "${proxy}"

        echo "No proxy"
        ;;
    "-c" | "--check")
        _mac_proxy_check
        ;;
    *)
        echo "Usage: macproxy [--vpn=shadow|--vpn=quant|--proxy|--noproxy|--check]"
        return 1
        ;;
    esac
}
