local utils = require 'utils'
local app = require 'app'
local Dialog = require 'dialog'

return {
  width = 32,
  height = 48,   
  greeting = 'My name is {{red_light}}Sir Merek{{white}}, I became a knight to protect this {{olive}}village{{white}} from the dangers of the forest.',
  animations = {
    default = {
      'loop',{'1,1','11,1'},.5,
    },
    walking = {
      'loop',{'1,1','2,1','3,1'},.2,
    },
  },

  stare = true,

  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Any useful info for me?' },
    { ['text']='This town is in ruins!' },
    { ['text']='Talk about the Acorn King'},
  },
  talk_commands = {
    ['Talk about the Acorn King'] = function (npc, player)
      local check = app.gamesaves:active():get("bosstriggers.acorn", false)
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
}