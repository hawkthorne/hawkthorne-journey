local queue = require("src/queue")

-- it should create a new queue
function test_queue_new()
  local q = queue.new()
end

-- it should let me push events
function test_queue_push_events()
  local q = queue.new()
  q:push('jump')
end

-- it should let me push events with arguments
function test_queue_events_arguments()
  local q = queue.new()
  q:push('jump', 1, 2)
end

-- it should let me push events with arguments
function test_queue_validate_arguments()
  local q = queue.new()
  q:push('jump', 1, 2)
  local f, x, y = q:poll('jump')
  assert_equal(f, true)
  assert_equal(x, 1)
  assert_equal(y, 2)
end

-- it should overwrite events
function test_queue_overwrite()
  local q = queue.new()
  q:push('jump', 1, 2)
  q:push('jump', 2, 3)
  local f, x, y = q:poll('jump')
  assert_equal(f, true)
  assert_equal(x, 2)
  assert_equal(y, 3)
end
