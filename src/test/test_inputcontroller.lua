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

function test_remap_persistence()
    local c1 = InputController.new()
    local c2 = InputController.new()

    assert_equal(c1:isRemapping(), false)
    assert_equal(c2:isRemapping(), false)

    c1:enableRemap()
    assert_equal(c1:isRemapping(), true)
    assert_equal(c2:isRemapping(), true)

    c2:disableRemap()
    assert_equal(c1:isRemapping(), false)
    assert_equal(c2:isRemapping(), false)
end

function test_get()
    local c1 = InputController.get('somename')
    local c2 = InputController.get('somename')

    assert_equal(c1, c2)

    c1:newAction('x', 'ATTACK')
    assert_equal(c2:getAction('x'), 'ATTACK')
end
