#!/usr/bin/env bash
# Generate TypeScript gRPC stubs from all proto files.
#
# Usage (run from the consuming service root):
#   bash protos/scripts/codegen-ts.sh <out_dir>
#
# Example:
#   bash protos/scripts/codegen-ts.sh src/generated/protos
#
# Requirements (install once in the consuming service):
#   npm install --save-dev grpc-tools ts-proto
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/../proto"
OUT_DIR="${1:-src/generated/protos}"

mkdir -p "$OUT_DIR"

for proto in "$PROTO_DIR"/*.proto; do
  echo "Generating $(basename "$proto") -> $OUT_DIR/"
  npx grpc_tools_node_protoc \
    --plugin=protoc-gen-grpc="$(npx which grpc_tools_node_protoc_plugin)" \
    --ts_proto_out="$OUT_DIR" \
    --ts_proto_opt=outputServices=grpc-js \
    --ts_proto_opt=esModuleInterop=true \
    --proto_path="$PROTO_DIR" \
    "$(basename "$proto")"
done

echo "TypeScript stubs generated in $OUT_DIR/"
