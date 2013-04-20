-- This object represents the DropBear when it has dropped from a tree, and is now on the ground
return {
    name = 'dropbear',
    die_sound = 'hippy_kill', -- TODO
    height = 48,
    width = 48,
    bb_width = 48,
    bb_height = 48,
    bb_offset = {x=0, y=0},
    damage = 2,
    hp = 10,
    tokens = 3,
    speed = 25,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
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
        if enemy.floor then
            if enemy.position.y < enemy.floor then
                enemy.position.y = enemy.position.y + dt * enemy.props.dropspeed
            else
                enemy.position.y = enemy.floor
            end
        end
    end
}
