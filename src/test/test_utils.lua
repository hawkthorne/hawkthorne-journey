local utils = require "src/utils"

--should be -1 for a negative number
function test_sign_negvative() 
  assert_equal(utils.sign(-100), -1)
end

--should be 0 for a 0
function test_sign_zero()
  assert_equal(utils.sign(0), 0)
end
    
--should be 1 for a positive number
function test_sign_positive()
  assert_equal(utils.sign(100), 1)
end
    
--should round 1.4 to 1
function test_round_down()
  assert_equal(utils.round(1.4), 1)
end

--should round 1.5 to 2
function test_round_up()
  assert_equal(utils.round(1.5), 2)
end

--should split a string
function test_split_string()
  local output = utils.split("a a", " ")
  assert_equal(output[1], "a")
  assert_equal(output[2], "a")
end
