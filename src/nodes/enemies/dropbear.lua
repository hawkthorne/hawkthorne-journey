local sound = require 'vendor/TEsound'

--[[ 
    This object represents a Dropbear (sprites courtesy of reddfawks)
    To add one to a map:
        First, add a node with a 'spawn' type
        Then the following properties should be set:
        Property Name       Property Value
           nodeType           enemy
           enemytype          dropbear
           initialState       dropping
           spawnType          smart/proximity
]]--
return {
    name = 'dropbear',
    die_sound = 'hippy_kill', -- TODO Need a kill sound
    spawn_sound = 'hippy_enter', -- TODO: Need a 'roar' sound
    height = 48,
    width = 48,
    bb_width = 48,
    bb_height = 48,
    bb_offset = {x=0, y=0},
    damage = 2,
    hp = 10,
    vulnerable = 'slash',
    tokens = 3,
    speed = 25,
    dropSpeed = 100,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dropping = {
            right = {'once', {'1,1'}, 1},
            left = {'once', {'1,1'}, 1}
        },
        dying = {
            right = {'loop', {'1-4,4'}, .1},
            left = {'loop', {'1-4,4'}, .1}
        },
        hurt = {
            right = {'once', {'4,2'}, 1},
            left = {'once', {'4,3'}, 1}
        },
        default = {
            right = {'loop', {'2-3,3'}, 0.25},
            left = {'loop', {'2-3,2'}, 0.25}
        },
        attack = {
            right = {'once', {'1,3'}, .1},
            left = {'once', {'1,2'}, .1}
        }
    },
    floor_pushback = function(enemy, node, new_y)
        -- Only set the state back to default the first time we get a pushback after dropping
        if ( enemy.state == 'dropping' ) then
            -- Once the DropBear hits the floor, transition to the normal walking state
            enemy.state = 'default'
        end

        enemy.position.y = new_y
        enemy.velocity.y = 0
        enemy:moveBoundingBox()
    end,
    update = function( dt, enemy, player )
        if enemy.position.x > player.position.x then
            enemy.direction = 'left'
        else
            enemy.direction = 'right'
        end

        if math.abs(enemy.position.x - player.position.x) < 2 or enemy.state == 'dying' or enemy.state == 'attack' or enemy.state == 'hurt' then
            -- stay put
        elseif enemy.direction == 'left' then
            enemy.position.x = enemy.position.x - (enemy.props.speed * dt)
        else
            enemy.position.x = enemy.position.x + (enemy.props.speed * dt)
        end
        if enemy.state == 'dropping' then
            enemy.position.y = enemy.position.y + dt * enemy.props.dropSpeed
        end
    end
}
