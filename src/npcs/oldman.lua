local Timer = require 'vendor/timer'
local Quest = require 'quest'
local quests = require 'npcs/quests/tildaquest'
local Dialog = require 'dialog'

return {
  width = 32,
  height = 32,  
  run_speed = 36,
  walking = true,
  run_offsets = {{x=5, y=0}, {x=-1000, y=0}, {x=-990, y=0}},
  greeting = 'Bah! Go away.',
  animations = {
    default = {
      'loop',{'9,1'},.5,
    },
    walking = {
      'loop',{'1-9,1'},.1,
    },
  },

 enter = function(npc, previous)
    local show = npc.db:get('acornKingVisible', false)
    local acornDead = npc.db:get("bosstriggers.acorn", true)
    local bldgburned = npc.db:get('house_building_burned', false )
    if show == true and not npc.hidden then 
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
    { ['text']='Any useful info for me?' },
    { ['text']='This town is in ruins!' },
    { ['text']='Hello!' },
  },
  talk_commands = {
    ['Hello!']=function(npc, player)
      npc.walking = false
      npc.stare = false
        
      if player.quest~='To Slay An Acorn - Ask Around the Village about the Acorn King' then
        Dialog.new("Piss off.", function()
          --npc.walking = true
          npc.menu:close(player)
        end)
      else
        player.quest = nil
        Quest.removeQuestItem(player)
        Quest:activate(npc, player, quests.explore_mines)
      end
    end,
  },
  talk_responses = {
    ["This town is in ruins!"]={
      "Piss off.",
    },
    ["Any useful info for me?"]={
      "Piss off, would ya?",
    },
  },
  update = function(dt, npc, player)
    if npc.flee== true then
      npc:run(dt, player)
    end
  end,
}