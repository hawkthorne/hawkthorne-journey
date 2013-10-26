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
