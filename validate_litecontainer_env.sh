#!/usr/bin/env bash
set -euo pipefail

# ── CONFIGURATION ─────────────────────────────────────────────────────────────
SERVER_HOST="52.9.0.168"
SERVER_PORT=50051
SERVER_CERT="./test_certs/server-cert.pem"
KEY_FILE="${HOME}/litecontainer/liteinstance_user.pub"
REPORT_FILE="validate_report.txt"
# ── FUNCTIONS ─────────────────────────────────────────────────────────────────
log() { echo "$1"; REPORT+=("$1"); }
header() { REPORT+=("─── $1 ───"); }
# ── MAIN ─────────────────────────────────────────────────────────────────────
REPORT=()
header "LiteContainer Environment Validation Report"
REPORT+=("Date: $(date +"%Y-%m-%d %H:%M:%S")")
REPORT+=("")

# 1️⃣ Network check
header "1. Network Connectivity"
if nc -z "${SERVER_HOST}" "${SERVER_PORT}"; then
  log "✔ Able to reach ${SERVER_HOST}:${SERVER_PORT}"
else
  log "✖ Cannot reach ${SERVER_HOST}:${SERVER_PORT}"
fi
REPORT+=("")

# 2️⃣ Server certificate
header "2. Server Certificate"
if [[ -f "${SERVER_CERT}" ]]; then
  if openssl x509 -noout -in "${SERVER_CERT}" >/dev/null 2>&1; then
    log "✔ Certificate file present and valid"
  else
    log "✖ Certificate file present but NOT valid"
  fi
else
  log "✖ Certificate file NOT found at ${SERVER_CERT}"
fi
REPORT+=("")

# 3️⃣ Public key format
header "3. Public Key File"
if [[ -f "${KEY_FILE}" ]]; then
  if head -n1 "${KEY_FILE}" | grep -E '^(ssh-(rsa|dss)|ecdsa-sha2-nistp|ssh-ed25519)' >/dev/null; then
    log "✔ Public key present and header looks good"
  else
    log "⚠ Public key present but unrecognized header"
  fi
else
  log "✖ Public key file NOT found at ${KEY_FILE}"
fi
REPORT+=("")

# 4️⃣ pdm & Python import
header "4. PDM and Python Module"
if command -v pdm >/dev/null; then
  PDM_VER=$(pdm --version)
  log "✔ pdm found (${PDM_VER})"
  OUTPUT=$(pdm run python - << 'EOF'
import sys
try:
    import foundry.litecontainer.litectl
    print("✔ Python import succeeded")
except Exception as e:
    print(f"✖ Python import failed: {e}")
    sys.exit(1)
EOF
)
  log "$OUTPUT"
else
  log "✖ pdm not on PATH"
fi

# ── WRITE REPORT ────────────────────────────────────────────────────────────────
{
  for line in "${REPORT[@]}"; do
    printf "%s\n" "$line"
  done
} > "${REPORT_FILE}"

echo
echo "✅ Validation complete. See '${REPORT_FILE}' for full details."
