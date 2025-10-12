module LevelDB
  # Base for RAII over opaque handles
  private abstract class Handle(T)
    getter! handle : T

    protected def initialize(@handle : T)
    end
  end

  class Options < Handle(LibLevelDB::Options)
    def initialize
      super LibLevelDB.options_create
    end

    def finalize
      return if @handle.nil?
      LibLevelDB.options_destroy(@handle.not_nil!)
    end

    def create_if_missing=(v : Bool)
      LibLevelDB.options_set_create_if_missing(handle, v ? 1_u8 : 0_u8)
      v
    end

    def create_if_missing(v : Bool)
      self.create_if_missing = v
      self
    end

    def error_if_exists=(v : Bool)
      LibLevelDB.options_set_error_if_exists(handle, v ? 1_u8 : 0_u8)
      v
    end

    def error_if_exists(v : Bool)
      self.error_if_exists = v
      self
    end

    def paranoid_checks=(v : Bool)
      LibLevelDB.options_set_paranoid_checks(handle, v ? 1_u8 : 0_u8)
      v
    end

    def paranoid_checks(v : Bool)
      self.paranoid_checks = v
      self
    end

    def write_buffer_size=(size : Int)
      LibLevelDB.options_set_write_buffer_size(handle, size.to_u64)
      size
    end

    def write_buffer_size(size : Int)
      self.write_buffer_size = size
      self
    end

    def max_open_files=(n : Int)
      LibLevelDB.options_set_max_open_files(handle, n.to_i)
      n
    end

    def max_open_files(n : Int)
      self.max_open_files = n
      self
    end

    def block_size=(size : Int)
      LibLevelDB.options_set_block_size(handle, size.to_u64)
      size
    end

    def block_size(size : Int)
      self.block_size = size
      self
    end

    def block_restart_interval=(n : Int)
      LibLevelDB.options_set_block_restart_interval(handle, n.to_i)
      n
    end

    def block_restart_interval(n : Int)
      self.block_restart_interval = n
      self
    end

    def max_file_size=(size : Int)
      LibLevelDB.options_set_max_file_size(handle, size.to_u64)
      size
    end

    def max_file_size(size : Int)
      self.max_file_size = size
      self
    end

    def compression=(c : LibLevelDB::Compression | Int32)
      LibLevelDB.options_set_compression(handle, c.to_i)
      c
    end

    def compression(c : LibLevelDB::Compression | Int32)
      self.compression = c
      self
    end
  end

  class ReadOptions < Handle(LibLevelDB::ReadOptions)
    def initialize
      super LibLevelDB.readoptions_create
    end

    def finalize
      return if @handle.nil?
      LibLevelDB.readoptions_destroy(@handle.not_nil!)
    end

    def verify_checksums=(v : Bool)
      LibLevelDB.readoptions_set_verify_checksums(handle, v ? 1_u8 : 0_u8)
      v
    end

    def verify_checksums(v : Bool)
      self.verify_checksums = v
      self
    end

    def fill_cache=(v : Bool)
      LibLevelDB.readoptions_set_fill_cache(handle, v ? 1_u8 : 0_u8)
      v
    end

    def fill_cache(v : Bool)
      self.fill_cache = v
      self
    end

    def snapshot=(snap : LibLevelDB::Snapshot)
      LibLevelDB.readoptions_set_snapshot(handle, snap)
      snap
    end

    def snapshot(snap : LibLevelDB::Snapshot)
      self.snapshot = snap
      self
    end
  end

  class WriteOptions < Handle(LibLevelDB::WriteOptions)
    def initialize
      super LibLevelDB.writeoptions_create
    end

    def finalize
      return if @handle.nil?
      LibLevelDB.writeoptions_destroy(@handle.not_nil!)
    end

    def sync=(v : Bool)
      LibLevelDB.writeoptions_set_sync(handle, v ? 1_u8 : 0_u8)
      v
    end

    def sync(v : Bool)
      self.sync = v
      self
    end
  end
end
