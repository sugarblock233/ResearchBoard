#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_APP="${1:-$ROOT_DIR/dist/ResearchBoard.app}"

cd "$ROOT_DIR"
BIN_PATH="$(swift build -c release --show-bin-path)/ResearchBoard"
mkdir -p "$OUTPUT_APP/Contents/MacOS"
cp "$BIN_PATH" "$OUTPUT_APP/Contents/MacOS/ResearchBoard"
cp "$ROOT_DIR/ResearchBoard/Resources/Info.plist" "$OUTPUT_APP/Contents/Info.plist"

# Ad-hoc signing keeps the locally assembled bundle launchable on this Mac.
codesign --force --deep --sign - "$OUTPUT_APP" >/dev/null 2>&1 || true
echo "Built $OUTPUT_APP"
