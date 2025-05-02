class SdkmanCli < Formula
  desc "SDKMAN! the Software Development Kit Manager"
  homepage "https://sdkman.io"
  url "https://github.com/sdkman/sdkman-cli/releases/download/5.19.0/sdkman-cli-5.19.0.zip"
  sha256 "3a9657b7cccc21998055520efd11c76faadaa73cac863c34094a7b9cb5eb67a9"
  license "Apache-2.0"

  resource "sdkman_cli_native" do
    on_macos do
      on_arm do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.4/sdkman-cli-native-0.7.4-aarch64-apple-darwin.zip"
        sha256 "f0eab8d5e8165510d17c1bb12699d1ce8f787d0b47cfea378a466c7457938d42"
      end
      on_intel do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.4/sdkman-cli-native-0.7.4-x86_64-apple-darwin.zip"
        sha256 "3fa846c9f92faed9568fc74b48b3f002a41315983ec8656be0f4edbbfa3844f3"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.4/sdkman-cli-native-0.7.4-aarch64-unknown-linux-gnu.zip"
        sha256 "82153f4463295d0ec658278ef4dbfce0670203f7bb15c3472d0ace09301c9da5"
      end
      on_intel do
        url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.7.4/sdkman-cli-native-0.7.4-x86_64-unknown-linux-gnu.zip"
        sha256 "2ac9e1e53289c065d8442bcdb4a2a2fa6e9034c49ffd1443f5ce0937556ff6ba"
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
end
