#!/bin/bash
# Install Hermes skills to ~/.hermes/skills/
set -e

SKILLS_DIR="${HERMES_HOME:-$HOME/.hermes}/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Hermes skills from $SCRIPT_DIR to $SKILLS_DIR"

mkdir -p "$SKILLS_DIR"

for skill in ghl-funnel-agent funnel-step-executor ghl-integration agentmail; do
    if [ -d "$SCRIPT_DIR/$skill" ]; then
        echo "  → $skill"
        rm -rf "$SKILLS_DIR/$skill"
        cp -r "$SCRIPT_DIR/$skill" "$SKILLS_DIR/$skill"
    fi
done

echo ""
echo "✓ Skills installed."
echo ""
echo "Make sure to set your credentials:"
echo "  export GHL_API_KEY=your_key"
echo "  export GHL_LOCATION_ID=your_location_id"
echo "  export AGENTMAIL_API_KEY=your_key"
echo ""
echo "Or add them to your profile .env file."
