require "./leveldb/*"

module LevelDB
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
