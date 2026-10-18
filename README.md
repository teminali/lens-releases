# Lens releases

Downloads of **Lens**, the coding agent for your terminal, from the makers of Lens Code (https://lenscode.web.app). Sign in with
`lens login`: free accounts get a daily allowance of credits, and Lens Pro and Lens Max give you more. Each release is one
self-contained program: no Node, Bun or Python needed.

Latest release: <https://github.com/teminali/lens-releases/releases/latest>

## Install

```
curl -fsSL https://raw.githubusercontent.com/teminali/lens-releases/main/install.sh | sh
```

It verifies the signature and checksum, then puts `lens` in `~/.local/bin`. Run it again to update. It needs `curl`, `openssl`,
`tar` and `shasum`, and `python3` or `jq` to read one file. The program itself needs none of them.

## For installers (Lens Code reads this)

`latest.json` in the latest release lists the version and, per platform, the file, its download url, size and sha256.
`latest.json.sig` is a base64 ed25519 signature of `latest.json`. The public key is `release-public-key.pem` in this repository.

```
curl -sL https://github.com/teminali/lens-releases/releases/latest/download/latest.json -o latest.json
curl -sL https://github.com/teminali/lens-releases/releases/latest/download/latest.json.sig | base64 -d > sig.bin
openssl pkeyutl -verify -pubin -inkey release-public-key.pem -rawin -in latest.json -sigfile sig.bin
```

Then check the sha256 of the downloaded archive against `latest.json` (and `SHA256SUMS.txt`). Reject anything that does not match.

Platforms: `darwin-arm64` (macOS, Apple silicon) only for now. Other platforms are added once they are built and tested.

## License

Built from MIT-licensed code; the license is in each archive and in this repository.
