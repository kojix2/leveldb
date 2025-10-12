require "./errors"
require "./options"

module LevelDB
  class Iterator
    getter ptr : LibLevelDB::Iterator

    def initialize(db : DB, read_options : ReadOptions = ReadOptions.new)
      # Keep reference to DB to prevent it from being garbage collected
      @db = db
      @ptr = LibLevelDB.create_iterator(db.ptr, read_options.handle)
      @closed = false
    end

    # Finalizer is only a safety net; prefer explicit close or block usage.
    def finalize
      LibLevelDB.iter_destroy(@ptr) unless @closed || @ptr.null?
    end

    def valid? : Bool
      ensure_not_closed!
      LibLevelDB.iter_valid(@ptr) != 0_u8
    end

    def seek_to_first
      ensure_not_closed!
      LibLevelDB.iter_seek_to_first(@ptr)
      self
    end

    def seek_to_last
      ensure_not_closed!
      LibLevelDB.iter_seek_to_last(@ptr)
      self
    end

    def seek(key : Bytes | String)
      ensure_not_closed!
      kptr, klen = to_bytes(key)
      LibLevelDB.iter_seek(@ptr, kptr, klen)
      self
    end

    def next
      ensure_not_closed!
      LibLevelDB.iter_next(@ptr)
      self
    end

    def prev
      ensure_not_closed!
      LibLevelDB.iter_prev(@ptr)
      self
    end

    def key : Bytes
      ensure_not_closed!
      raise Error.new("Iterator is not valid") unless valid?
      lenp = Pointer(LibC::SizeT).malloc(1_u64)
      kptr = LibLevelDB.iter_key(@ptr, lenp)
      raise Error.new("Failed to get key") if kptr.null?
      len = lenp.value
      return Bytes.empty if len == 0
      Bytes.new(kptr, len).clone
    end

    def key_string : String
      String.new(key)
    end

    def value : Bytes
      ensure_not_closed!
      raise Error.new("Iterator is not valid") unless valid?
      lenp = Pointer(LibC::SizeT).malloc(1_u64)
      vptr = LibLevelDB.iter_value(@ptr, lenp)
      raise Error.new("Failed to get value") if vptr.null?
      len = lenp.value
      return Bytes.empty if len == 0
      Bytes.new(vptr, len).clone
    end

    def value_string : String
      String.new(value)
    end

    # Yields each key-value pair
    def each(&block : Bytes, Bytes ->)
      ensure_not_closed!
      seek_to_first
      while valid?
        yield key, value
        self.next
      end
      check_error # Check for any iteration errors
    end

    # Yields each key-value pair as strings
    def each_string(&block : String, String ->)
      each do |k, v|
        yield String.new(k), String.new(v)
      end
    end

    def check_error
      ensure_not_closed!
      err = Pointer(Pointer(LibC::Char)).malloc(1_u64)
      err.value = Pointer(LibC::Char).null
      LibLevelDB.iter_get_error(@ptr, err)
      LevelDB.raise_if_error(err)
      nil
    end

    def close
      return if @closed
      @closed = true
      LibLevelDB.iter_destroy(@ptr) unless @ptr.null?
      @ptr = Pointer(Void).null.as(LibLevelDB::Iterator)
    end

    def closed?
      @closed
    end

    private def ensure_not_closed!
      raise Error.new("Iterator is closed") if @closed
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
