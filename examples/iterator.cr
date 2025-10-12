require "../src/leveldb"

# Iterator usage example
db_path = "/tmp/leveldb_example_iterator"

puts "=== Iterator Example ==="

LevelDB::DB.open(db_path, LevelDB::Options.new(create_if_missing: true)) do |db|
  # Add some data
  db.put("apple", "red")
  db.put("banana", "yellow")
  db.put("cherry", "red")
  db.put("date", "brown")

  puts "\n1. Using each_string:"
  db.each_string do |key, value|
    puts "  #{key} => #{value}"
  end

  puts "\n2. Using iterator with block:"
  db.iterator do |it|
    it.seek_to_first
    puts "  First: #{it.key_string} => #{it.value_string}"

    it.seek_to_last
    puts "  Last: #{it.key_string} => #{it.value_string}"
  end

  puts "\n3. Manual iteration with method chaining:"
  it = db.iterator
  it.seek_to_first.next
  puts "  Second item: #{it.key_string} => #{it.value_string}"
  it.close
end

puts "\n✓ Example completed successfully"
