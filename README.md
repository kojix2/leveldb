# LevelDB.cr

[![CI](https://github.com/kojix2/leveldb/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/leveldb/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fleveldb%2Flines)](https://tokei.kojix2.net/github/kojix2/leveldb)
![Static Badge](https://img.shields.io/badge/PURE-VIBE_CODING-magenta)

Crystal bindings for Google LevelDB

## Requirements

- macOS: `brew install leveldb`
- Ubuntu/Debian: `sudo apt-get install -y libleveldb-dev`

## Install

Add to `shard.yml`:

```yaml
dependencies:
  leveldb:
    github: kojix2/leveldb
```

Then install:

```sh
shards install
```

## Quick start

```crystal
require "leveldb"

# Using keyword arguments
opts = LevelDB::Options.new(create_if_missing: true)

LevelDB::DB.open("/tmp/mydb", opts) do |db|
  db.put "hello", "world"
  db["hello"]           # => "world"
  db.delete "hello"
  db["hello"]           # => nil
end
```

### Options

Configure LevelDB with keyword arguments:

```crystal
opts = LevelDB::Options.new(
  create_if_missing: true,
  write_buffer_size: 4 * 1024 * 1024,
  max_open_files: 100,
  compression: LevelDB::LibLevelDB::Compression::SnappyCompression
)
```

Or use setters after initialization:

```crystal
opts = LevelDB::Options.new
opts.create_if_missing = true
opts.write_buffer_size = 4 * 1024 * 1024
```

### Iterate

```crystal
opts = LevelDB::Options.new(create_if_missing: true)

LevelDB::DB.open("/tmp/mydb", opts) do |db|
  # Simple iteration
  db.each_string { |k, v| puts "#{k} => #{v}" }

  # Manual iteration with control
  db.iterator do |it|
    it.seek("b")
    while it.valid?
      puts "#{it.key_string} => #{it.value_string}"
      it.next
    end
    it.check_error
  end
end
```

### Batch

```crystal
opts = LevelDB::Options.new(create_if_missing: true)

LevelDB::DB.open("/tmp/mydb", opts) do |db|
  batch = LevelDB::WriteBatch.build do |b|
    b.put "user:1", "Alice"
    b.put "user:2", "Bob"
    b.delete "old"
  end
  db.write batch
  batch.close
end
```

### Snapshots

```crystal
opts = LevelDB::Options.new(create_if_missing: true)

LevelDB::DB.open("/tmp/mydb", opts) do |db|
  db.put "key", "version1"
  snapshot = db.create_snapshot

  db.put "key", "version2"

  # Read from snapshot
  read_opts = LevelDB::ReadOptions.new
  read_opts.snapshot = snapshot
  db.get_string("key", read_opts)  # => "version1"
  db.get_string("key")             # => "version2"

  db.release_snapshot(snapshot)
end
```

## Errors

On failure, methods raise `LevelDB::Error`.

## Tests

```sh
crystal spec
```
