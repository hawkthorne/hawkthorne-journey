return {
  name = 'frog',
  die_sound = 'karramba_pop',
  position_offset = { x = 0, y = 3 },
  height = 48,
  width = 48,
  damage = 20,
  hp = 1,
  antigravity = true,
  animations = {
    dying = {
      right = {'once', {'5-8,2'}, 0.2},
      left = {'once', {'5-8,1'}, 0.2}
    },
    default = {
      right = {'loop', {'1,2'}, 1},
      left = {'loop', {'1,1'}, 1}
    },
    hurt = {
      right = {'loop', {'1,2'}, 1},
      left = {'loop', {'1,1'}, 1}
    },
    emerge = {
      right = {'loop', {'2,2'}, 1},
      left = {'loop', {'2,1'}, 1}
    },
    dive = {
      right = {'loop', {'2,2'}, 1},
      left = {'loop', {'2,1'}, 1}
    },
    fall = {
      right = {'loop', {'4,2'}, 1},
      left = {'loop', {'4,1'}, 1}
    },
    leap = {
      right = {'loop', {'3,2'}, 1},
      left = {'loop', {'3,1'}, 1}
    }
  },
  enter = function( enemy )
    if enemy.count == nil then
      enemy.count = tonumber(enemy.node_properties.count) or 0
    else
      enemy.count = 0
    end
  end,
  update = function( dt, enemy, player )
    if enemy.position.x > player.position.x then
      enemy.direction = 'left'
    else
      enemy.direction = 'right'
    end

    if enemy.state == 'default' then
      if enemy.count < 30 then
        enemy.count = enemy.count + (10 * dt)
      else
        enemy.count = 0
        enemy.state = 'emerge'
      end
    elseif enemy.state == 'emerge' then
      if enemy.count < 2 then
        enemy.count = enemy.count + (10 * dt)
      else
        enemy.count = 0
        enemy.state = 'leap'
      end
    elseif enemy.state == 'leap' then
      if enemy.position.y > ( enemy.node.y + 3 ) - 80 then
        enemy.position.y = enemy.position.y - (100 * dt)
      else
        enemy.state = 'fall'
      end
    elseif enemy.state == 'fall' then
      if enemy.position.y < ( enemy.node.y + 3 ) then
        enemy.position.y = enemy.position.y + (100 * dt)
      else
        enemy.state = 'dive'
      end
    elseif enemy.state == 'dive' then
      if enemy.count < 2 then
        enemy.count = enemy.count + (10 * dt)
      else
        enemy.count = 0
        enemy.state = 'default'
      end
    end
  end
}
