require "./errors"
require "./options"

module LevelDB
  class DB
    getter ptr : LibLevelDB::DB

    def initialize(path : String, options : Options = Options.new)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      @ptr = LibLevelDB.open(options.handle, path, err)
      LevelDB.raise_if_error(err)
      raise Error.new("failed to open db: unknown error") if @ptr.null?
      GC.add_finalizer(self) { |obj| LibLevelDB.close(obj.ptr) unless obj.ptr.null? }
    end

    def close
      return if @ptr.null?
      LibLevelDB.close(@ptr)
      @ptr = Pointer(Void).null.as(LibLevelDB::DB)
    end

    def put(key : Bytes | String, value : Bytes | String, write_options : WriteOptions = WriteOptions.new)
      key_ptr, key_len = to_bytes(key)
      val_ptr, val_len = to_bytes(value)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.put(@ptr, write_options.handle, key_ptr, key_len, val_ptr, val_len, err)
      LevelDB.raise_if_error(err)
      nil
    end

    def get(key : Bytes | String, read_options : ReadOptions = ReadOptions.new) : Bytes?
      key_ptr, key_len = to_bytes(key)
      vallen = Pointer(LibC::SizeT).malloc(1_u64)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      val_ptr = LibLevelDB.get(@ptr, read_options.handle, key_ptr, key_len, vallen, err)
      LevelDB.raise_if_error(err)
      return nil if val_ptr.null?
      begin
        len = vallen.value
        # Copy into managed Bytes
        slice = Bytes.new(len)
        LibC.memcpy(slice.to_unsafe.as(Pointer(Void)), val_ptr.as(Pointer(Void)), len)
        slice
      ensure
        LibLevelDB.free(val_ptr.as(Pointer(Void))) unless val_ptr.null?
      end
    end

    def delete(key : Bytes | String, write_options : WriteOptions = WriteOptions.new)
      key_ptr, key_len = to_bytes(key)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.delete(@ptr, write_options.handle, key_ptr, key_len, err)
      LevelDB.raise_if_error(err)
      nil
    end

    def write(batch : WriteBatch, write_options : WriteOptions = WriteOptions.new)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.write(@ptr, write_options.handle, batch.handle, err)
      LevelDB.raise_if_error(err)
      nil
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
