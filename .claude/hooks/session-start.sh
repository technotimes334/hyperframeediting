#!/bin/bash
# Prepare a Claude Code cloud session for editing/rendering video with HyperFrames:
# install workspace deps, build all packages, and put the local `hyperframes` CLI on PATH.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

bun install
bun run build

# Expose the freshly built CLI as `hyperframes` for this session.
bin_dir="$CLAUDE_PROJECT_DIR/.claude/bin"
mkdir -p "$bin_dir"
cat > "$bin_dir/hyperframes" <<SHIM
#!/bin/bash
exec node "$CLAUDE_PROJECT_DIR/packages/cli/dist/cli.js" "\$@"
SHIM
chmod +x "$bin_dir/hyperframes"

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$bin_dir:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi
