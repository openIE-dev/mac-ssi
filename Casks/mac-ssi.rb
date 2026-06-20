# Homebrew Cask for mac-ssi — distributes the signed .dmg only (source is private).
#
# Install:
#   brew install --cask openie-dev/mac-ssi/mac-ssi
# (equivalently)
#   brew tap openie-dev/mac-ssi https://github.com/openIE-dev/mac-ssi
#   brew install --cask mac-ssi
#
# Maintainers: when cutting a release, update `version` + `sha256` to match the
# uploaded .dmg, or run `scripts/update-cask.sh <version>` (see repo).
cask "mac-ssi" do
  version "0.1.0"
  sha256 :no_check # replace with the .dmg sha256 on first tagged release

  url "https://github.com/openIE-dev/mac-ssi/releases/download/v#{version}/mac-ssi-#{version}.dmg",
      verified: "github.com/openIE-dev/mac-ssi/"
  name "mac-ssi"
  desc "Single System Image for Apple Silicon — pool many Macs into one compute fabric"
  homepage "https://openie-dev.github.io/mac-ssi/"

  depends_on macos: ">= :sequoia"
  depends_on arch: :arm64

  app "mac-ssi.app"
  binary "#{appdir}/mac-ssi.app/Contents/MacOS/ssi", target: "ssi"

  zap trash: [
    "~/Library/Application Support/mac-ssi",
    "~/Library/Preferences/dev.openie.mac-ssi.plist",
    "~/Library/Logs/mac-ssi",
  ]

  caveats <<~EOS
    mac-ssi pools multiple Apple Silicon Macs into one compute fabric
    over Thunderbolt 5, Ethernet, or Wi-Fi.
    Connect your Macs (TB5 fastest, or Ethernet / Wi-Fi), then run:
      ssi up        # start the node agent (auto-discovers peers)
      ssi status    # see the cluster
    Docs: https://openie-dev.github.io/mac-ssi/
  EOS
end
