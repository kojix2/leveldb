require "./spec_helper"

describe LevelDB::DB do
  it "opens and closes" do
    dir = File.join(Dir.tempdir, "ldb-#{Random::Secure.hex(4)}")
    Dir.mkdir(dir)
    begin
      opts = LevelDB::Options.new(create_if_missing: true)
      LevelDB::DB.open(dir, opts) do |db|
        db.closed?.should be_false
      end
    ensure
      # naive recursive removal
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
  end

  it "put/get/delete roundtrip" do
    dir = File.join(Dir.tempdir, "ldb-#{Random::Secure.hex(4)}")
    Dir.mkdir(dir)
    begin
      opts = LevelDB::Options.new(create_if_missing: true)
      LevelDB::DB.open(dir, opts) do |db|
        db.put "k1", "v1"
        db.get_string("k1").should eq("v1")
        db.delete "k1"
        db.get("k1").should be_nil
      end
    ensure
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
  end
end
