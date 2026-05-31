class Morph < Formula
  desc "Terminal-native multimodal AI agent written in pure C"
  homepage "https://github.com/oxUnd/morph"
  url "https://github.com/oxUnd/morph/archive/c64283f81f17f813c0de6cb6b683f65a745f6766.tar.gz"
  version "0.3.3"
  sha256 "67b3e1cda3251b978639365bbd247361ed428324d59948728eff01c2b9833169"
  license "all-rights-reserved"

  depends_on "cmake" => :build
  depends_on "curl"
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
    assert_match "morph", shell_output("#{bin}/morph -h", 1)
  end
end
