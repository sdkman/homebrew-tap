class SdkmanCli < Formula
  desc "Sdkman - The Software Development Kit Manager"
  homepage "https://sdkman.io"
  url "https://github.com/sdkman/sdkman-cli/releases/download/5.18.2/sdkman-cli-5.18.2.zip"
  version "5.18.2"
  sha256 "e98d0d0501e8b8d2749a601b5dc23344ed5ad67c99beb0f4d968c2e186b4ee71"
  license "Apache-2.0"

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
    EOS
  end

  test do
    assert_match version, shell_output("export SDKMAN_DIR=#{libexec} && source #{libexec}/bin/sdkman-init.sh && sdk version")
  end
end
