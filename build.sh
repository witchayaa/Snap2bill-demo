#!/usr/bin/env bash
set -e

echo "=== Starting Flutter Web Build ==="

if ! command -v flutter &> /dev/null; then
  echo "Flutter not found. Downloading Flutter SDK for Linux..."
  curl -sLO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz
  tar -xf flutter_linux_3.29.0-stable.tar.xz
  export PATH="$PATH:$PWD/flutter/bin"
fi

flutter --version
flutter config --no-analytics

echo "Building Flutter Web..."
flutter build web --release --base-href "/"

echo "Copying assets and configuration..."
cp web/sql-wasm.wasm build/web/ 2>/dev/null || true
cp vercel.json build/web/ 2>/dev/null || true

echo "=== Build Complete Successfully ==="
