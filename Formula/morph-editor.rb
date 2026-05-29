class MorphEditor < Formula
  desc "Terminal-native image/video annotation editor written in pure C"
  homepage "https://github.com/oxUnd/morph-editor"
  url "https://github.com/oxUnd/morph-editor/archive/f413383de25e5ccb1a608ab7038828cdd9976665.tar.gz"
  sha256 "3884bf2b1044484750258b8214d1dc9c5e60ccba49a767cca4405b27d7fb0bc7"
  version "0.1.0"
  license "all-rights-reserved"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libuv"

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_TESTS=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"

    bin.install "build/morph-editor"
  end

  test do
    assert_match "morph-editor", shell_output("#{bin}/morph-editor -h", 1)
  end
end
