require 'formula'

class Fftw < Formula
  homepage 'http://www.fftw.org'
  url 'http://www.fftw.org/fftw-3.3.3.tar.gz'
  sha1 '11487180928d05746d431ebe7a176b52fe205cf9'

  option "with-fortran", "Enable Fortran bindings"
  option "with-openmp", "Enable OpenMP version"

  def install
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]

    if build.include? "with-fortran"
      ENV.fortran
    else
      args << "--disable-fortran" unless which 'gfortran'
    end
    
    if build.include? "with-openmp"
      depends_on 'pango'
      ENV['HOMEBREW_CC'] = "gcc-4.8"
      "might need something like https://github.com/rabauke/trng4/pull/2/files"
      args << "--enable-openmp"
    end

    # single precision
    # enable-sse only works with single
    system "./configure", "--enable-single",
                          "--enable-sse",
                          *args
    system "make install"

    # clean up so we can compile the double precision variant
    system "make clean"

    # double precision
    # enable-sse2 only works with double precision (default)
    system "./configure", "--enable-sse2", *args
    system "make install"

    # clean up so we can compile the long-double precision variant
    system "make clean"

    # long-double precision
    # no SIMD optimization available
    system "./configure", "--enable-long-double", *args
    system "make install"
  end

  test do
    # Adapted from the sample usage provided in the documentation:
    # http://www.fftw.org/fftw3_doc/Complex-One_002dDimensional-DFTs.html
    (testpath/'fftw.c').write <<-TEST_SCRIPT.undent
      #include <fftw3.h>

      int main(int argc, char* *argv)
      {
          fftw_complex *in, *out;
          fftw_plan p;
          long N = 1;
          in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
          fftw_execute(p); /* repeat as needed */
          fftw_destroy_plan(p);
          fftw_free(in); fftw_free(out);
          return 0;
      }
    TEST_SCRIPT

    system ENV.cc, '-o', 'fftw', 'fftw.c', '-lfftw3', *ENV.cflags.split
    system './fftw'
  end

  
  def patches
    # Fixes detection of OpenMP on Mac 
    "https://gist.github.com/jenshnielsen/5846017/raw/3e53d60b581f4e7fffd2410ca701d54003c85073/fftw_openmp"
  end
end
