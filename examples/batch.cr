require "../src/leveldb"

# WriteBatch usage example
db_path = "/tmp/leveldb_example_batch"

puts "=== WriteBatch Example ==="

LevelDB::DB.open(db_path, LevelDB::Options.new.create_if_missing(true)) do |db|
  # Using WriteBatch.build for atomic operations
  batch = LevelDB::WriteBatch.build do |b|
    b.put("user:1:name", "Alice")
    b.put("user:1:age", "25")
    b.put("user:2:name", "Bob")
    b.put("user:2:age", "30")
    b.delete("old_key") # Delete if exists
  end

  # Write batch atomically
  db.write(batch)
  batch.close

  puts "After batch write:"
  puts "  user:1:name => #{db["user:1:name"]}"
  puts "  user:1:age => #{db["user:1:age"]}"
  puts "  user:2:name => #{db["user:2:name"]}"
  puts "  user:2:age => #{db["user:2:age"]}"
end

puts "\n✓ Example completed successfully"
