return {
  name = 'mannequin',
  die_sound = 'mannequin_death',
  height = 48,
  width = 48,
  bb_width = 20,
  bb_height = 40,
  bb_offset = {x=0, y=4},
  damage = 20,
  hp = 3,
  speed = 75,
  vulnerabilities = {'blunt'},
  tokens = 3,
  tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
    { item = 'coin', v = 1, p = 0.9 },
    { item = 'health', v = 1, p = 1 }
  },
  animations = {
    default = {
      right = {'loop', {'1,2'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
    hurt = {
      right = {'loop', {'1,2'}, 0.25},
      left = {'loop', {'1,1'}, 0.25}
    },
    move = {
      right = {'loop', {'1-3,2'}, 0.25},
      left = {'loop', {'1-3,1'}, 0.25}
    },
    attack = {
      right = {'loop', {'4-5,2'}, 0.25},
      left = {'loop', {'4-5,1'}, 0.25}
    },
    dying = {
      right = {'once', {'6,1'}, 1},
      left = {'once', {'6,1'}, 1}
    }
  },
  update = function( dt, enemy, player )
    if enemy.state == 'attack' then return end

    --if player.position.y + player.height - 5 <= enemy.position.y + enemy.props.height and
       if math.abs(enemy.position.x - player.position.x) < 100 then
        enemy.state = 'move' 
        enemy.direction = 'right'
        if enemy.position.x > player.position.x then
          enemy.direction = 'left'
        end
    else  
    -- if neither continue to wait
       enemy.state = 'default'
       enemy.velocity.x = 0 
    end

    if math.abs(enemy.position.x - player.position.x) < 2 then
      -- stay put if very close to player
      enemy.velocity.x = 0
    elseif enemy.state == 'move' then
      local direction = enemy.direction == 'left' and 1 or -1
      enemy.velocity.x =  direction * enemy.props.speed
    else 
      -- otherwise stay still
      enemy.velocity.x = 0
    end
  end
}
