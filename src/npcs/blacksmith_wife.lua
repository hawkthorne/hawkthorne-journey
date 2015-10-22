-- inculdes
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Emotion = require 'nodes/emotion'
local Quest = require 'quest'
local quests = require 'npcs/quests/wifequest'

return {
  width = 48,
  height = 48,  
  special_items = {'throwingtorch'},
  run_offsets = {{x=0, y=0}, {x=190, y=0}},
  run_speed = 100,
  animations = {
    default = {
      'loop',{'1,1','2,1'},.5,
    },
    hurt = {
      'loop',{'1-4, 2'}, 0.20,
    },
    dying = {
      'once',{'3-4,1'}, 0.15,
    },
    exclaim = {
      'loop',{'1-4, 3'}, 0.20,
    },
    yelling = {
      'loop',{'1-4, 3'}, 0.20,
    },
    crying = {
      'loop',{'1-3, 4'}, 0.20,
    },
  },

  noinventory = "Talk to my husband to about supplies.",
  enter = function(npc, previous)
    local dead = npc.db:get('blacksmith_wife-dead', false)

    if Gamestate.currentState().name == "blacksmith" then
      local blacksmith = npc.db:get('blacksmith-dead', false)
      if blacksmith then
        if dead ~= false then
          npc:show_death()

          return
        else
          -- The wife should be crying next to the blacksmith
          npc.state = 'crying'
          npc.position.x = blacksmith.position.x - (npc.width / 2)
        end
      else
        npc.busy = true
        npc.state = 'hidden'
      end
      return
    end

    if npc.db:get('blacksmith-dead', false) and Gamestate.currentState().name == "blacksmith-upstairs" then
      npc.busy = true
      npc.state = 'hidden'
      return
    end
    
    if previous and previous.name ~= 'town' then
      return
    end

  end,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Any useful info for me?' },
    { ['text']='Anything happening here?' },
    { ['text']='Hello!' },
  },
  talk_commands = {
    ['Hello!'] = function (npc, player)
      Quest:activate(npc, player, quests.mushroom)
    end,
  },
  talk_responses = {
    
    ["Anything happening here?"]={
      "I've been trying to convince my husband to build us a new home. I keep telling him it's a terrible idea to have his workshop inside a wooden house!",
    },
    ["Any useful info for me?"]={
      "My husband is the best blacksmith around. He can help you stock up on supplies before venturing into the woods.",
    },
  },

  collide = function(npc, node, dt, mtv_x, mtv_y)
    if npc.state == 'hurt' and node.hurt then
      -- 5 is minimum player damage
      node:hurt(5)
    end
  end,

  hurt = function(npc, special_damage, knockback)
    -- Wife reacts when getting hit while dead
    if npc.dead then
      npc:animation():restart()
    end
    
    -- Only accept torches or similar for burning the wife
    if not special_damage or special_damage['fire'] == nil then return end
    
    -- Wife will be yelling after she panics seeing the dead blacksmith
    if npc.state == 'yelling' or npc.state == 'crying' then
      -- Wife is now on fire
      npc.state = 'hurt'
      -- The flames will kill the wife if the player doesn't
      -- Add a bit of randomness so the wife doesn't always fall in the same place
      Timer.add(2 + math.random(), function() npc.props.die(npc) end)
      -- Save position and direction now before they leave the level
      npc:store_death()
    elseif npc.state == 'hurt' then
      npc.props.die(npc)
    end
  end,

  update = function(dt, npc, player)
    if npc.state == 'yelling' or npc.state == 'hurt' then
      npc.busy = true
      npc:run(dt, player)
    end
  end,

  panic = function(npc, player)
    Timer.add(0.5, function()
      npc.emotion = Emotion.new(npc, "exclaim")
    end)
    npc.run_offsets = {{x=10, y=60}, {x=-10, y=125}, {x=-60, y=125}, {x=130, y=125}}
    Timer.add(1.5, function()
      npc.emotion = Emotion.new(npc)
      npc.state = 'yelling'
      -- If the wife hasn't been killed after 8 seconds, she stops running and cries
      Timer.add(8, function()
        if npc.dead ~= true then
          npc.state = 'crying'
        end
      end)
    end)
  end,

  die = function(npc, player)
    npc.dead = true
    npc.state = 'dying'
    npc:store_death()
  end,
}