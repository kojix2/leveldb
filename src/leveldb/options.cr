module LevelDB
  # Base for RAII over opaque handles
  private abstract class Handle(T)
    getter! handle : T

    protected def initialize(@handle : T)
    end
  end

  class Options < Handle(LibLevelDB::Options)
    def initialize(
      create_if_missing : Bool? = nil,
      error_if_exists : Bool? = nil,
      paranoid_checks : Bool? = nil,
      write_buffer_size : Int? = nil,
      max_open_files : Int? = nil,
      block_size : Int? = nil,
      block_restart_interval : Int? = nil,
      max_file_size : Int? = nil,
      compression : (LibLevelDB::Compression | Int32)? = nil
    )
      super LibLevelDB.options_create
      
      self.create_if_missing = create_if_missing unless create_if_missing.nil?
      self.error_if_exists = error_if_exists unless error_if_exists.nil?
      self.paranoid_checks = paranoid_checks unless paranoid_checks.nil?
      self.write_buffer_size = write_buffer_size unless write_buffer_size.nil?
      self.max_open_files = max_open_files unless max_open_files.nil?
      self.block_size = block_size unless block_size.nil?
      self.block_restart_interval = block_restart_interval unless block_restart_interval.nil?
      self.max_file_size = max_file_size unless max_file_size.nil?
      self.compression = compression unless compression.nil?
    end

    # Finalizer is a safety net. Prefer using with a block or explicit close.
    def finalize
      return if @handle.nil?
      LibLevelDB.options_destroy(@handle.not_nil!)
    end

    def close
      return if @handle.nil?
      LibLevelDB.options_destroy(@handle.not_nil!)
      @handle = Pointer(Void).null.as(LibLevelDB::Options)
    end


    def create_if_missing=(v : Bool)
      LibLevelDB.options_set_create_if_missing(handle, v ? 1_u8 : 0_u8)
      v
    end

    def error_if_exists=(v : Bool)
      LibLevelDB.options_set_error_if_exists(handle, v ? 1_u8 : 0_u8)
      v
    end

    def paranoid_checks=(v : Bool)
      LibLevelDB.options_set_paranoid_checks(handle, v ? 1_u8 : 0_u8)
      v
    end

    def write_buffer_size=(size : Int)
      LibLevelDB.options_set_write_buffer_size(handle, size.to_u64)
      size
    end

    def max_open_files=(n : Int)
      LibLevelDB.options_set_max_open_files(handle, n.to_i)
      n
    end

    def block_size=(size : Int)
      LibLevelDB.options_set_block_size(handle, size.to_u64)
      size
    end

    def block_restart_interval=(n : Int)
      LibLevelDB.options_set_block_restart_interval(handle, n.to_i)
      n
    end

    def max_file_size=(size : Int)
      LibLevelDB.options_set_max_file_size(handle, size.to_u64)
      size
    end

    def compression=(c : LibLevelDB::Compression | Int32)
      LibLevelDB.options_set_compression(handle, c.to_i)
      c
    end
  end

  class ReadOptions < Handle(LibLevelDB::ReadOptions)
    def initialize
      super LibLevelDB.readoptions_create
    end

    # Finalizer is a safety net. Prefer using with a block or explicit close.
    def finalize
      return if @handle.nil?
      LibLevelDB.readoptions_destroy(@handle.not_nil!)
    end

    def close
      return if @handle.nil?
      LibLevelDB.readoptions_destroy(@handle.not_nil!)
      @handle = Pointer(Void).null.as(LibLevelDB::ReadOptions)
    end

    def verify_checksums=(v : Bool)
      LibLevelDB.readoptions_set_verify_checksums(handle, v ? 1_u8 : 0_u8)
      v
    end

    def fill_cache=(v : Bool)
      LibLevelDB.readoptions_set_fill_cache(handle, v ? 1_u8 : 0_u8)
      v
    end

    def snapshot=(snap : LibLevelDB::Snapshot)
      LibLevelDB.readoptions_set_snapshot(handle, snap)
      snap
    end
  end

  class WriteOptions < Handle(LibLevelDB::WriteOptions)
    def initialize
      super LibLevelDB.writeoptions_create
    end

    # Finalizer is a safety net. Prefer using with a block or explicit close.
    def finalize
      return if @handle.nil?
      LibLevelDB.writeoptions_destroy(@handle.not_nil!)
    end

    def close
      return if @handle.nil?
      LibLevelDB.writeoptions_destroy(@handle.not_nil!)
      @handle = Pointer(Void).null.as(LibLevelDB::WriteOptions)
    end

    def sync=(v : Bool)
      LibLevelDB.writeoptions_set_sync(handle, v ? 1_u8 : 0_u8)
      v
    end
  end
end
