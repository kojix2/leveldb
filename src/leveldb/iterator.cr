require "./errors"
require "./options"

module LevelDB
  class Iterator
    getter ptr : LibLevelDB::Iterator

    def initialize(db : DB, read_options : ReadOptions = ReadOptions.new)
      @db = db
      @ptr = LibLevelDB.create_iterator(db.ptr, read_options.handle)
      GC.add_finalizer(self) { |obj| LibLevelDB.iter_destroy(obj.ptr) unless obj.ptr.null? }
    end

    def valid? : Bool
      LibLevelDB.iter_valid(@ptr) != 0_u8
    end

    def seek_to_first
      LibLevelDB.iter_seek_to_first(@ptr)
    end

    def seek_to_last
      LibLevelDB.iter_seek_to_last(@ptr)
    end

    def seek(key : Bytes | String)
      kptr, klen = to_bytes(key)
      LibLevelDB.iter_seek(@ptr, kptr, klen)
    end

    def next
      LibLevelDB.iter_next(@ptr)
    end

    def prev
      LibLevelDB.iter_prev(@ptr)
    end

    def key : Bytes
      lenp = Pointer(LibC::SizeT).malloc(1_u64)
      kptr = LibLevelDB.iter_key(@ptr, lenp)
      len = lenp.value
      bytes = Bytes.new(len)
      LibC.memcpy(bytes.to_unsafe.as(Pointer(Void)), kptr.as(Pointer(Void)), len)
      bytes
    end

    def value : Bytes
      lenp = Pointer(LibC::SizeT).malloc(1_u64)
      vptr = LibLevelDB.iter_value(@ptr, lenp)
      len = lenp.value
      bytes = Bytes.new(len)
      LibC.memcpy(bytes.to_unsafe.as(Pointer(Void)), vptr.as(Pointer(Void)), len)
      bytes
    end

    def error!
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.iter_get_error(@ptr, err)
      LevelDB.raise_if_error(err)
      nil
    end

    def close
      return if @ptr.null?
      LibLevelDB.iter_destroy(@ptr)
      @ptr = Pointer(Void).null.as(LibLevelDB::Iterator)
    end

    private def to_bytes(s : String)
      slice = s.to_slice
      {slice.to_unsafe.as(Pointer(LibC::Char)), slice.size}
    end

    private def to_bytes(b : Bytes)
      {b.to_unsafe.as(Pointer(LibC::Char)), b.size}
    end
  end
end
