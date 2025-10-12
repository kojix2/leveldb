require "./spec_helper"

describe LevelDB::Iterator do
  it "iterates over keys in order" do
    dir = make_tmpdir
    begin
      opts = LevelDB::Options.new(create_if_missing: true)
      LevelDB::DB.open(dir, opts) do |db|
        db.put "a", "1"
        db.put "b", "2"
        db.put "c", "3"

        keys = [] of String
        values = [] of String
        db.each_string do |k, v|
          keys << k
          values << v
        end

        keys.should eq(["a", "b", "c"]) # LevelDB lexicographic order
        values.should eq(["1", "2", "3"])
      end
    ensure
      rm_rf(dir)
    end
  end

  it "seek and iterate from middle" do
    dir = make_tmpdir
    begin
      opts = LevelDB::Options.new(create_if_missing: true)
      LevelDB::DB.open(dir, opts) do |db|
        ["a", "b", "c", "d"].each_with_index { |k, i| db.put k, (i + 1).to_s }

        db.iterator do |it|
          it.seek("b")
          out = [] of String
          while it.valid?
            out << String.new(it.key)
            it.next
          end
          it.check_error
          out.should eq(["b", "c", "d"])
        end
      end
    ensure
      rm_rf(dir)
    end
  end
end
