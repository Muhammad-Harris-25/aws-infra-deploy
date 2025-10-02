#!/usr/bin/env bash
set -euo pipefail

OUT="$1"   # e.g. ansible/inventory.ini

# Where terraform output is expected
TF_JSON="${WORKSPACE:-.}/terraform/tf-output.json"

if [ ! -f "$TF_JSON" ]; then
  echo "ERROR: terraform output file not found: $TF_JSON" >&2
  exit 2
fi

# Read the instance_public_ips array (jq required)
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed" >&2
  exit 3
fi

IPS=$(jq -r '.instance_public_ips.value[]? // empty' "$TF_JSON")

if [ -z "$IPS" ]; then
  echo "ERROR: No instance_public_ips found in $TF_JSON" >&2
  exit 4
fi

# Ensure destination dir exists
mkdir -p "$(dirname "$OUT")"

# Build INI inventory
# Group name used in your playbook: [web]
{
  echo "[web]"
  for ip in $IPS; do
    # default ansible_user and ansible_ssh_private_key_file are intentionally omitted;
    # your Jenkinsfile/ansible command should pass the private key and user or inventory can include it.
    echo "${ip} ansible_user=ubuntu"
  done
} > "$OUT"

echo "Inventory generated at $OUT"
exit 0
