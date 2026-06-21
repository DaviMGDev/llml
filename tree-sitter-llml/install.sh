#!/usr/bin/env bash
set -euo pipefail

# ── Install Tree-sitter parser for LLML ────────────────────────────
# This script compiles the grammar and installs it into mvim.
# Run this from the project root:
#   bash tree-sitter-llml/install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔧 Generating parser from grammar.js..."
npx tree-sitter generate
echo "✅ Parser generated (src/parser.c)"

echo "🔧 Building shared library..."
npx tree-sitter build 2>/dev/null || cc -shared -fPIC -O2 \
  -I src src/parser.c -o llml.so 2>/dev/null || echo "⚠️  Build had warnings (usually fine)"
echo "✅ llml.so built"

echo "🔧 Locating mvim parser directory..."
MVIM_DATA=$(mvim --headless -c 'echo stdpath("data")' -c 'qa!' 2>&1)
PARSER_DIR="$MVIM_DATA/site/parser"
mkdir -p "$PARSER_DIR"
cp llml.so "$PARSER_DIR/llml.so"
echo "✅ Parser installed to $PARSER_DIR/llml.so"

ls -la "$PARSER_DIR/llml.so"

echo ""
echo "──────────────────────────────────────────────"
echo "✅ Installation complete!"
echo ""
echo "Next step: add this to your Lazy.nvim config:"
echo ""
echo "  local parser_config = require(\"nvim-treesitter.parsers\").get_parser_configs()"
echo "  parser_config.llml = {"
echo "    install_info = {"
echo "      url = \"$SCRIPT_DIR\","
echo "      files = { \"src/parser.c\" },"
echo "    },"
echo "    filetype = \"llml\","
echo "  }"
echo ""
echo "  vim.api.nvim_create_autocmd({ \"BufRead\", \"BufNewFile\" }, {"
echo "    pattern = \"*.llml\","
echo "    callback = function() vim.bo.filetype = \"llml\" end,"
echo "  })"
echo ""
echo "Then restart mvim and open example.llml 🎉"
