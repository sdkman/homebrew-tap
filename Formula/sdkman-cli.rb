class SdkmanCli < Formula
  desc "SDKMAN! the Software Development Kit Manager"
  homepage "https://sdkman.io"
  url "https://github.com/sdkman/sdkman-cli/releases/download/5.23.0/sdkman-cli-5.23.0.zip"
  sha256 "7ef83583a6986351ea8c86b8494a885fcae91a2fbfac91662bca7ea4f72bd230"
  license "Apache-2.0"

  resource "sdkman_cli_native" do
    on_macos do
      on_arm do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.34/sdkman-cli-native-0.7.34-aarch64-apple-darwin.zip"
        sha256 "605309948730f016960f6e22add3160dbf04ba49b424fefe934aed27d4202097"
      end
      on_intel do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.34/sdkman-cli-native-0.7.34-x86_64-apple-darwin.zip"
        sha256 "ed7b23d745bc65724cfb4827f87f654ffe87f47d6055f3e9041520396a7bfd21"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.34/sdkman-cli-native-0.7.34-aarch64-unknown-linux-gnu.zip"
        sha256 "79b2747107aaeca1c4d3c1fea1178ec34210e43949633771b5c31f08c353ee7b"
      end
      on_intel do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.34/sdkman-cli-native-0.7.34-x86_64-unknown-linux-gnu.zip"
        sha256 "d268e17a36f6fae542bb38018f2bfadf60689c4c1de0bff2dcfdace0855ddf0a"
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
