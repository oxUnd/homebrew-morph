class Morph < Formula
  desc "Terminal-native multimodal AI agent written in pure C"
  homepage "https://github.com/oxUnd/morph"
  url "https://github.com/oxUnd/morph/archive/refs/tags/v0.3.10.tar.gz"
  sha256 "3311f727aeb53286bb348e36bd1c19534da375a062fd84412cd8ffb6bd564ae0"
  license :cannot_represent

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "curl"
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "libuv"
  depends_on "morph-editor"
  depends_on "mpv"
  depends_on "pango"
  depends_on "sqlite"
  depends_on "vips"
  depends_on "readline" => :recommended

  resource "mathjax-c" do
    url "https://github.com/oxUnd/mathjax-c/archive/ea692adccc0eb56ac53261c5880d93094d22e43e.tar.gz"
    sha256 "e838ebb0766a8544dce359842bc529723ed0a41fd10b9df40b916a11d8ab3f90"
  end

  resource "morph-markdown" do
    url "https://github.com/oxUnd/morph-markdown/archive/509258e4b8c10624b39a58e5a91a40745f0ad524.tar.gz"
    sha256 "e1be2ab10feb40053375d48949ee37a481605a882cd2ef5e30874763d9d4b135"
  end

  resource "quickjs" do
    url "https://bellard.org/quickjs/quickjs-2026-06-04.tar.xz"
    sha256 "b376e839b322978313d929fd20663b11ba58b75df5a46c126dd19ea2fa70ad2a"
  end

  resource "wasm3" do
    url "https://github.com/wasm3/wasm3/archive/refs/tags/v0.5.0.tar.gz"
    sha256 "b778dd72ee2251f4fe9e2666ee3fe1c26f06f517c3ffce572416db067546536c"
  end

  resource "blake3" do
    url "https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/1.8.5.tar.gz"
    sha256 "220bd81286e2a0585beac66d41ac3f4c2c33ae8a4e339fc88cf22d5e00514fe9"
  end

  resource "tree-sitter" do
    url "https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.25.10.tar.gz"
    sha256 "ad5040537537012b16ef6e1210a572b927c7cdc2b99d1ee88d44a7dcdc3ff44c"
  end

  resource "tree-sitter-bash" do
    url "https://github.com/tree-sitter/tree-sitter-bash/archive/refs/tags/v0.25.1.tar.gz"
    sha256 "2e785a761225b6c433410ef9c7b63cfb0a4e83a35a19e0f2aec140b42c06b52d"
  end

  resource "cmark-gfm" do
    url "https://github.com/github/cmark-gfm/archive/refs/tags/0.29.0.gfm.13.tar.gz"
    sha256 "5abc61798ebd9de5660bc076443c07abad2b8d15dbc11094a3a79644b8ad243a"
  end

  def install
    resource("mathjax-c").stage buildpath/"vendor/mathjax-c"
    resource("morph-markdown").stage buildpath/"fronts/morph-markdown"

    fetchcontent_dir = buildpath/"homebrew-fetchcontent"
    %w[quickjs wasm3 blake3 tree-sitter tree-sitter-bash cmark-gfm].each do |name|
      resource(name).stage fetchcontent_dir/name
    end

    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_TESTS=OFF",
                    "-DFETCHCONTENT_SOURCE_DIR_QUICKJS=#{fetchcontent_dir}/quickjs",
                    "-DFETCHCONTENT_SOURCE_DIR_WASM3=#{fetchcontent_dir}/wasm3",
                    "-DFETCHCONTENT_SOURCE_DIR_BLAKE3=#{fetchcontent_dir}/blake3",
                    "-DFETCHCONTENT_SOURCE_DIR_TREE_SITTER=#{fetchcontent_dir}/tree-sitter",
                    "-DFETCHCONTENT_SOURCE_DIR_TREE_SITTER_BASH=#{fetchcontent_dir}/tree-sitter-bash",
                    "-DFETCHCONTENT_SOURCE_DIR_CMARK-GFM=#{fetchcontent_dir}/cmark-gfm",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    rm bin/"cmark-gfm"
    rm_r include
    rm_r lib
    rm_r share/"man"
  end

  test do
    assert_match "0.3.10", shell_output("#{bin}/morph --version")
    assert_path_exists bin/"morph-js-runner"
    assert_path_exists pkgshare/"fonts/STIXTwoMath-Regular.ttf"
    assert_path_exists pkgshare/"tiktoken/o200k_base.tiktoken"
    assert_path_exists pkgshare/"skills/morph-usage/SKILL.md"
  end
end
