#!/bin/bash
# IP detection module - multiple methods to detect all public IPs

# add unique IP to all_ips array
_add_ip() {
    local addr=$1
    [[ -z $addr || $addr == "null" ]] && return
    # skip private/reserved ranges
    [[ $addr =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|100\.(6[4-9]|[7-9][0-9]|1[0-1][0-9]|12[0-7])\.|127\.|169\.254\.) ]] && return
    for existing in "${all_ips[@]}"; do [[ $existing == "$addr" ]] && return; done
    all_ips+=("$addr")
}

# Method 1: local network interfaces
_detect_iface_ipv4() {
    local addrs=$(ip -4 addr show scope global 2>/dev/null | grep -oP 'inet \K[\d.]+')
    for addr in $addrs; do _add_ip "$addr"; done
}

_detect_iface_ipv6() {
    local addrs=$(ip -6 addr show scope global 2>/dev/null | grep -oP 'inet6 \K[^/]+')
    for addr in $addrs; do
        [[ $addr =~ ^fe80: ]] && continue
        _add_ip "$addr"
    done
}

# Method 2: cloud metadata APIs
_detect_cloud_meta() {
    type -P curl &>/dev/null || return
    # Huawei Cloud / OpenStack
    local net_json=$(curl -sLm3 http://169.254.169.254/openstack/latest/network_data.json 2>/dev/null)
    if [[ $net_json == *"public_ipv4"* ]]; then
        local meta_ips=$(echo "$net_json" | grep -oP '"public_ipv4"\s*:\s*"\K[^"]+')
        for addr in $meta_ips; do _add_ip "$addr"; done
        return
    fi
    # AWS / generic
    local aws_ip=$(curl -sLm3 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
    [[ $aws_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && _add_ip "$aws_ip"
    # Tencent Cloud
    local tx_ip=$(curl -sLm3 http://metadata.tencentyun.com/latest/meta-data/public-ipv4 2>/dev/null)
    [[ $tx_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && _add_ip "$tx_ip"
    # Alibaba Cloud
    local ali_ip=$(curl -sLm3 http://100.100.100.200/latest/meta-data/eipv4 2>/dev/null)
    [[ $ali_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && _add_ip "$ali_ip"
}

# Method 3: external HTTP/HTTPS services via curl
_detect_curl_external() {
    type -P curl &>/dev/null || return
    [[ -z $ip ]] && ip=$(curl -4 -sLm5 https://one.one.one.one/cdn-cgi/trace 2>/dev/null | grep -oP 'ip=\K.*')
    [[ -z $ip ]] && ip=$(curl -4 -sLm5 https://ifconfig.me 2>/dev/null)
    [[ -z $ip ]] && ip=$(curl -4 -sLm5 https://api.ipify.org 2>/dev/null)
    [[ -z $ip ]] && ip=$(curl -4 -sLm5 http://ifconfig.me 2>/dev/null)
    [[ -z $ip ]] && ip=$(curl -4 -sLm5 http://ip.sb 2>/dev/null)
    [[ -z $ip ]] && ip=$(curl -4 -sLm5 http://checkip.amazonaws.com 2>/dev/null)
    [[ $ip ]] && _add_ip "$ip"
    # try IPv6
    local ipv6=$(curl -6 -sLm5 https://ifconfig.me 2>/dev/null)
    [[ $ipv6 ]] && _add_ip "$ipv6"
}

# Method 4: external services via wget
_detect_wget_external() {
    [[ $ip ]] && return
    ip=$(wget -T5 -t1 -4 -qO- http://ifconfig.me 2>/dev/null)
    [[ -z $ip ]] && ip=$(wget -T5 -t1 -4 -qO- http://ip.sb 2>/dev/null)
    [[ -z $ip ]] && ip=$(wget -T5 -t1 -4 -qO- http://checkip.amazonaws.com 2>/dev/null)
    [[ $ip ]] && _add_ip "$ip"
}

# Method 5: extra IPs from -i parameter
_detect_extra_ips() {
    [[ -z $extra_ips ]] && return
    IFS=',' read -ra ips_arr <<< "$extra_ips"
    for addr in "${ips_arr[@]}"; do
        _add_ip "$(echo "$addr" | tr -d ' ')"
    done
}

# Main: get primary IP
get_ip() {
    msg warn "获取服务器公网 IP..."
    all_ips=()
    _detect_iface_ipv4
    _detect_cloud_meta
    [[ ${#all_ips[@]} -gt 0 ]] && ip="${all_ips[0]}"
    [[ -z $ip ]] && { _detect_curl_external; }
    [[ -z $ip ]] && { _detect_wget_external; }
}

# Main: get all public IPs
get_all_ips() {
    [[ ${#all_ips[@]} -eq 0 ]] && all_ips=()
    [[ $ip ]] && _add_ip "$ip"
    _detect_iface_ipv4
    _detect_iface_ipv6
    _detect_cloud_meta
    _detect_curl_external
    _detect_extra_ips
    [[ ${#all_ips[@]} -eq 0 ]] && all_ips=("$ip")
}
