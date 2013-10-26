local character = require "src/character"

--Should fail
function test_pick_unknown_character() 
  assert_error(function() 
    character.pick('unknown', 'base')
  end, "Unknown character should fail")
end

function test_pick_unknown_costume() 
  assert_error(function() 
    character.pick('abed', 'unknown')
  end, "Unknown character should fail")
end

function test_pick_known_combination() 
  character.pick('abed', 'base')
end

function test_load_unknown_character() 
  assert_error(function() 
    character.load('unknown')
  end, "Unknown character should fail")
end

function test_load_abed() 
  local abed = character.load('abed')
  assert_equal(abed.name, 'abed')
end



