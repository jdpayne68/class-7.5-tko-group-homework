#!/usr/bin/env bash
set -euo pipefail

#Chewbacca: Infrastructure must prove it lives.

VM_IP="${VM_IP:-}"
OUT_JSON="${OUT_JSON:-gate_result.json}"
BADGE="${BADGE:-badge.txt}"

failures=()
details=()

add_fail(){ failures+=("$1"); }
add_detail(){ details+=("$1"); }

usage() {
cat <<EOF
Usage:

VM_IP=<external_ip> ./gate_gcp_vm_http_ok.sh

Example:

VM_IP=34.27.11.92 ./gate_gcp_vm_http_ok.sh
EOF
}

if [[ -z "$VM_IP" ]]; then
  echo "ERROR: VM_IP not provided"
  usage
  exit 1
fi

BASE_URL="http://${VM_IP}"

# -------------------------------------------------
# 1) Homepage reachable
# -------------------------------------------------

code=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}" || echo "000")

if [[ "$code" == "200" ]]; then
  add_detail "PASS: Homepage reachable (HTTP 200)"
else
  add_fail "FAIL: Homepage not reachable (HTTP $code)"
fi

# -------------------------------------------------
# 2) Health endpoint
# -------------------------------------------------

health=$(curl -s "${BASE_URL}/healthz" || true)

if [[ "$health" == "ok" ]]; then
  add_detail "PASS: /healthz endpoint returned 'ok'"
else
  add_fail "FAIL: /healthz endpoint did not return 'ok'"
fi

# -------------------------------------------------
# 3) Metadata endpoint JSON
# -------------------------------------------------

meta=$(curl -s "${BASE_URL}/metadata" || true)

if echo "$meta" | jq . >/dev/null 2>&1; then
  add_detail "PASS: /metadata returned valid JSON"
else
  add_fail "FAIL: /metadata not valid JSON"
fi

# -------------------------------------------------
# 4) Metadata contains expected fields
# -------------------------------------------------

if echo "$meta" | jq -e '.instance_name' >/dev/null 2>&1; then
  add_detail "PASS: metadata contains instance_name"
else
  add_fail "FAIL: metadata missing instance_name"
fi

if echo "$meta" | jq -e '.region' >/dev/null 2>&1; then
  add_detail "PASS: metadata contains region"
else
  add_fail "FAIL: metadata missing region"
fi

# -------------------------------------------------
# Gate result
# -------------------------------------------------

status="PASS"
exit_code=0

if (( ${#failures[@]} > 0 )); then
  status="FAIL"
  exit_code=2
fi

# -------------------------------------------------
# Badge
# -------------------------------------------------

if [[ "$status" == "PASS" ]]; then
  echo "GREEN" > "$BADGE"
else
  echo "RED" > "$BADGE"
fi

# -------------------------------------------------
# JSON output
# -------------------------------------------------

details_json=$(printf '%s\n' "${details[@]}" | jq -R . | jq -s .)
failures_json=$(printf '%s\n' "${failures[@]}" | jq -R . | jq -s .)

cat > "$OUT_JSON" <<EOF
{
  "lab": "SEIR-I Lab 1",
  "target": "$VM_IP",
  "status": "$status",
  "details": $details_json,
  "failures": $failures_json
}
EOF

echo
echo "Lab 1 Gate Result: $status"
echo

printf '%s\n' "${details[@]}"

if (( ${#failures[@]} > 0 )); then
  echo
  printf '%s\n' "${failures[@]}"
fi

exit "$exit_code"
