class Help2man < Formula
  desc "Automatically generate simple man pages"
  homepage "https://www.gnu.org/software/help2man/"
  url "http://ftpmirror.gnu.org/help2man/help2man-1.47.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/help2man/help2man-1.47.1.tar.xz"
  sha256 "c59b26f60cb06e45b00e729dea721e7a17220e2c17d800eb428271a750382b06"

  bottle do
    cellar :any
    sha1 "9da6d2c455736f4798fe0a61a5f3d36fdba7dcc1" => :yosemite
    sha1 "82f41da658678b31550bd68a627530f777fb68c9" => :mavericks
    sha1 "b58ab63750f1725c5daa4f5c5ad0b961d1fe2df4" => :mountain_lion
  end

  def install
    # install is not parallel safe
    # see https://github.com/Homebrew/homebrew/issues/12609
    ENV.j1

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    cmd = "#{bin}/help2man #{bin}/help2man"
    assert_match(/"help2man #{version}"/, shell_output(cmd))
  end
end
