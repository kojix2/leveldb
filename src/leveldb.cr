require "./leveldb/lib_leveldb"
require "./leveldb/errors"
require "./leveldb/options"
require "./leveldb/db"
require "./leveldb/iterator"
require "./leveldb/write_batch"

module LevelDB
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
