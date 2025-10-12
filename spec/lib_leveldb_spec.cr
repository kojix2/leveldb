require "./spec_helper"

describe "LevelDB::LibLevelDB" do
  it "exposes version functions" do
    LevelDB::LibLevelDB.major_version.should be_a(Int32)
    LevelDB::LibLevelDB.minor_version.should be_a(Int32)
  end
end
