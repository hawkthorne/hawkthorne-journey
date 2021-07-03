-- inculdes
local prompt = require 'prompt'
local Dialog = require 'dialog'
local app = require 'app'

return {
  width = 24,
  height = 34,
  animations = {
    default = {
      'loop',{'1-4,1','1-4,2'},.25,
    },
  },
  begin = function(npc, player)
    npc.menu.state = 'closing'
    if npc.db:get('sandwich-curtain', false) then
      Dialog.new("Enjoy the special. *wink*", function()
          player.freeze = false
          npc.menu:close(player)
        end)
    else
      npc.prompt = prompt.new("Welcome to {{yellow}}Shirley's Sandwiches{{white}}. Would you like to try {{olive}}The Special?{{white}}", function(result)
        if result == 'Yes' then
          Dialog.new("{{olive}}The Specials{{white}} are kept in the back.", function()
            Dialog.currentDialog = nil
            npc.menu:close(player)
            npc.db:set('sandwich-curtain', true)
          end)
        else
          npc.menu:close(player)
        end
      end)
    end
  end,
}
