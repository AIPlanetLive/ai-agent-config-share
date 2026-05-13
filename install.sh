#!/usr/bin/env bash
# install.sh — symlink shared commands/references into user-scope dirs,
# and print manual-merge instructions for top-level config files.
#
# Auto-symlinked (safe to share verbatim):
#   <repo>/claude/commands/custom/*.md → ~/.claude/commands/custom/*.md
#   <repo>/claude/references/*.md      → ~/.claude/references/*.md
#
# Manual merge required (you likely already have your own version of
# these and a hard symlink would overwrite your customizations):
#   <repo>/claude/CLAUDE.md → merge into ~/.claude/CLAUDE.md
#   <repo>/codex/AGENTS.md  → merge into ~/.codex/AGENTS.md
#
# Symlink policy: if a target path already exists (file, dir, or symlink
# pointing elsewhere), prompt the user whether to overwrite it. In a
# non-interactive shell the prompt defaults to skip (preserve existing).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="$SCRIPT_DIR/claude"
DST_ROOT="$HOME/.claude"

if [ ! -d "$SRC_ROOT" ]; then
    echo "ERROR: source dir not found: $SRC_ROOT" >&2
    exit 1
fi

installed=0
overwritten=0
skipped=0
already_linked=0

prompt_overwrite() {
    # Ask the user whether to replace an existing target with our symlink.
    # Returns 0 (yes) or 1 (no / no tty). Silent — caller prints messaging.
    #
    # Reads from /dev/tty directly because the caller runs inside a
    # `while read; done < <(find ...)` loop, where stdin is the find pipe,
    # not the terminal. /dev/tty bypasses that.
    if [ ! -e /dev/tty ] || [ ! -r /dev/tty ]; then
        return 1
    fi

    local dst="$1"
    local detail="$2"
    {
        echo "  [CONFLICT] $dst already exists ($detail)"
        printf "  Replace with symlink to share version? [y/N] "
    } >/dev/tty
    local answer=""
    read -r answer </dev/tty
    case "$answer" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

link_one() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "  [SKIP — source missing] $src"
        skipped=$((skipped + 1))
        return
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        local current
        current="$(readlink "$dst")"
        if [ "$current" = "$src" ]; then
            echo "  [already linked] $dst"
            already_linked=$((already_linked + 1))
            return
        fi
        if prompt_overwrite "$dst" "symlink -> $current"; then
            rm "$dst"
            ln -s "$src" "$dst"
            echo "  [overwritten] $dst"
            overwritten=$((overwritten + 1))
        else
            echo "  [SKIP — kept existing symlink] $dst -> $current"
            skipped=$((skipped + 1))
        fi
        return
    fi

    if [ -e "$dst" ]; then
        if prompt_overwrite "$dst" "regular file"; then
            rm "$dst"
            ln -s "$src" "$dst"
            echo "  [overwritten] $dst"
            overwritten=$((overwritten + 1))
        else
            echo "  [SKIP — kept existing file] $dst"
            skipped=$((skipped + 1))
        fi
        return
    fi

    ln -s "$src" "$dst"
    echo "  [linked] $dst"
    installed=$((installed + 1))
}

link_tree() {
    local subdir="$1"
    local src_dir="$SRC_ROOT/$subdir"
    local dst_dir="$DST_ROOT/$subdir"

    if [ ! -d "$src_dir" ]; then
        echo "WARN: source subdir missing: $src_dir" >&2
        return
    fi

    echo
    echo "Installing $subdir:"
    while IFS= read -r -d '' src_file; do
        local rel="${src_file#"$src_dir"/}"
        link_one "$src_file" "$dst_dir/$rel"
    done < <(find "$src_dir" -type f -name '*.md' -print0)
}

echo "ai-agent-config-share installer"
echo "  source: $SRC_ROOT"
echo "  target: $DST_ROOT"

link_tree "commands/custom"
link_tree "references"

echo
echo "Symlink install done. installed=$installed  overwritten=$overwritten  already_linked=$already_linked  skipped=$skipped"

if [ "$skipped" -gt 0 ]; then
    echo
    echo "Some targets were left as-is. Re-run this script and choose 'y' at"
    echo "the prompt if you want to overwrite them with the share version."
fi

# ---------------------------------------------------------------
# Manual step: merge top-level config files
# ---------------------------------------------------------------
# CLAUDE.md and AGENTS.md are NOT auto-symlinked because you likely
# already have your own versions and overwriting them would erase
# your customizations. Print clear instructions for two manual paths:
# (A) copy/paste yourself, or (B) hand a prompt to Claude Code.

CLAUDE_MD_SRC="$SCRIPT_DIR/claude/CLAUDE.md"
AGENTS_MD_SRC="$SCRIPT_DIR/codex/AGENTS.md"

cat <<EOF

================================================================
One more step: merge top-level config via Claude Code
================================================================

CLAUDE.md and AGENTS.md were NOT auto-symlinked — that would
overwrite your existing customizations. Paste the prompt below into
Claude Code (in any directory) to merge them safely:

----- COPY FROM HERE -----
Please merge two source files into my user-scope Claude Code and
Codex config WITHOUT overwriting my existing customizations.

Sources:
  $CLAUDE_MD_SRC  -> ~/.claude/CLAUDE.md
  $AGENTS_MD_SRC   -> ~/.codex/AGENTS.md

Steps:
1. Read both source files and both target files. If a target file
   does not exist, create it with the source content and stop.
2. For each source, identify top-level / sub-section headings
   present in the source but absent in the target. Append those
   sections to the target under their original headings, preserving
   the source's formatting and any reference paths
   (e.g., '~/.claude/references/...').
3. If a source heading already exists in the target with different
   content, do NOT overwrite. Stop and show me the diff for that
   section, then ask whether to keep mine, replace with source, or
   merge.
4. When done, print a summary: which sections were appended to which
   file, and which sections (if any) were flagged for my review.
----- COPY UNTIL HERE -----

EOF
