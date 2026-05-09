#!/usr/bin/env bash
# Generate C++ gRPC stubs from all proto files.
#
# Usage (run from the consuming service root, or from CMake):
#   bash protos/scripts/codegen-cpp.sh <out_dir>
#
# Example:
#   bash protos/scripts/codegen-cpp.sh build/generated/protos
#
# Requirements:
#   protoc + grpc_cpp_plugin installed (e.g. via apt/brew or CMake FetchContent gRPC)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/../proto"
OUT_DIR="${1:-build/generated/protos}"

# Detect grpc_cpp_plugin location
GRPC_CPP_PLUGIN="${GRPC_CPP_PLUGIN:-$(which grpc_cpp_plugin 2>/dev/null || true)}"
if [ -z "$GRPC_CPP_PLUGIN" ]; then
  echo "ERROR: grpc_cpp_plugin not found. Install gRPC dev tools or set GRPC_CPP_PLUGIN env var." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

for proto in "$PROTO_DIR"/*.proto; do
  echo "Generating $(basename "$proto") -> $OUT_DIR/"
  protoc \
    --proto_path="$PROTO_DIR" \
    --cpp_out="$OUT_DIR" \
    --grpc_out="$OUT_DIR" \
    --plugin=protoc-gen-grpc="$GRPC_CPP_PLUGIN" \
    "$(basename "$proto")"
done

echo "C++ stubs generated in $OUT_DIR/"
