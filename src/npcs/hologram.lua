-- inculdes
local Dialog = require 'dialog'
local app = require 'app'
local sound = require 'vendor/TEsound'

return {
  width = 48,
  height = 61,
  animations = {
    default = {
      'once',{'1,1'},.25,
    },
    pierce = {
      'loop',{'2-6,1'},.15,
    },
    drugs = {
      'loop',{'7-8,1', '1-3,2'},.25,
    },
    laser = {
      'loop',{'4-8,1'},.25,
    },
  },
  begin = function(npc, player)
    npc.menu.state = 'closing'
    local script ={
    "Looks as if you've lost your way.",
    "Continue on this path, and you might miss your last chance to see the Pierce Hawthorne Museum of Gender Sensitivity and Sexual Potency on the central quad.",
    "The museum and this hologram were donated in compliance with a court order I'm not allowed to discuss.",
    "What I am allowed to discuss is Greendale, and I'll say this...  Don't turn your back on it.",
    "Take it from a man with no legal right to be there. You're in a special place.",
    "A crappy place, sure, but only because it gives crappy people a chance to sort themselves out.",
    "Did I sound gay at the end?  Do you want to do another take?",
    }
    if npc.db:get('hologram-pierce', false) or npc.db:get('hologram-drugs', false) or npc.db:get('hologram-laser', false) then
      sound.playMusic("greendales-the-way-it-goes")
      Dialog.new(script, function()
            player.freeze = false
            npc.menu:close(player)
            sound.stopMusic()
            sound.playSfx("greendale")
          end)
    else
    	local script = {"This almost looks like the platform to some kind of hologram...",
    					"It seems broken though, maybe the bursar knows when it will be fixed."
    					}
      Dialog.new(script, function()
          player.freeze = false
          npc.menu:close(player)
        end)
    end
  end,
  
  update = function(dt, npc, player)
    if npc.db:get('hologram-pierce', false)  then
      npc.state = 'pierce'
    elseif npc.db:get('hologram-drugs', false)  then
      npc.state = 'drugs'
    elseif npc.db:get('hologram-laser', false)  then
        npc.state = 'laser'
    end

  end,
}
