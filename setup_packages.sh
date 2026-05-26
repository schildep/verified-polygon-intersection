#!/usr/bin/env bash
set -euo pipefail

# Clone Mathlib v4.15.0-patch1 and its dependencies for `lake build`.
#
# Lean 4.15.0 is the most recent Lean release with an official wasm32
# toolchain asset, so the WASM build (./build.sh) requires this version.
#
# By default packages are cloned into PKGDIR=$TMPDIR-style path
# (/tmp/claude/polygons_pkgs) and `.lake/packages` is symlinked to it.
# This avoids two sandbox restrictions inside the project tree:
#   - .vscode/settings.json writes are blocked
#   - .git/config writes are blocked
# Override PKGDIR if you want packages stored elsewhere.

PKGDIR_DEFAULT="/tmp/claude/polygons_pkgs"
PKGDIR="${PKGDIR:-$PKGDIR_DEFAULT}"
LAKE_PACKAGES="$(pwd)/.lake/packages"

mkdir -p "$PKGDIR"

# git clone --bare of large repos like Mathlib often hits a network RPC
# timeout. We do `init --bare` + `fetch --depth=1 origin <rev>` instead, which
# pulls only the one commit we need.
fetch_pkg() {
    local name="$1" url="$2" rev="$3"
    local dest="$PKGDIR/$name"

    if [ -d "$dest/.git" ] \
        && [ "$(git -C "$dest" rev-parse HEAD 2>/dev/null || true)" = "$rev" ]; then
        echo "  $name: already at $rev"
        return 0
    fi

    rm -rf "$dest"
    mkdir -p "$dest"
    echo "  $name: fetching $rev..."
    git -C "$dest" init --quiet
    git -C "$dest" remote add origin "$url"
    git -C "$dest" fetch --depth=1 --quiet origin "$rev"
    git -C "$dest" checkout --quiet "$rev"
    echo "  $name: OK"
}

echo "==> Setting up Mathlib v4.15.0-patch1 and dependencies in $PKGDIR ..."

# Revisions match the lake-manifest.json of Mathlib v4.15.0-patch1.
fetch_pkg "mathlib"          "https://github.com/leanprover-community/mathlib4"         "e9ae2a61ef5c99d6edac84f0d04f6324c5d97f67"
fetch_pkg "plausible"        "https://github.com/leanprover-community/plausible"        "2c57364ef83406ea86d0f78ce3e342079a2fece5"
fetch_pkg "LeanSearchClient" "https://github.com/leanprover-community/LeanSearchClient" "003ff459cdd85de551f4dcf95cdfeefe10f20531"
fetch_pkg "importGraph"      "https://github.com/leanprover-community/import-graph"     "9a0b533c2fbd6195df067630be18e11e4349051c"
fetch_pkg "proofwidgets"     "https://github.com/leanprover-community/ProofWidgets4"    "2b000e02d50394af68cfb4770a291113d94801b5"
fetch_pkg "aesop"            "https://github.com/leanprover-community/aesop"            "2689851f387bb2cef351e6825fe94a56a304ca13"
fetch_pkg "Qq"               "https://github.com/leanprover-community/quote4"           "f0c584bcb14c5adfb53079781eeea75b26ebbd32"
fetch_pkg "batteries"        "https://github.com/leanprover-community/batteries"        "e8dc5fc16c625fc4fe08f42d625523275ddbbb4b"
fetch_pkg "Cli"              "https://github.com/leanprover/lean4-cli"                  "0c8ea32a15a4f74143e4e1e107ba2c412adb90fd"

# Wire .lake/packages -> $PKGDIR (replace any prior symlink/dir).
if [ -L "$LAKE_PACKAGES" ] || [ -e "$LAKE_PACKAGES" ]; then
    rm -rf "$LAKE_PACKAGES" 2>/dev/null || rm -f "$LAKE_PACKAGES"
fi
mkdir -p "$(dirname "$LAKE_PACKAGES")"
ln -s "$PKGDIR" "$LAKE_PACKAGES"

echo "==> All packages ready. .lake/packages -> $PKGDIR"
