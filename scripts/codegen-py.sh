#!/usr/bin/env bash
# Generate Python gRPC stubs from all proto files.
#
# Usage (run from the consuming service root):
#   bash protos/scripts/codegen-py.sh <out_dir>
#
# Example:
#   bash protos/scripts/codegen-py.sh src/protos
#
# Requirements:
#   pip install grpcio-tools
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/../proto"
OUT_DIR="${1:-src/protos}"

mkdir -p "$OUT_DIR"

for proto in "$PROTO_DIR"/*.proto; do
  echo "Generating $(basename "$proto") -> $OUT_DIR/"
  python -m grpc_tools.protoc \
    --proto_path="$PROTO_DIR" \
    --python_out="$OUT_DIR" \
    --grpc_python_out="$OUT_DIR" \
    "$(basename "$proto")"
done

echo "Python stubs generated in $OUT_DIR/"
