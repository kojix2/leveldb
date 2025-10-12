module LevelDB
  # Generic LevelDB error
  class Error < Exception
  end

  # Internal helper to check C error pointer, raise if set, and free.
  def self.raise_if_error(errptr : Pointer(Pointer(LibC::Char)))
    cstr_ptr = errptr.value
    return if cstr_ptr.null?
    begin
      # Convert C string to Crystal String (copies the content)
      message = String.new(cstr_ptr)
      raise Error.new(message)
    ensure
      # leveldb allocates message via malloc in its API; free with leveldb_free
      LibLevelDB.free(cstr_ptr.as(Void*))
      # Also null out for safety
      errptr.value = Pointer(LibC::Char).null
    end
  end
end
