require "./spec_helper"

describe LevelDB do

  it "has a version number" do
    LevelDB::VERSION.should match(/\d+\.\d+\.\d+/)
  end
end
