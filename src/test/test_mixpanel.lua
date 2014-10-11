local mixpanel = require "src/vendor/mixpanel"

--should be -1 for a negative number
function test_random_id() 
  assert_equal(#mixpanel.randomId(), 10)
end

function test_distinct_id() 
  love.filesystem.remove('mixpanel.txt')
  assert_equal(mixpanel.distinctId(), mixpanel.distinctId())
end

function test_distinct_id_len() 
  love.filesystem.remove('mixpanel.txt')
  assert_equal(#mixpanel.distinctId(), 10)
end

function test_distinct_id_source() 
  love.filesystem.write('mixpanel.txt', 'foo')
  assert_equal(mixpanel.distinctId(), 'foo')
  love.filesystem.remove('mixpanel.txt')
end

function test_randomness()
  assert_not_equal(mixpanel.randomId(), mixpanel.randomId())
end
