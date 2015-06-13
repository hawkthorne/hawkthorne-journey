local utils = require 'utils'
local Dialog = require 'dialog'
local app = require 'app'

return {
  width = 32,
  height = 48,  
  run_speed = 50,
  run_offsets = {{x=5, y=0}, {x=-1000, y=0}, {x=-990, y=0}},
  animations = {
    default = {
      'loop',{'1,1','11,1'},.5,
    },
    walking = {
      'loop',{'1,1','2,1','3,1'},.2,
    },
  },

  walking = true,
  --walk_speed = 36,

 enter = function(npc, previous)
    local show = npc.db:get('acornKingVisible', false)
    local acornDead = npc.db:get("bosstriggers.acorn", true)
    local bldgburned = npc.db:get('house_building_burned', false )
    if show == true and not npc.hidden then
      npc.state = 'walking'
      npc.collider:setGhost(npc.bb)
      npc.run_offsets = {{x=5, y=0}, {x=-1000, y=0}, {x=-990, y=0}}
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
    { ['text']='What are you carrying?'},
    { ['text']='This town is in ruins!' },
    { ['text']='Talk about the Acorn King'},
  },
  talk_commands = {
    ['Talk about the Acorn King'] = function (npc, player)
      npc.walking = false
      local check = app.gamesaves:active():get("bosstriggers.acorn", false)
      if check ~= false then
          Dialog.new("You saved us from the Acorn King! Thank you so much, adventurer!", function()
          npc.menu:close(player)
          npc.walking = true
        end)
      else
        Dialog.new("The Acorn King? He's a monster! It's because of the acorn infestation that we had to close the mines, it got too dangerous!", function()
          npc.menu:close(player)
          npc.walking = true
          end)
      end
      end,    
      },
  talk_responses = {
    ["This town is in ruins!"]={
      "Ever since that tyrant {{grey}}Hawkthorne{{white}} started ruling,",
      "our town started falling apart into pieces. If only he were overthrown!",
    },
    ["What are you carrying?"]={
      "It's a piece of wood. The town {{green_light}}blacksmith{{white}} needs it to make his weapons.",
      "You can find him at the last house on the street.",
    },
  },
  update = function(dt, npc, player)
    if npc.flee then
      npc:run(dt, player)
    end
  end,
}