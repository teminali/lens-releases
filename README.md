# Lens releases

Downloads of **Lens**, a coding agent for the terminal that runs small and local models well. Each release is one self-contained
program per platform: no Node, Bun or Python needed.

Latest release: <https://github.com/teminali/lens-releases/releases/latest>

## For installers (Deterministic Coder reads this)

`latest.json` in the latest release lists the version and, per platform, the file, its download url, size and sha256.
`latest.json.sig` is a base64 ed25519 signature of `latest.json`. The public key is `release-public-key.pem` in this repository.

```
curl -sL https://github.com/teminali/lens-releases/releases/latest/download/latest.json -o latest.json
curl -sL https://github.com/teminali/lens-releases/releases/latest/download/latest.json.sig | base64 -d > sig.bin
openssl pkeyutl -verify -pubin -inkey release-public-key.pem -rawin -in latest.json -sigfile sig.bin
```

Then check the sha256 of the downloaded archive against `latest.json` (and `SHA256SUMS.txt`). Reject anything that does not match.

Platforms: `darwin-arm64` (macOS, Apple silicon) in 0.1.0. Others are added as they are built and tried.

## License

Built from MIT-licensed code; the license is in each archive and in this repository.
