class Morph < Formula
  desc "Terminal-native multimodal AI agent written in pure C"
  homepage "https://github.com/oxUnd/morph"
  url "https://github.com/oxUnd/morph/archive/1191628db7c1f4bb627c0cfa2465281765c3e0ef.tar.gz"
  sha256 "4930476a16b41fa3aa9989617d99f3a94ae7fe1c3665efb6a0e0444bebea9369"
  version "0.1.0"
  license "all-rights-reserved"

  depends_on "cmake" => :build
  depends_on "md4c"
  depends_on "sqlite"
  depends_on "curl"
  depends_on "readline" => :recommended

  def install
    inreplace "CMakeLists.txt" do |s|
      s.gsub! /include\(FetchContent\)/, ""
      s.gsub! /FetchContent_Declare\(\n\tmd4c\n\tURL      https:\/\/github\.com\/mity\/md4c\/archive\/refs\/tags\/release-0\.5\.3\.tar\.gz\n\)\nFetchContent_MakeAvailable\(md4c\)/, "find_package(md4c REQUIRED)"
    end

    inreplace "src/render/CMakeLists.txt", "md4c", "md4c::md4c"

    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_TESTS=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"

    bin.install "build/morph"

    (etc/"morph").install "config.toml.example" => "config.toml.example"
  end

  test do
    assert_match "morph", shell_output("#{bin}/morph -h", 1)
  end
end
