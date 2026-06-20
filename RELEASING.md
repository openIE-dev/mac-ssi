# Releasing mac-ssi

The engine source is private; the public artifact is a **signed, notarized
`.dmg`**. One script wires the DMG into a GitHub Release and the Homebrew tap so
`brew install --cask openie-dev/mac-ssi/mac-ssi` works end-to-end.

## Repos involved

| Repo | Role |
|---|---|
| `openIE-dev/mac-ssi-private` | engine source (private) — builds the `.dmg` |
| `openIE-dev/mac-ssi` | this repo — site, docs, examples, **hosts the `.dmg` in Releases** |
| `openIE-dev/homebrew-mac-ssi` | Homebrew **tap** — the cask `brew` installs |

## One-time setup (already done)

- Public site + repo: `openIE-dev/mac-ssi` (GitHub Pages on `/docs`)
- Tap: `openIE-dev/homebrew-mac-ssi` with `Casks/mac-ssi.rb`
- `gh` authenticated as an `openIE-dev` org member

## Cut a release

```sh
# 1. Build + sign + notarize the app from the PRIVATE repo, then make a .dmg:
#    (in mac-ssi-private)
#    cargo build --release
#    # bundle mac-ssi.app, then:
#    codesign --deep --options runtime --sign "Developer ID Application: …" mac-ssi.app
#    hdiutil create -volname mac-ssi -srcfolder mac-ssi.app -ov -format UDZO mac-ssi.dmg
#    xcrun notarytool submit mac-ssi.dmg --apple-id "$APPLE_ID" --password "$APPLE_APP_PASSWORD" --team-id "$TEAM" --wait
#    xcrun stapler staple mac-ssi.dmg

# 2. Publish it everywhere with one command (from this repo):
scripts/release.sh 0.1.0 ~/build/mac-ssi.dmg
```

`release.sh` will:
1. `sha256` the `.dmg` and sanity-check notarization (`spctl`)
2. create GitHub Release `v0.1.0` on `openIE-dev/mac-ssi` and upload `mac-ssi-0.1.0.dmg`
3. bump `version` + `sha256` in the tap's `Casks/mac-ssi.rb` (and this repo's reference copy), commit & push

## Verify

```sh
brew untap openie-dev/mac-ssi 2>/dev/null; brew install --cask openie-dev/mac-ssi/mac-ssi
brew audit --cask --online openie-dev/mac-ssi/mac-ssi   # cask sanity
ssi status                                              # it runs
```

## Notes

- **DMG only.** Never push engine source to the public repos.
- The `url` in the cask resolves to
  `…/mac-ssi/releases/download/v<version>/mac-ssi-<version>.dmg` — the script
  uploads the asset under exactly that name.
- Bugfix release? Bump the patch version and re-run `release.sh`. Homebrew users
  get it on `brew upgrade`.
- The first real tag replaces the placeholder `version "0.0.0"` / dummy `sha256`
  in the tap automatically.
