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
      @closed = false
    end

    # Finalizer is only a safety net; prefer explicit close or block-style open.
    def finalize
      LibLevelDB.close(@ptr) unless @closed || @ptr.null?
    end

    # RAII-friendly block helper
    def self.open(path : String, options : Options = Options.new, &)
      db = new(path, options)
      begin
        yield db
      ensure
        db.close
      end
    end

    def close
      return if @closed
      @closed = true
      LibLevelDB.close(@ptr) unless @ptr.null?
      @ptr = Pointer(Void).null.as(LibLevelDB::DB)
    end

    def closed?
      @closed
    end

    def put(key : Bytes | String, value : Bytes | String, write_options : WriteOptions = WriteOptions.new)
      ensure_not_closed!
      key_ptr, key_len = to_bytes(key)
      val_ptr, val_len = to_bytes(value)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.put(@ptr, write_options.handle, key_ptr, key_len, val_ptr, val_len, err)
      LevelDB.raise_if_error(err)
      nil
    end

    def get(key : Bytes | String, read_options : ReadOptions = ReadOptions.new) : Bytes?
      ensure_not_closed!
      key_ptr, key_len = to_bytes(key)
      vallen = Pointer(LibC::SizeT).malloc(1_u64)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      val_ptr = LibLevelDB.get(@ptr, read_options.handle, key_ptr, key_len, vallen, err)
      LevelDB.raise_if_error(err)
      return nil if val_ptr.null?
      begin
        len = vallen.value
        return Bytes.empty if len == 0
        # Copy into managed Bytes
        Bytes.new(val_ptr, len).clone
      ensure
        LibLevelDB.free(val_ptr.as(Pointer(Void))) unless val_ptr.null?
      end
    end

    def get_string(key : Bytes | String, read_options : ReadOptions = ReadOptions.new) : String?
      bytes = get(key, read_options)
      bytes ? String.new(bytes) : nil
    end

    # [] operator for convenient string access
    def [](key : Bytes | String) : String?
      get_string(key)
    end

    def delete(key : Bytes | String, write_options : WriteOptions = WriteOptions.new)
      ensure_not_closed!
      key_ptr, key_len = to_bytes(key)
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.delete(@ptr, write_options.handle, key_ptr, key_len, err)
      LevelDB.raise_if_error(err)
      nil
    end

    def write(batch : WriteBatch, write_options : WriteOptions = WriteOptions.new)
      ensure_not_closed!
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.write(@ptr, write_options.handle, batch.handle, err)
      LevelDB.raise_if_error(err)
      nil
    end

    # Create a snapshot of the current DB state
    def create_snapshot : LibLevelDB::Snapshot
      ensure_not_closed!
      LibLevelDB.create_snapshot(@ptr)
    end

    # Release a snapshot
    def release_snapshot(snapshot : LibLevelDB::Snapshot)
      ensure_not_closed!
      LibLevelDB.release_snapshot(@ptr, snapshot)
    end

    # Get database property value
    def property(name : String) : String?
      ensure_not_closed!
      prop_ptr = LibLevelDB.property_value(@ptr, name)
      return nil if prop_ptr.null?
      begin
        String.new(prop_ptr)
      ensure
        LibLevelDB.free(prop_ptr.as(Pointer(Void))) unless prop_ptr.null?
      end
    end

    # Compact the underlying storage for the key range [start_key, limit_key]
    def compact_range(start_key : Bytes | String, limit_key : Bytes | String)
      ensure_not_closed!
      start_ptr, start_len = to_bytes(start_key)
      limit_ptr, limit_len = to_bytes(limit_key)
      LibLevelDB.compact_range(@ptr, start_ptr, start_len, limit_ptr, limit_len)
    end

    # Compact the entire database
    def compact
      ensure_not_closed!
      LibLevelDB.compact_range(@ptr, Pointer(LibC::Char).null, 0, Pointer(LibC::Char).null, 0)
    end

    # Create an iterator
    def iterator(read_options : ReadOptions = ReadOptions.new) : Iterator
      ensure_not_closed!
      Iterator.new(self, read_options)
    end

    # Block-style iterator usage with ensure close
    def iterator(read_options : ReadOptions = ReadOptions.new, &)
      it = iterator(read_options)
      begin
        yield it
      ensure
        it.close
      end
    end

    # Iterate over all key-value pairs
    def each(&block : Bytes, Bytes ->)
      iter = iterator
      begin
        iter.each { |k, v| yield k, v }
      ensure
        iter.close
      end
    end

    # Iterate over all key-value pairs as strings
    def each_string(&block : String, String ->)
      iter = iterator
      begin
        iter.each_string { |k, v| yield k, v }
      ensure
        iter.close
      end
    end

    private def ensure_not_closed!
      raise Error.new("Database is closed") if @closed
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
