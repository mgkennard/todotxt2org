class Todotxt2org < Formula
  desc "Convert todo.txt files into Org mode files"
  homepage "https://github.com/mgkennard/todotxt2org"
  url "https://github.com/mgkennard/todotxt2org.git", :tag => "0.1", :revision => "9bc9b788eeef34cde20275b6e201a4b5fc0bd922"
  head "https://github.com/mgkennard/todotxt2org.git"

  depends_on :xcode => ["10.1", :build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    touch "test.txt"
    system "#{bin}/todotxt2org"
  end
end
