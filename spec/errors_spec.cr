require "./spec_helper"

describe LevelDB::Error do
  it "does nothing if errptr is null" do
    err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
    err.value = Pointer(LibC::Char).null
    # Should not raise
    LevelDB.raise_if_error(err)
  end
end
