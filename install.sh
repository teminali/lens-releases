#!/bin/sh
# lens-install: installs (or updates to) the latest released Lens as `lens`. Re-run it to update.
#   sh lens-install                       installs to ~/.local/bin/lens
#   LENS_INSTALL_DIR=/some/folder sh lens-install
# It downloads latest.json and its signature from the releases repository, verifies the signature with the repository's public key,
# downloads the archive for this platform, checks its sha256 against the signed manifest, and only then puts `lens` in place.
# Published as install.sh in https://github.com/teminali/lens-releases
set -eu
REPO="${LENS_RELEASES:-teminali/lens-releases}"
DEST="${LENS_INSTALL_DIR:-$HOME/.local/bin}"
BASE="https://github.com/$REPO/releases/latest/download"
KEY="https://raw.githubusercontent.com/$REPO/main/release-public-key.pem"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) PLATFORM=darwin-arm64 ;;
  Darwin-x86_64) PLATFORM=darwin-x64 ;;
  Linux-x86_64) PLATFORM=linux-x64 ;;
  Linux-aarch64 | Linux-arm64) PLATFORM=linux-arm64 ;;
  *) echo "lens-install: no release for $(uname -s) $(uname -m)" >&2; exit 1 ;;
esac

for tool in curl openssl base64 tar shasum; do command -v "$tool" >/dev/null 2>&1 || { echo "lens-install: needs $tool" >&2; exit 1; }; done
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$BASE/latest.json" -o "$TMP/latest.json"
curl -fsSL "$BASE/latest.json.sig" | base64 -d > "$TMP/sig.bin"
curl -fsSL "$KEY" -o "$TMP/pub.pem"
openssl pkeyutl -verify -pubin -inkey "$TMP/pub.pem" -rawin -in "$TMP/latest.json" -sigfile "$TMP/sig.bin" >/dev/null 2>&1 \
  || { echo "lens-install: the signature of latest.json does not verify; nothing was installed" >&2; exit 1; }

# read one field of the manifest (python3 or jq, whichever this computer has)
field() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); a=m["assets"].get(sys.argv[2]); print(m["version"] if sys.argv[3]=="version" else (a or {}).get(sys.argv[3],""))' "$TMP/latest.json" "$PLATFORM" "$1"
  elif command -v jq >/dev/null 2>&1; then
    if [ "$1" = version ]; then jq -r .version "$TMP/latest.json"; else jq -r ".assets[\"$PLATFORM\"].$1 // empty" "$TMP/latest.json"; fi
  else
    echo "lens-install: needs python3 or jq" >&2; exit 1
  fi
}
VERSION="$(field version)"; URL="$(field url)"; SHA="$(field sha256)"
[ -n "$URL" ] || { echo "lens-install: release $VERSION has no build for $PLATFORM yet" >&2; exit 1; }

echo "installing Lens $VERSION ($PLATFORM)"
curl -fsSL "$URL" -o "$TMP/lens.tgz"
[ "$(shasum -a 256 "$TMP/lens.tgz" | cut -d' ' -f1)" = "$SHA" ] || { echo "lens-install: the download does not match the signed checksum; nothing was installed" >&2; exit 1; }
tar -xzf "$TMP/lens.tgz" -C "$TMP" lens
mkdir -p "$DEST"
mv "$TMP/lens" "$DEST/.lens.new" && chmod +x "$DEST/.lens.new" && mv "$DEST/.lens.new" "$DEST/lens"
echo "installed $DEST/lens: $("$DEST/lens" --version)"
case ":$PATH:" in *":$DEST:"*) ;; *) echo "note: $DEST is not on your PATH; add it to use \`lens\`" ;; esac
