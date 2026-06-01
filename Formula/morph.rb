class Morph < Formula
  desc "Terminal-native multimodal AI agent written in pure C"
  homepage "https://github.com/oxUnd/morph"
  url "https://github.com/oxUnd/morph/archive/1dcfaf2162f9adc17b9120b22949dfd51be94954.tar.gz"
  version "0.3.4"
  sha256 "9d94731e4068e1399d76d707cfe30f058ed215d591ea68f17b9a7bde21e4a605"
  license "all-rights-reserved"

  depends_on "cmake" => :build
  depends_on "curl"
  depends_on "mpv"
  depends_on "libuv"
  depends_on "md4c"
  depends_on "morph-editor"
  depends_on "sqlite"
  depends_on "readline" => :recommended

  def install
    inreplace "CMakeLists.txt" do |s|
      s.gsub! "include(FetchContent)", ""
      s.gsub! %r{FetchContent_Declare\(\n\tmd4c\n\tURL      https://github\.com/mity/md4c/archive/refs/tags/release-0\.5\.3\.tar\.gz\n\)\nFetchContent_MakeAvailable\(md4c\)},
              "find_package(md4c REQUIRED)"
    end

    inreplace "src/render/CMakeLists.txt", "md4c", "md4c::md4c"

    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_TESTS=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"

    bin.install "build/morph"

    (etc/"morph").install "config.toml.example" => "config.toml.example"
    (pkgshare/"tiktoken").install Dir["vendor/tiktoken/*.tiktoken"]
  end

  def post_install
    tiktoken_dir = Pathname.new(Dir.home) / ".morph" / "tiktoken"
    tiktoken_dir.mkpath
    %w[cl100k_base.tiktoken o200k_base.tiktoken].each do |f|
      src = pkgshare / "tiktoken" / f
      cp src, tiktoken_dir / f if src.exist?
    end
  end

  test do
    assert_match "morph", shell_output("#{bin}/morph -h")
  end
end
