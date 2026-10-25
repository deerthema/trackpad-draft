#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/trackpad-color-tests.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT

# Compile the real canvas and views, without launching the menu-bar app or hotkey.
xcrun --sdk macosx swiftc -parse-as-library -swift-version 5 \
    -default-isolation MainActor -target "$(uname -m)-apple-macos15.7" \
    'Trackpad Draft/CanvasEngine.swift' \
    'Trackpad Draft/PenColor.swift' \
    'Trackpad Draft/PenColorPicker.swift' \
    'Trackpad Draft/Localization.swift' \
    'Trackpad Draft/DraftWindowManager.swift' \
    'Trackpad Draft/DraftView.swift' \
    'Trackpad Draft/DrawingToolbar.swift' \
    'Trackpad Draft/TouchCanvasView.swift' \
    Tests/CanvasEngineColorTests.swift -o "$test_dir/tests"
"$test_dir/tests"
