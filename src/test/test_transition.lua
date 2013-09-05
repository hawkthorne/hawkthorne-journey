local transition = require "src/transition"

-- it should create a new transition
function test_transition_new()
  local newTrasition = transition.new('fade', 0.5)
  assert_false(newTrasition:finished())
end

-- it should finish after a certain time
function test_transition_time()
  local newTrasition = transition.new('fade', 0.5)
  newTrasition:update(1)
  assert_false(newTrasition:finished())
end

-- it should go forward
function test_transition_go_forward()
  local newTrasition = transition.new('fade', 0.5)
  newTrasition:forward()
  assert_equal(newTrasition.count, 0)
end

-- it should go backward
function test_transition_go_backward()
  local newTrasition = transition.new('fade', 0.5)
  newTrasition:backward()
  assert_equal(newTrasition.count, 0)
end
