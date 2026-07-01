class Morph < Formula
  desc "Terminal-native multimodal AI agent written in pure C"
  homepage "https://github.com/oxUnd/morph"
  url "https://github.com/oxUnd/morph/archive/83c7887a9919e87cdbf7cb93b31c8803ed12624f.tar.gz"
  version "0.3.6"
  sha256 "5b0099d84cccc20da65f8a1cf43bb8f65cf5d33a1a08d7a8e717e5443f0b09bd"
  license "all-rights-reserved"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "curl"
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "libuv"
  depends_on "md4c"
  depends_on "morph-editor"
  depends_on "mpv"
  depends_on "sqlite"
  depends_on "readline" => :recommended

  resource "mathjax-c" do
    url "https://github.com/oxUnd/mathjax-c/archive/c6b33a517a8a1b82f25801b2b60104602389161f.tar.gz"
    sha256 "986881cea1bb72958d3fdd14f57a22a8f422c8ca1de84a2b5ced10cbc8ac1e3c"
  end

  def install
    resource("mathjax-c").stage buildpath/"vendor/mathjax-c"

    inreplace "CMakeLists.txt" do |s|
      md4c_fetchcontent = %r{
        include\(FetchContent\)\n\n
        if\(EXISTS\ "\$\{CMAKE_SOURCE_DIR\}/_deps/md4c-0\.5\.3\.tar\.gz"\).*?
        FetchContent_MakeAvailable\(md4c\)
      }mx
      s.gsub! md4c_fetchcontent, "find_package(md4c REQUIRED)"
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
