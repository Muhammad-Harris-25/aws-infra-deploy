#!/usr/bin/env bash
set -euo pipefail

TF_DIR="${1:-terraform}"
OUT="${2:-inventory.ini}"

# Prefer pre-generated tf-output.json in workspace root (Jenkins writes this)
if [ -f "${WORKSPACE:-.}/tf-output.json" ]; then
  TFJSON="${WORKSPACE:-.}/tf-output.json"
else
  (cd "$TF_DIR" && terraform output -json) > /tmp/tf-output.json
  TFJSON=/tmp/tf-output.json
fi

KEY="instance_public_ips"

# Parse IPs
IPS=$(jq -r --arg k "$KEY" '.[$k].value[]? // empty' "$TFJSON" || true)

if [ -z "$IPS" ]; then
  echo "ERROR: No IPs found under key '$KEY' in $TFJSON"
  echo "Contents of $TFJSON:"
  sed -n '1,200p' "$TFJSON" || true
  exit 2
fi

cat > "$OUT" <<EOF
[web]
EOF

for ip in $IPS; do
  # change ansible_user if using ubuntu AMI
  echo "${ip} ansible_user=ubuntu" >> "$OUT"
done

echo "Inventory generated at $OUT"
