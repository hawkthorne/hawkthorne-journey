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
  damage = 10,
  hp = 1,
  vulnerabilities = {'blunt'},
  jumpkill = false,
  antigravity = true,
  dyingdelay = 5,
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 1 },
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
    hurt = {
      right = {'loop', {'3-5,1'}, 0.2},
      left = {'loop', {'3-5,1'}, 0.2}
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
    enemy.swoop_speed = 150
    enemy.fly_speed = 100
    enemy.swoop_distance = 150
    enemy.swoop_ratio = 0.5
  end,

  -- adjusts values needed to initialize bat swooping
  startDive = function ( enemy, player, direction )
    enemy.state = 'dive'
    enemy.fly_dir = direction
    enemy.launch_y = enemy.position.y
    enemy.swoop_distance = math.abs(player.position.y - enemy.position.y)
    enemy.swoop_ratio = math.abs(player.position.x - enemy.position.x) / enemy.swoop_distance
    -- experimentally determined max and min swoop_ratio values
    enemy.swoop_ratio = math.min(1.4, math.max(0.7, enemy.swoop_ratio))
  end,

  update = function( dt, enemy, player, level )
    if enemy.state == 'dive' then
      enemy.position.y = enemy.position.y + dt * enemy.swoop_speed
      -- swoop ratio used to center bat on target
      enemy.position.x = enemy.position.x + ( dt * ( enemy.swoop_speed * enemy.swoop_ratio ) * enemy.fly_dir )
      if enemy.launch_y + enemy.swoop_distance < enemy.position.y then
        enemy.state = 'flying'
      end
    elseif enemy.state == 'flying' then
      enemy.position.y = enemy.position.y - dt * enemy.fly_speed
      -- swoop ratio not needed because the bat is not moving to a specific target
      enemy.position.x = enemy.position.x + ( dt * ( enemy.swoop_speed / 2 ) * enemy.fly_dir )
    elseif enemy.state == 'default' and player.position.y <= enemy.position.y + 100 then
      if player.position.x < enemy.position.x then
        -- player is to the right
        if player.position.x + player.width + 50 >= enemy.position.x then
          enemy.props.startDive( enemy, player, -1 )
        end
      else
        -- player is to the left
        if player.position.x - 50 <= enemy.position.x + enemy.width then
          enemy.props.startDive( enemy, player, 1 )
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
