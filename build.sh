#!/usr/bin/env bash
set -e

echo "=== Starting Flutter Web Build ==="

# Fix git dubious ownership in CI/Docker/Vercel containers
git config --global --add safe.directory '*' || true

# Ensure .env exists for Flutter assets and runtime
if [ ! -f ".env" ]; then
  echo "Generating .env file for build..."
  cat << 'EOF' > .env
SUPABASE_URL=https://nuwrxianosqkaeygnici.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51d3J4aWFub3Nxa2FleWduaWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAyNjQ3MDQsImV4cCI6MjEwNTg0MDcwNH0.1UflwBKg9_tQ1A-8sxvl8TLWYZo2zO2g5y-BsLkft40
GEMINI_API_KEY=QVEuQWI4Uk42SjRES0ZTS2pvOVNPNWh5NkhxVDNqSTAwYUJjRnJnbVl2VktaQkgyOXd6d3c=
GOOGLE_CLIENT_ID=400887731254-ipi7qcbn006uucpuehvc2ur2f18oq6c7.apps.googleusercontent.com
GOOGLE_SERVER_CLIENT_ID=400887731254-1d2b056maqqtsgloh488fg36qe0r0upv.apps.googleusercontent.com
EOF
fi

if ! command -v flutter &> /dev/null; then
  echo "Flutter not found. Downloading Flutter SDK for Linux..."
  curl -sLO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz
  tar -xf flutter_linux_3.29.0-stable.tar.xz
  rm -f flutter_linux_3.29.0-stable.tar.xz
  export PATH="$PATH:$PWD/flutter/bin"
fi

git config --global --add safe.directory '*' || true

flutter --version
flutter config --no-analytics

echo "Building Flutter Web..."
flutter build web --release --base-href "/"

echo "Copying assets and configuration..."
cp web/sql-wasm.wasm build/web/ 2>/dev/null || true
cp vercel.json build/web/ 2>/dev/null || true

echo "=== Build Complete Successfully ==="
