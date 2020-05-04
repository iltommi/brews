class Gnuplot < Formula
  desc "Command-driven, interactive function plotting"
  homepage "http://www.gnuplot.info/"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.2.8/gnuplot-5.2.8.tar.gz"
  sha256 "60a6764ccf404a1668c140f11cc1f699290ab70daa1151bb58fed6139a28ac37"
  revision 1

  head do
    url "https://git.code.sf.net/p/gnuplot/gnuplot-main.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gd"
  depends_on "libcerf"
  depends_on "lua"
  depends_on "pango"
  depends_on "qt"
  depends_on "readline"
  depends_on "wxmac"
  depends_on :x11

  def install
    # Qt5 requires c++11 (and the other backends do not care)
    ENV.cxx11

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
      --without-tutorial
      --with-qt
      --with-x
      --with-wx=#{Formula["wxmac"].opt_prefix}/bin/
    ]
    
    system "sed -i '' 's/define\ GP_CAIRO_SCALE\ 20/define\ GP_CAIRO_SCALE\ 1/g' ./src/wxterminal/gp_cairo.h"

    system "./prepare" if build.head?
    system "./configure", "--help"
    system "./configure", *args
    ENV.deparallelize # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/gnuplot", "-e", <<~EOS
      set terminal dumb;
      set output "#{testpath}/graph.txt";
      plot sin(x);
    EOS
    assert_predicate testpath/"graph.txt", :exist?
  end
end
