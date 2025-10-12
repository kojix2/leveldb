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
      GC.add_finalizer(self) { |obj| LibLevelDB.options_destroy(obj.handle) }
    end

    def create_if_missing=(v : Bool)
      LibLevelDB.options_set_create_if_missing(handle, v ? 1_u8 : 0_u8)
    end

    def error_if_exists=(v : Bool)
      LibLevelDB.options_set_error_if_exists(handle, v ? 1_u8 : 0_u8)
    end

    def paranoid_checks=(v : Bool)
      LibLevelDB.options_set_paranoid_checks(handle, v ? 1_u8 : 0_u8)
    end

    def write_buffer_size=(size : Int)
      LibLevelDB.options_set_write_buffer_size(handle, size.to_u64)
    end

    def max_open_files=(n : Int)
      LibLevelDB.options_set_max_open_files(handle, n.to_i)
    end

    def block_size=(size : Int)
      LibLevelDB.options_set_block_size(handle, size.to_u64)
    end

    def block_restart_interval=(n : Int)
      LibLevelDB.options_set_block_restart_interval(handle, n.to_i)
    end

    def max_file_size=(size : Int)
      LibLevelDB.options_set_max_file_size(handle, size.to_u64)
    end

    def compression=(c : LibLevelDB::Compression | Int32)
      LibLevelDB.options_set_compression(handle, c.to_i)
    end
  end

  class ReadOptions < Handle(LibLevelDB::ReadOptions)
    def initialize
      super LibLevelDB.readoptions_create
      GC.add_finalizer(self) { |obj| LibLevelDB.readoptions_destroy(obj.handle) }
    end

    def verify_checksums=(v : Bool)
      LibLevelDB.readoptions_set_verify_checksums(handle, v ? 1_u8 : 0_u8)
    end

    def fill_cache=(v : Bool)
      LibLevelDB.readoptions_set_fill_cache(handle, v ? 1_u8 : 0_u8)
    end

    def snapshot=(snap : LibLevelDB::Snapshot)
      LibLevelDB.readoptions_set_snapshot(handle, snap)
    end
  end

  class WriteOptions < Handle(LibLevelDB::WriteOptions)
    def initialize
      super LibLevelDB.writeoptions_create
      GC.add_finalizer(self) { |obj| LibLevelDB.writeoptions_destroy(obj.handle) }
    end

    def sync=(v : Bool)
      LibLevelDB.writeoptions_set_sync(handle, v ? 1_u8 : 0_u8)
    end
  end
end
