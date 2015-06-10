local Timer = require 'vendor/timer'
local Dialog = require 'dialog'

return {
  width = 32,
  height = 32,  
  greeting = 'Bah! Go away.',
  animations = {
    default = {
      'loop',{'1,1','2,1'},.5,
    },
  },

 enter = function(npc, previous)
    local show = npc.db:get('acornKingVisible', false)
    local acornDead = npc.db:get("bosstriggers.acorn", true)
    local bldgburned = npc.db:get('house_building_burned', false )
    if show == true or bldgburned == true then
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
        script = {
          "Huh? You say the Acorn King plans on destroying this town? You are as crazy as those filthy, long-haired hippies living high up in the mountains.",
          "Get out of here young man, my life is hard enough without you crazy hipies stirring trouble up!",
          "Alright, fine, I suppose there's no harm in indulging you in your crazy hippie-talk. So you want to know how to defeat the Acorn?",
          "In the {{orange}}abandoned mine{{white}} up in the mountains, is a local cult who are said to worship Cornelius and his creatures.",
          "It's supposed to contain numerous secrets such as the map to the Acorn King's hideout and ways to defeat him.",
          "Now I don't know if the rumors are true or not, but it's definitely worth checking out.",
          "Alright, now get out of my sight, I've got better things to be doing than talking to you.",
        }
        Dialogue = Dialog.create(script)
        Dialogue:open(function()
          Dialog.finished = true
          player.quest = 'To Slay An Acorn - Explore the Mines for a Map to the Acorn King'
          player.freeze = false 
          player.minesDoor = true
        end)

        npc.menu:close(player)

        player.freeze = true
        npc.prompt = nil
        Timer.add(2, function()
          npc.fixed = false
        end)
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
}