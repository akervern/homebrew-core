class AflFuzz < Formula
  desc "American fuzzy lop: Security-oriented fuzzer"
  homepage "http://lcamtuf.coredump.cx/afl/"
  url "http://lcamtuf.coredump.cx/afl/releases/afl-2.20b.tgz"
  sha256 "f84f3b2e6e52fc03b737f2cb7988996b88668da8de9810dfd797d81cc17de23b"

  bottle do
    sha256 "21c25f56187b6f25b0ee658dfdcb7cda9754fd6c2a0345a2131c2f23970ba248" => :el_capitan
    sha256 "7d4ab575a84873b6a61d541401adcbd6c5af2bbde820e71d081e7f20944d60d3" => :yosemite
    sha256 "cebe42158975cd4e4ba45f364ea9cbd1113e3feb78bead1b7b7f7a244e07ad7c" => :mavericks
  end

  def install
    # test_build dies with "Oops, the instrumentation does not seem to be
    # behaving correctly!" in a nested login shell.
    # Reported to lcamtuf@coredump.cx 6th Apr 2016.
    inreplace "Makefile" do |s|
      s.gsub! "all: test_x86 $(PROGS) afl-as test_build all_done", "all: test_x86 $(PROGS) afl-as all_done"
      s.gsub! "all_done: test_build", "all_done:"
    end
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    cpp_file = testpath/"main.cpp"
    exe_file = testpath/"test"

    cpp_file.write <<-EOS.undent
      #include <iostream>

      int main() {
        std::cout << "Hello, world!";
      }
    EOS

    system "#{bin}/afl-clang++", "-g", cpp_file, "-o", exe_file
    output = `#{exe_file}`
    assert_equal 0, $?.exitstatus
    assert_equal output, "Hello, world!"
  end
end
