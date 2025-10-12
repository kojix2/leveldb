require "./options"

module LevelDB
  class WriteBatch
    getter handle : LibLevelDB::WriteBatch

    def initialize
      @handle = LibLevelDB.writebatch_create
    end

    def finalize
      LibLevelDB.writebatch_destroy(@handle)
    end

    def clear
      LibLevelDB.writebatch_clear(@handle)
    end

    def put(key : Bytes | String, value : Bytes | String)
      kptr, klen = to_bytes(key)
      vptr, vlen = to_bytes(value)
      LibLevelDB.writebatch_put(@handle, kptr, klen, vptr, vlen)
    end

    def delete(key : Bytes | String)
      kptr, klen = to_bytes(key)
      LibLevelDB.writebatch_delete(@handle, kptr, klen)
    end

    def append(other : WriteBatch)
      LibLevelDB.writebatch_append(@handle, other.handle)
    end

    private def to_bytes(s : String)
      sl = s.to_slice
      {sl.to_unsafe.as(Pointer(LibC::Char)), sl.size}
    end

    private def to_bytes(b : Bytes)
      {b.to_unsafe.as(Pointer(LibC::Char)), b.size}
    end
  end
end
