require "../src/leveldb"

# Basic usage example
db_path = "/tmp/leveldb_example_basic"

puts "=== Basic LevelDB Example ==="

# Using block-style open (recommended)
LevelDB::DB.open(db_path, LevelDB::Options.new.create_if_missing(true)) do |db|
  # Put a key-value pair
  db.put("hello", "world")
  db.put("foo", "bar")

  # Get values
  puts "hello => #{db["hello"]}"
  puts "foo => #{db["foo"]}"
  puts "missing => #{db["missing"].inspect}"

  # Delete a key
  db.delete("foo")
  puts "foo after delete => #{db["foo"].inspect}"
end

puts "✓ Example completed successfully"
