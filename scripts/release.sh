#!/usr/bin/env bash
#
# release.sh — cut a mac-ssi release end-to-end so `brew install` just works.
#
#   scripts/release.sh <version> <path-to-signed.dmg>
#   e.g. scripts/release.sh 0.1.0 ~/build/mac-ssi.dmg
#
# What it does:
#   1. sha256 the .dmg (+ a notarization sanity check)
#   2. create/refresh the GitHub Release on openIE-dev/mac-ssi and upload the
#      .dmg as `mac-ssi-<version>.dmg` (the name the cask expects)
#   3. bump version + sha256 in the Homebrew tap (openIE-dev/homebrew-mac-ssi)
#      and in this repo's reference Casks/mac-ssi.rb, then push
#
# After it runs:  brew install --cask openie-dev/mac-ssi/mac-ssi
#
# The engine source stays private — only the .dmg + docs are published.
set -euo pipefail

VERSION="${1:?usage: release.sh <version> <path-to-signed.dmg>}"; VERSION="${VERSION#v}"
DMG="${2:?usage: release.sh <version> <path-to-signed.dmg>}"
REPO="${SSI_REPO:-openIE-dev/mac-ssi}"
TAP="${SSI_TAP:-openIE-dev/homebrew-mac-ssi}"
GH_USER="${SSI_GH_USER:-dcharlot65-openie}"      # org-member account that can push
ASSET="mac-ssi-${VERSION}.dmg"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-].+)?$ ]] || { echo "✗ bad version '$VERSION' (use x.y.z)"; exit 1; }
[ -f "$DMG" ] || { echo "✗ DMG not found: $DMG"; exit 1; }
command -v gh >/dev/null || { echo "✗ gh CLI required (brew install gh)"; exit 1; }

say(){ printf '\n\033[1m== %s ==\033[0m\n' "$*"; }
prev_user="$(gh auth status 2>&1 | awk '/Active account: true/{print u} {u=$NF}' | tail -1 || true)"
gh auth switch --user "$GH_USER" >/dev/null 2>&1 || true
restore(){ [ -n "${prev_user:-}" ] && gh auth switch --user "$prev_user" >/dev/null 2>&1 || true; }
trap restore EXIT

say "1/3  checksum + notarization"
SHA="$(shasum -a 256 "$DMG" | awk '{print $1}')"
echo "    version  $VERSION"
echo "    sha256   $SHA"
if spctl -a -t open --context context:primary-signature "$DMG" >/dev/null 2>&1; then
  echo "    notarized: ✓"
else
  echo "    notarized: ⚠  not stapled/notarized — users will see Gatekeeper warnings."
  read -rp "    continue anyway? [y/N] " ok; [ "${ok:-}" = "y" ] || exit 1
fi

say "2/3  GitHub Release + upload .dmg  ($REPO)"
TMP="$(mktemp -d)"; cp "$DMG" "$TMP/$ASSET"
NOTES="mac-ssi v$VERSION — Single System Image for Apple Silicon.
Install: \`brew install --cask openie-dev/mac-ssi/mac-ssi\`  ·  or download \`$ASSET\` below.
Docs: https://openie-dev.github.io/mac-ssi/"
if gh release view "v$VERSION" --repo "$REPO" >/dev/null 2>&1; then
  gh release upload "v$VERSION" "$TMP/$ASSET" --repo "$REPO" --clobber
else
  gh release create "v$VERSION" "$TMP/$ASSET" --repo "$REPO" --title "mac-ssi v$VERSION" --notes "$NOTES"
fi
echo "    asset: $ASSET uploaded"

say "3/3  bump cask in tap + repo, push"
bump(){ perl -0pi -e "s/version \"[^\"]*\"/version \"$VERSION\"/; s/sha256 (\"[0-9a-f]{64}\"|:no_check)/sha256 \"$SHA\"/" "$1"; }
# tap (canonical — this is what brew installs)
TAPDIR="$(mktemp -d)"; gh repo clone "$TAP" "$TAPDIR" -- -q
( cd "$TAPDIR" && bump Casks/mac-ssi.rb \
  && git config user.name "David Charlot" && git config user.email "david@openie.dev" \
  && git commit -aqm "mac-ssi $VERSION" && git push -q ) && echo "    tap updated → $TAP"
# reference copy in this repo
if [ -f "$HERE/Casks/mac-ssi.rb" ]; then
  bump "$HERE/Casks/mac-ssi.rb"
  ( cd "$HERE" && git add Casks/mac-ssi.rb && git commit -qm "cask: mac-ssi $VERSION" 2>/dev/null && git push -q ) || true
  echo "    reference cask synced"
fi

say "DONE"
cat <<EOF
  Release:  https://github.com/$REPO/releases/tag/v$VERSION
  Install:  brew install --cask openie-dev/mac-ssi/mac-ssi
  Verify:   brew audit --cask --online openie-dev/mac-ssi/mac-ssi
EOF
