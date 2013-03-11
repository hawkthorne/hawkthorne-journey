return {
    name = 'bat',
    attack_sound = 'acorn_growl',--need new sound
    die_sound = 'acorn_crush',--need new sound
    position_offset = { x = 0, y = 0 },
    height = 22,
    width = 30,
    bb_width = 10,
    bb_height = 18,
    bb_offset = {x=0, y=-2},
    damage = 1,
    hp = 1,
    jumpkill = false,
    antigravity = true,
    dyingdelay = 5,
    tokens = 1,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'life', v = 1, p = 1 },
    },
    animations = {
        dying = { -- same as dive
            right = {'once', {'2,1'}, 1},
            left = {'once', {'2,1'}, 1}
        },
        default = { --hanging
            right = {'once', {'1,1'}, 1},
            left = {'once', {'1,1'}, 1}
        },
        dive = {
            right = {'once', {'2,1'}, 1},
            left = {'once', {'2,1'}, 1}
        },
        flying = {
            right = {'loop', {'3-5,1'}, 0.2},
            left = {'loop', {'3-5,1'}, 0.2}
        }
    },
    enter = function( enemy )
        enemy.swoop_speed = 200
        enemy.fly_speed = 100
        enemy.swoop_distance = 150
    end,
    update = function( dt, enemy, player, level )
        if enemy.state == 'dive' then
            enemy.position.y = enemy.position.y + dt * enemy.swoop_speed
            enemy.position.x = enemy.position.x + ( dt * ( enemy.swoop_speed / 2 ) * enemy.fly_dir )
            if enemy.launch_y + enemy.swoop_distance < enemy.position.y then
                enemy.state = 'flying'
            end
        elseif enemy.state == 'flying' then
            enemy.position.y = enemy.position.y - dt * enemy.fly_speed
            enemy.position.x = enemy.position.x + ( dt * ( enemy.swoop_speed / 2 ) * enemy.fly_dir )
        elseif enemy.state == 'default' and player.position.y <= enemy.position.y + 100 then
            if player.position.x < enemy.position.x then
                -- player is to the right
                if player.position.x + player.width + 50 >= enemy.position.x then
                    enemy.state = 'dive'
                    enemy.fly_dir = -1
                    enemy.launch_y = enemy.position.y
                end
            else
                -- player is to the left
                if player.position.x - 50 <= enemy.position.x + enemy.width then
                    enemy.state = 'dive'
                    enemy.fly_dir = 1
                    enemy.launch_y = enemy.position.y
                end
            end
        end
    end,
    ceiling_pushback = function( enemy, node, new_y )
        if enemy.state ~= 'default' then
            enemy.state = 'default'
            enemy.position.y = new_y
        end
    end,
    floor_pushback = function() end,
    dyingupdate = function( dt, enemy )
        enemy.position.y = enemy.position.y + dt * enemy.swoop_speed
    end
}
