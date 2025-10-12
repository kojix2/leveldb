# LevelDB.cr

Crystal bindings for Google LevelDB (thin FFI + small high-level wrapper).

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

opts = LevelDB::Options.build { |o| o.create_if_missing true }

LevelDB::DB.open("/tmp/mydb", opts) do |db|
  db.put "hello", "world"
  db["hello"]           # => "world"
  db.delete "hello"
  db["hello"]           # => nil
end
```

### Iterate

```crystal
LevelDB::DB.open("/tmp/mydb", opts) do |db|
  db.each_string { |k, v| puts "#{k} #{v}" }

  db.iterator do |it|
    it.seek("b")
    while it.valid?
      puts it.key_string
      it.next
    end
    it.check_error
  end
end
```

### Batch

```crystal
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

## Errors

On failure, methods raise `LevelDB::Error`.

## Tests

```sh
crystal spec
```
