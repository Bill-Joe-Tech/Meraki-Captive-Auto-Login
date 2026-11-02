#!/usr/bin/env bash

# ============================================
# Meraki Captive Portal Login
# Created By: B1LL J03
# ============================================

USERNAME=""
PASSWORD=""
COOKIE_JAR="cookies.txt"
USER_AGENT="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0"

mullvad disconnect
sleep 1
echo "[1/3] Getting fresh auth URL with dynamic parameters..."
REFERER_URL=$(curl -s -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -w '%{url_effective}' \
  'http://detectportal.firefox.com/success.txt' \
  -H "$USER_AGENT" \
  -o /dev/null)

echo "REFERER: $REFERER_URL"

if [ -z "$REFERER_URL" ]; then
    echo "ERROR: Failed to get URL. Are you connected to the network?"
    exit 1
fi

echo "[2/3] Submitting login credentials..."
curl -s -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -X POST \
  'https://na.network-auth.com/splash/UJqKcdKc.5.836/login' \
  -H "$USER_AGENT" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Accept-Encoding: gzip, deflate, br, zstd' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Origin: https://na.network-auth.com' \
  -H 'Sec-GPC: 1' \
  -H 'Connection: keep-alive' \
  -H "Referer: $REFERER_URL" \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'DNT: 1' \
  -H 'Priority: u=0, i' \
  --data-raw "utf8=%E2%9C%93&email=$USERNAME&password=$PASSWORD"

echo "[3/3] Verifying internet access..."
TEST_RESULT=$(curl -s -L -b "$COOKIE_JAR" \
  'http://detectportal.firefox.com/success.txt' \
  -H "$USER_AGENT" \
  -o /dev/null -w "%{http_code}")

if [ "$TEST_RESULT" = "200" ]; then
    echo "Connected to internet."
    mullvad connect
else
    echo "FAILED. HTTP Code: $TEST_RESULT"
    exit 1
fi

rm -f "$COOKIE_JAR"
