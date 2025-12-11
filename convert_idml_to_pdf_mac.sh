#!/bin/bash
# macOS: Convert IDML to PDF using InDesign
# Usage: ./convert_idml_to_pdf_mac.sh file.idml [output.pdf]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLESCRIPT="$SCRIPT_DIR/convert_idml_to_pdf.applescript"

# Validate arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <input.idml> [output.pdf]"
    echo ""
    echo "Examples:"
    echo "  $0 document.idml"
    echo "  $0 document.idml output.pdf"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Convert to absolute paths
if [[ "$INPUT_FILE" != /* ]]; then
    INPUT_FILE="$(cd "$(dirname "$INPUT_FILE")" && pwd)/$(basename "$INPUT_FILE")"
fi

if [ -n "$OUTPUT_FILE" ] && [[ "$OUTPUT_FILE" != /* ]]; then
    OUTPUT_FILE="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"
fi

# Validate files
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: Input file not found: $INPUT_FILE"
    exit 1
fi

if [ ! -f "$APPLESCRIPT" ]; then
    echo "ERROR: AppleScript not found: $APPLESCRIPT"
    exit 1
fi

# Run conversion
if [ -n "$OUTPUT_FILE" ]; then
    osascript "$APPLESCRIPT" "$INPUT_FILE" "$OUTPUT_FILE"
else
    osascript "$APPLESCRIPT" "$INPUT_FILE"
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Success!"
else
    echo "✗ Failed. Check errors above."
    exit $EXIT_CODE
fi

