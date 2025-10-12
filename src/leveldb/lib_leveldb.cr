module LevelDB
  @[Link("leveldb")]
  lib LibLevelDB
    # Opaque handle types (C opaque structs as void*)
    type DB = Void*
    type Cache = Void*
    type Comparator = Void*
    type Env = Void*
    type FileLock = Void*
    type FilterPolicy = Void*
    type Iterator = Void*
    type Logger = Void*
    type Options = Void*
    type RandomFile = Void*
    type ReadOptions = Void*
    type SeqFile = Void*
    type Snapshot = Void*
    type WritableFile = Void*
    type WriteBatch = Void*
    type WriteOptions = Void*

    # Enums
    enum Compression : Int32
      NoCompression     = 0
      SnappyCompression = 1
    end

    # Callback types
    # Comparator
    type ComparatorDestructor = (Pointer(Void) -> Void)
    type ComparatorCompare = (Pointer(Void), Pointer(LibC::Char), LibC::SizeT, Pointer(LibC::Char), LibC::SizeT -> Int32)
    type ComparatorName = (Pointer(Void) -> Pointer(LibC::Char))

    # Filter policy
    type FilterPolicyDestructor = (Pointer(Void) -> Void)
    type FilterPolicyCreateFilter = (Pointer(Void), Pointer(Pointer(LibC::Char)), Pointer(LibC::SizeT), Int32, Pointer(LibC::SizeT) -> Pointer(LibC::Char))
    type FilterPolicyKeyMayMatch = (Pointer(Void), Pointer(LibC::Char), LibC::SizeT, Pointer(LibC::Char), LibC::SizeT -> UInt8)
    type FilterPolicyName = (Pointer(Void) -> Pointer(LibC::Char))

    # Write batch iterate callbacks
    type WriteBatchPutCallback = (Pointer(Void), Pointer(LibC::Char), LibC::SizeT, Pointer(LibC::Char), LibC::SizeT -> Void)
    type WriteBatchDeletedCallback = (Pointer(Void), Pointer(LibC::Char), LibC::SizeT -> Void)

    # DB operations
    fun open = "leveldb_open"(options : Options, name : Pointer(LibC::Char), errptr : Pointer(Pointer(LibC::Char))) : DB
    fun close = "leveldb_close"(db : DB) : Void

    fun put = "leveldb_put"(db : DB,
                            options : WriteOptions,
                            key : Pointer(LibC::Char), keylen : LibC::SizeT,
                            val : Pointer(LibC::Char), vallen : LibC::SizeT,
                            errptr : Pointer(Pointer(LibC::Char))) : Void

    fun delete = "leveldb_delete"(db : DB,
                                  options : WriteOptions,
                                  key : Pointer(LibC::Char), keylen : LibC::SizeT,
                                  errptr : Pointer(Pointer(LibC::Char))) : Void

    fun write = "leveldb_write"(db : DB,
                                options : WriteOptions,
                                batch : WriteBatch,
                                errptr : Pointer(Pointer(LibC::Char))) : Void

    fun get = "leveldb_get"(db : DB,
                            options : ReadOptions,
                            key : Pointer(LibC::Char), keylen : LibC::SizeT,
                            vallen_out : Pointer(LibC::SizeT),
                            errptr : Pointer(Pointer(LibC::Char))) : Pointer(LibC::Char)

    fun create_iterator = "leveldb_create_iterator"(db : DB, options : ReadOptions) : Iterator
    fun create_snapshot = "leveldb_create_snapshot"(db : DB) : Snapshot
    fun release_snapshot = "leveldb_release_snapshot"(db : DB, snapshot : Snapshot) : Void

    fun property_value = "leveldb_property_value"(db : DB, propname : Pointer(LibC::Char)) : Pointer(LibC::Char)

    fun approximate_sizes = "leveldb_approximate_sizes"(db : DB,
                                                        num_ranges : Int32,
                                                        range_start_key : Pointer(Pointer(LibC::Char)),
                                                        range_start_key_len : Pointer(LibC::SizeT),
                                                        range_limit_key : Pointer(Pointer(LibC::Char)),
                                                        range_limit_key_len : Pointer(LibC::SizeT),
                                                        sizes : Pointer(UInt64)) : Void

    fun compact_range = "leveldb_compact_range"(db : DB,
                                                start_key : Pointer(LibC::Char), start_key_len : LibC::SizeT,
                                                limit_key : Pointer(LibC::Char), limit_key_len : LibC::SizeT) : Void

    # Management operations
    fun destroy_db = "leveldb_destroy_db"(options : Options, name : Pointer(LibC::Char), errptr : Pointer(Pointer(LibC::Char))) : Void
    fun repair_db = "leveldb_repair_db"(options : Options, name : Pointer(LibC::Char), errptr : Pointer(Pointer(LibC::Char))) : Void

    # Iterator
    fun iter_destroy = "leveldb_iter_destroy"(it : Iterator) : Void
    fun iter_valid = "leveldb_iter_valid"(it : Iterator) : UInt8
    fun iter_seek_to_first = "leveldb_iter_seek_to_first"(it : Iterator) : Void
    fun iter_seek_to_last = "leveldb_iter_seek_to_last"(it : Iterator) : Void
    fun iter_seek = "leveldb_iter_seek"(it : Iterator, k : Pointer(LibC::Char), klen : LibC::SizeT) : Void
    fun iter_next = "leveldb_iter_next"(it : Iterator) : Void
    fun iter_prev = "leveldb_iter_prev"(it : Iterator) : Void
    fun iter_key = "leveldb_iter_key"(it : Iterator, klen_out : Pointer(LibC::SizeT)) : Pointer(LibC::Char)
    fun iter_value = "leveldb_iter_value"(it : Iterator, vlen_out : Pointer(LibC::SizeT)) : Pointer(LibC::Char)
    fun iter_get_error = "leveldb_iter_get_error"(it : Iterator, errptr : Pointer(Pointer(LibC::Char))) : Void

    # Write batch
    fun writebatch_create = "leveldb_writebatch_create" : WriteBatch
    fun writebatch_destroy = "leveldb_writebatch_destroy"(batch : WriteBatch) : Void
    fun writebatch_clear = "leveldb_writebatch_clear"(batch : WriteBatch) : Void
    fun writebatch_put = "leveldb_writebatch_put"(batch : WriteBatch,
                                                  key : Pointer(LibC::Char), klen : LibC::SizeT,
                                                  val : Pointer(LibC::Char), vlen : LibC::SizeT) : Void
    fun writebatch_delete = "leveldb_writebatch_delete"(batch : WriteBatch,
                                                        key : Pointer(LibC::Char), klen : LibC::SizeT) : Void
    fun writebatch_iterate = "leveldb_writebatch_iterate"(batch : WriteBatch,
                                                          state : Pointer(Void),
                                                          put : WriteBatchPutCallback,
                                                          deleted : WriteBatchDeletedCallback) : Void
    fun writebatch_append = "leveldb_writebatch_append"(destination : WriteBatch, source : WriteBatch) : Void

    # Options
    fun options_create = "leveldb_options_create" : Options
    fun options_destroy = "leveldb_options_destroy"(options : Options) : Void
    fun options_set_comparator = "leveldb_options_set_comparator"(options : Options, cmp : Comparator) : Void
    fun options_set_filter_policy = "leveldb_options_set_filter_policy"(options : Options, policy : FilterPolicy) : Void
    fun options_set_create_if_missing = "leveldb_options_set_create_if_missing"(options : Options, v : UInt8) : Void
    fun options_set_error_if_exists = "leveldb_options_set_error_if_exists"(options : Options, v : UInt8) : Void
    fun options_set_paranoid_checks = "leveldb_options_set_paranoid_checks"(options : Options, v : UInt8) : Void
    fun options_set_env = "leveldb_options_set_env"(options : Options, env : Env) : Void
    fun options_set_info_log = "leveldb_options_set_info_log"(options : Options, logger : Logger) : Void
    fun options_set_write_buffer_size = "leveldb_options_set_write_buffer_size"(options : Options, size : LibC::SizeT) : Void
    fun options_set_max_open_files = "leveldb_options_set_max_open_files"(options : Options, files : Int32) : Void
    fun options_set_cache = "leveldb_options_set_cache"(options : Options, cache : Cache) : Void
    fun options_set_block_size = "leveldb_options_set_block_size"(options : Options, size : LibC::SizeT) : Void
    fun options_set_block_restart_interval = "leveldb_options_set_block_restart_interval"(options : Options, interval : Int32) : Void
    fun options_set_max_file_size = "leveldb_options_set_max_file_size"(options : Options, size : LibC::SizeT) : Void
    fun options_set_compression = "leveldb_options_set_compression"(options : Options, c : Int32) : Void

    # Comparator
    fun comparator_create = "leveldb_comparator_create"(state : Pointer(Void), destructor : ComparatorDestructor, compare : ComparatorCompare, name : ComparatorName) : Comparator
    fun comparator_destroy = "leveldb_comparator_destroy"(cmp : Comparator) : Void

    # Filter policy
    fun filterpolicy_create = "leveldb_filterpolicy_create"(state : Pointer(Void), destructor : FilterPolicyDestructor, create_filter : FilterPolicyCreateFilter, key_may_match : FilterPolicyKeyMayMatch, name : FilterPolicyName) : FilterPolicy
    fun filterpolicy_destroy = "leveldb_filterpolicy_destroy"(policy : FilterPolicy) : Void
    fun filterpolicy_create_bloom = "leveldb_filterpolicy_create_bloom"(bits_per_key : Int32) : FilterPolicy

    # Read options
    fun readoptions_create = "leveldb_readoptions_create" : ReadOptions
    fun readoptions_destroy = "leveldb_readoptions_destroy"(options : ReadOptions) : Void
    fun readoptions_set_verify_checksums = "leveldb_readoptions_set_verify_checksums"(options : ReadOptions, v : UInt8) : Void
    fun readoptions_set_fill_cache = "leveldb_readoptions_set_fill_cache"(options : ReadOptions, v : UInt8) : Void
    fun readoptions_set_snapshot = "leveldb_readoptions_set_snapshot"(options : ReadOptions, snapshot : Snapshot) : Void

    # Write options
    fun writeoptions_create = "leveldb_writeoptions_create" : WriteOptions
    fun writeoptions_destroy = "leveldb_writeoptions_destroy"(options : WriteOptions) : Void
    fun writeoptions_set_sync = "leveldb_writeoptions_set_sync"(options : WriteOptions, v : UInt8) : Void

    # Cache
    fun cache_create_lru = "leveldb_cache_create_lru"(capacity : LibC::SizeT) : Cache
    fun cache_destroy = "leveldb_cache_destroy"(cache : Cache) : Void

    # Env
    fun create_default_env = "leveldb_create_default_env" : Env
    fun env_destroy = "leveldb_env_destroy"(env : Env) : Void
    fun env_get_test_directory = "leveldb_env_get_test_directory"(env : Env) : Pointer(LibC::Char)

    # Utility
    fun free = "leveldb_free"(ptr : Void*) : Void
    fun major_version = "leveldb_major_version" : Int32
    fun minor_version = "leveldb_minor_version" : Int32
  end
end
