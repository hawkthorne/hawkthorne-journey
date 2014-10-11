local tween = require "src/vendor/tween"

-- it should handle a zero dt value
function test_tween_zero_value()
  tween.update(0)
end

-- it should handle a negative value
function test_tween_negative_value()
  tween.update(-5)
end

function test_tween_hanlde_nil()
  tween.update(nil)
end

function test_tween_handle_anything()
  tween.update("fkajsdkfj")
end
