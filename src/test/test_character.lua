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

function test_load_abed() 
  local found = false
  for _, name in pairs(character.characters()) do
    if name == 'abed' then
      found = true
    end
  end

  assert_true(found, "Couldn't find Abed in characters")
end

function test_load_current() 
  local character = character.current()
  assert_equal(character.name, 'abed')
end

function test_load_current() 
  local character = character.current()
  character.state = 'walk'
  character.direction = 'left'

  character:reset()

  assert_equal(character.state, 'idle')
  assert_equal(character.direction, 'right')
end

function test_find_unrelated_costume()
  local c = character.findRelatedCostume('abed', 'unknown_category')
  assert_equal(c, 'base')
end

function test_find_related_costume()
  local c = character.findRelatedCostume('abed', 's1e7')
  assert_equal(c, 'batman')
end
