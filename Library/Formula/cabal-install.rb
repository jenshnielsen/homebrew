require 'formula'

class CabalInstall < Formula
  homepage 'http://www.haskell.org/haskellwiki/Cabal-Install'
  url 'http://hackage.haskell.org/package/cabal-install-1.18.0.2/cabal-install-1.18.0.2.tar.gz'
  sha1 '2d1f7a48d17b1e02a1e67584a889b2ff4176a773'

  bottle do
    cellar :any
    sha1 '6479272e2dcc61c0e240fb396baac1de96026655' => :mountain_lion
    sha1 '72bc77c328690f89ce722fc7d7885fa91b0bf331' => :lion
    sha1 '4f4ea54fb256df47bbbba5a8a21e5b3540300f69' => :snow_leopard
  end

  depends_on 'ghc'

  #Add apple-gcc42 here to stop homebrew from complaining about libc++
  #which makes no sense since ghc uses gcc.
  depends_on 'apple-gcc42' if MacOS.version >= :mountain_lion
  fails_with :clang do
    cause <<-EOS.undent
      Building with Clang configures GHC to use Clang as its preprocessor,
      which causes subsequent GHC-based builds to fail. Thus Cabal depends on
      gcc.
      EOS
  end

  conflicts_with 'haskell-platform'

  def install
    # use a temporary package database instead of ~/.cabal or ~/.ghc
    pkg_db = "#{Dir.pwd}/package.conf.d"
    system 'ghc-pkg', 'init', pkg_db
    ENV['EXTRA_CONFIGURE_OPTS'] = "--package-db=#{pkg_db}"
    ENV['PREFIX'] = Dir.pwd
    inreplace 'bootstrap.sh', 'list --global',
      'list --global --no-user-package-db'

    system 'sh', 'bootstrap.sh'
    bin.install "bin/cabal"
    bash_completion.install 'bash-completion/cabal'
  end

  test do
    system "#{bin}/cabal", "--config-file=#{testpath}/config", 'info', 'cabal'
  end
end
