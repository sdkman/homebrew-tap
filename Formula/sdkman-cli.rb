class SdkmanCli < Formula
  desc "Sdkman - The Software Development Kit Manager"
  homepage "https://sdkman.io"
  url "https://github.com/sdkman/sdkman-cli/releases/download/5.14.3/sdkman-cli-5.14.3.zip"
  version "5.14.3"
  sha256 "c5130c787b90ffa78470b148f90792ba376a07c93958eaba1a97da9e20239cae"
  license "Apache-2.0"

  def install
    libexec.install Dir["*"]

    %w[tmp ext etc var archives candidates].each { |dir| mkdir libexec/dir }

    system "curl", "-s", "https://api.sdkman.io/2/candidates/all", "-o", libexec/"var/candidates"

    (libexec/"etc/config").write <<~EOS
      sdkman_auto_answer=false
      sdkman_auto_complete=true
      sdkman_auto_env=false
      sdkman_auto_update=false
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
