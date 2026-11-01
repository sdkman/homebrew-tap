class SdkmanCli < Formula
  desc "SDKMAN! the Software Development Kit Manager"
  homepage "https://sdkman.io"
  url "https://github.com/sdkman/sdkman-cli/releases/download/5.24.0/sdkman-cli-5.24.0.zip"
  sha256 "b765ef213c7b3dd731815e42f398b6e2eef1053b38d32ecc09a9f6d51c8ee948"
  license "Apache-2.0"

  resource "sdkman_cli_native" do
    on_macos do
      on_arm do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.8.0/sdkman-cli-native-0.8.0-aarch64-apple-darwin.zip"
        sha256 "00c89bc5297b467510be1986ccfac8cd3347de3218ca82ae323a6203c0ce739e"
      end
      on_intel do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.8.0/sdkman-cli-native-0.8.0-x86_64-apple-darwin.zip"
        sha256 "3a7b03d2968e10a5d2a8831d6d6e521b5f57ce1c665db14c88159fdd21b93110"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.8.0/sdkman-cli-native-0.8.0-aarch64-unknown-linux-gnu.zip"
        sha256 "f1edd9b2d63908a9dd9079d6ed971da8a32ed6ce046a7216720beff507b25754"
      end
      on_intel do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.8.0/sdkman-cli-native-0.8.0-x86_64-unknown-linux-gnu.zip"
        sha256 "91cc56bce077fb605172d6bb3182ab2a1b1711d64f12a8bbb1910dc11d561397"
      end
    end
  end

  def install
    libexec.install Dir["*"]

    %w[tmp ext etc var candidates].each { |dir| mkdir libexec/dir }

    system "curl", "-s", "https://api.sdkman.io/2/candidates/all", "-o", libexec/"var/candidates"

    (libexec/"etc/config").write <<~EOS
      sdkman_auto_answer=false
      sdkman_auto_complete=true
      sdkman_auto_env=false
      sdkman_beta_channel=false
      sdkman_colour_enable=true
      sdkman_curl_connect_timeout=7
      sdkman_curl_max_time=10
      sdkman_debug_mode=false
      sdkman_insecure_ssl=false
      sdkman_rosetta2_compatible=false
      sdkman_selfupdate_feature=false
      sdkman_native_enable=true
    EOS

    (libexec/"var/version").write version
    (libexec/"var/version_native").write resource("sdkman_cli_native").version

    (libexec/"var/platform").write "darwinarm64" if OS.mac? && Hardware::CPU.arm?
    (libexec/"var/platform").write "darwinx64" if OS.mac? && Hardware::CPU.intel?
    (libexec/"var/platform").write "linuxarm64" if OS.linux? && Hardware::CPU.arm?
    (libexec/"var/platform").write "linuxx64" if OS.linux? && Hardware::CPU.intel?

    libexec.install resource("sdkman_cli_native") 
  end

  test do
    assert_match /SDKMAN!\nscript: #{version}\nnative: #{resource("sdkman_cli_native").version}/, shell_output("export SDKMAN_DIR=#{libexec} && source #{libexec}/bin/sdkman-init.sh && sdk version")
  end

  def caveats
    <<~EOS
      Add the following to your shell profile e.g. ~/.profile or ~/.zshrc:
        export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
        [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    EOS
  end
end
