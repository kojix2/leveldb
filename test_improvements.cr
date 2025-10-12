require "./src/leveldb"

DB_PATH = "/tmp/leveldb_test_#{Time.utc.to_unix}"

puts "Test 1: Basic operations with closed? check"
begin
  options = LevelDB::Options.new
    .create_if_missing(true)
    .write_buffer_size(4 * 1024 * 1024)

  db = LevelDB::DB.new(DB_PATH, options)

  puts "DB closed? #{db.closed?}"

  db.put("key1", "value1")
  value = db.get_string("key1")
  puts "key1 = #{value}"

  db.put("key2", "value2")
  db.put("key3", "value3")

  db.close
  puts "DB closed? #{db.closed?}"
  puts "✓ Test 1 passed"
rescue ex
  puts "✗ Test 1 failed: #{ex.message}"
end

puts "\nTest 2: Iterator with each method"
begin
  options = LevelDB::Options.new.create_if_missing(true)
  db = LevelDB::DB.new(DB_PATH, options)

  db.put("a", "alpha")
  db.put("b", "beta")
  db.put("c", "gamma")

  puts "All key-value pairs:"
  db.each_string do |key, value|
    puts "  #{key} => #{value}"
  end

  db.close
  puts "✓ Test 2 passed"
rescue ex
  puts "✗ Test 2 failed: #{ex.message}"
end

puts "\nTest 3: Iterator method chaining"
begin
  options = LevelDB::Options.new.create_if_missing(true)
  db = LevelDB::DB.new(DB_PATH, options)

  iter = db.iterator
  puts "Iterator closed? #{iter.closed?}"

  iter.seek_to_first.next
  if iter.valid?
    puts "Second key: #{iter.key_string}"
  end

  iter.close
  puts "Iterator closed? #{iter.closed?}"

  db.close
  puts "✓ Test 3 passed"
rescue ex
  puts "✗ Test 3 failed: #{ex.message}"
end

puts "\nTest 4: Snapshot support"
begin
  options = LevelDB::Options.new.create_if_missing(true)
  db = LevelDB::DB.new(DB_PATH, options)

  db.put("snap_key", "version1")
  snapshot = db.create_snapshot

  db.put("snap_key", "version2")

  read_opts = LevelDB::ReadOptions.new.snapshot(snapshot)
  snap_value = db.get_string("snap_key", read_opts)
  current_value = db.get_string("snap_key")

  puts "Snapshot value: #{snap_value}"
  puts "Current value: #{current_value}"

  db.release_snapshot(snapshot)
  db.close
  puts "✓ Test 4 passed"
rescue ex
  puts "✗ Test 4 failed: #{ex.message}"
end

puts "\nTest 5: Database properties"
begin
  options = LevelDB::Options.new.create_if_missing(true)
  db = LevelDB::DB.new(DB_PATH, options)

  10.times do |i|
    db.put("prop_key_#{i}", "value_#{i}")
  end

  if stats = db.property("leveldb.stats")
    puts "Database stats available"
  end

  db.close
  puts "✓ Test 5 passed"
rescue ex
  puts "✗ Test 5 failed: #{ex.message}"
end

puts "\nAll tests completed!"
