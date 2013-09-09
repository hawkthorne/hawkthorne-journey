local Player = require 'player'
Player.refreshPlayer = function() end -- Stubs refreshPlayer to avoid dependencies

player = Player.factory() -- Create test player

local cheat = require 'src/cheat'

-- it should toggle 'jump_high' on and off with correct values
function test_toggle_jump_high()
    cheat:toggle('jump_high')
    assert_equal(1.44, player.jumpFactor)
    assert_true(cheat:is('jump_high'))
    cheat:toggle('jump_high')
    assert_equal(1.00, player.jumpFactor)
end

-- it should give 500 coins on 'give_money'
function test_give_money()
    cheat:on('give_money')
    assert_equal(500, player.money)
end

-- it should 'give_taco_meat'
function test_give_taco_meat()
    cheat:on('give_taco_meat')
    assert_equal('tacomeat', player.inventory.pages.consumables[0].name)
end

-- it should 'unlock_levels', filling player.visitedLevels appropriately
function test_unlock_levels()
    cheat:on('unlock_levels')
    assert_equal(12, #player.visitedLevels)
end
