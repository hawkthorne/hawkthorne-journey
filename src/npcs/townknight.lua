local utils = require 'utils'
local app = require 'app'
local Dialog = require 'dialog'
local Emotion = require 'nodes/emotion'

return {
  width = 70,
  --bb_width = 40,
  height = 55,
  run_offsets = {{x=5, y=0}, {x=-1200, y=0}, {x=-1190, y=0}},
  run_speed = 50,
  greeting = 'My name is {{red_light}}Sir Merek{{white}}, I became a knight to protect this {{olive}}village{{white}} from the dangers of the forest.',
  special_enemy = {'acornBoss'},
  animations = {
    default = {
      'loop',{'1,1'},.5,
    },
    walking = {
      'loop',{'1-4,1'},.2,
    },
    draw_sword = {
      'once',{'5-10,1'},.2,   
    },
    attack = {
      'loop',{'11-12,1'},.2,   
    },
  },

  stare = true,
  enter = function(npc, previous)
    local show = npc.db:get('acornKingVisible', false)
    local acornDead = npc.db:get("bosstriggers.acorn", true)
    local bldgburned = npc.db:get('blacksmith_building_burned', false )
    if show == true and not npc.hidden then 
        --[[npc.emotion = Emotion.new(npc, "exclaim")
      npc.angry = true
      npc.stare = false
      npc.state = 'attack'
      npc.attackingEnemy = true]]
      npc.state = 'walking'
      npc.walking = true
      npc.stare = false
      npc.collider:setGhost(npc.bb)
      npc.run_offsets = {{x=5, y=0}, {x=-1200, y=0}, {x=-1190, y=0}}
      npc.flee = true
      npc.hidden = true
    elseif bldgburned == true then
      npc.flee = false
      npc.state = 'hidden'
      npc.collider:setGhost(npc.bb)
    end
    
  end,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Any useful info for me?' },
    { ['text']='This town is in ruins!' },
    { ['text']='Talk about the Acorn King'},
  },
  talk_commands = {
    ['Talk about the Acorn King'] = function (npc, player)
      local check = npc.db:get("bosstriggers.acorn", false)
      if check ~= false then
          Dialog.new("Hooray to the great slayer of acorns! Thank you for saving us from destruction!", function()
          npc.menu:close(player)
        end)
      else
        Dialog.new("The Acorn King? Don't know lot about him. He popped out of nowhere a while ago, and brought those nasty little acorns with him.", function()
          npc.menu:close(player)
        end)
      end
      end,
  },
  talk_responses = {
    ["This town is in ruins!"]={
      "It's that damned {{grey}}Hawkthorne{{white}}! He's a madman, that's what he is.",
      "Just sitting in that ivory tower of his, it's his fault we're in shambles like this.",
    },
    ["Any useful info for me?"]={
      "I hear {{grey}}Castle Hawkthorne{{white}} holds untold riches, if anyone could get to them.",
      "One of them, I hear, is a key that unlocks a fabled world called {{olive}}Greendale{{white}}.",
      "Now there's what I call an adventure.",
    },

  },
  update = function(dt, npc, player)
    if npc.flee then
      npc:run(dt, player)
    end
  end,

}