require "spec"
require "../src/leveldb"

# Test helpers
def make_tmpdir(prefix = "ldb-") : String
	dir = File.join(Dir.tempdir, "#{prefix}#{Random::Secure.hex(4)}")
	Dir.mkdir(dir)
	dir
end

def rm_rf(dir : String)
	paths = Dir.glob("#{dir}/**/*")
	paths.reverse_each do |path|
		if File.directory?(path)
			Dir.delete(path) rescue nil
		else
			File.delete(path) rescue nil
		end
	end
	Dir.delete(dir) rescue nil
end
