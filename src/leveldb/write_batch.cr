require "./options"

module LevelDB
  class WriteBatch
    getter handle : LibLevelDB::WriteBatch

    def initialize
      @handle = LibLevelDB.writebatch_create
    end

    # Finalizer is only a safety net; prefer explicit close or block usage.
    def finalize
      LibLevelDB.writebatch_destroy(@handle) unless @handle.null?
    end

    def close
      return if @handle.null?
      LibLevelDB.writebatch_destroy(@handle)
      @handle = Pointer(Void).null.as(LibLevelDB::WriteBatch)
    end

    def self.build(&)
      b = new
      begin
        yield b
        b
      rescue ex
        b.close
        raise ex
      end
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
