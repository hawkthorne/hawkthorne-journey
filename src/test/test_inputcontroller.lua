local InputController = require 'inputcontroller'

function test_init_no_args()
    local controls = InputController.new()
    local expected_actionmap = {
        UP = 'up',
        DOWN = 'down',
        LEFT = 'left',
        RIGHT = 'right',
        SELECT = 's',
        START = 'escape',
        JUMP = ' ',
        ATTACK = 'a',
        INTERACT = 'd',
    }
    for action, key in pairs(expected_actionmap) do
        assert_equal(controls.actionmap[action], key)
    end
end

function test_get_action()
    local controls = InputController.new()
    assert_equal(controls:getAction('d'), 'INTERACT')
end

function test_get_key()
    local controls = InputController.new()
    assert_equal(controls:getKey('INTERACT'), 'd')
end
