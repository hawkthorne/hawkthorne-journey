local sound = require 'vendor/TEsound'
local Timer = require('vendor/timer')
local tween = require 'vendor/tween'
local character = require 'character'
local Gamestate = require 'vendor/gamestate'
local utils = require 'utils'
require 'utils'
local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local prompt = require 'prompt'

return {
  width = 32,
  height = 32,  
  greeting = 'Bah! Go away.', 
  animations = {
    default = {
      'loop',{'1,1','2,1'},.5,
    },
  },

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='This town is in ruins!' },
        { ['text']='Talk about quests', freeze = true },
    },
    talk_commands = {
        ['Talk about quests']=function(npc, player)
                npc.walking = false
                npc.stare = false
            
            if player.quest ~= 'To Slay An Acorn - Collect Mushroom for the Old Man' and player.quest ~= 'To Slay An Acorn - Talk to Old Man in Village' then
            Dialog.new("Piss off.", function()
            --npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='To Slay An Acorn - Collect Mushroom for the Old Man' and not player.inventory:hasMaterial('greenmushroom') then
            Dialog.new("Huh, didn't get that mushroom yet? The mushroom grows in the treetops just before the border to the Valley of Laziness. Get going!", function()
            --npc.walking = true
            npc.menu:close(player)
            end) 
          elseif player.quest=='To Slay An Acorn - Collect Mushroom for the Old Man' and player.inventory:hasMaterial('greenmushroom') then

script2 = {
"Good, good, this mushroom will do nicely, great work...",
"Now piss off would ya?",
"Oh I suppose a promise is a promise...alright fine, I'll help you out.",
"First, you should know that the blasted Acorn King is invincible in his raging state, thanks to that tyrant Hawthorne's enchantments.",
"However, there had been rumors that a local cult group had managed to create a special weapon that could harm the Acorn King.",
"Those cultists have holed up in the abandoned mines up in the mountains, you should go there and see if you can obtain that weapon somehow.",
"Here's the key to the entrance of the mines. You'll have to be careful in there, it's gotten dangerous ever since it was abandoned.",
"Good luck eh? Now piss off.",
}
            
            local Dialogue2 = require 'dialog'
                  Dialogue2 = Dialog.create(script2)
                  Dialogue2:open(function()
                        Dialog.finished = true
                        player.freeze = false 
                        end)
              player.inventory:removeManyItems(1,{name='greenmushroom',type='material'})
              local Item = require 'items/item'
	            local itemNode = utils.require ('items/keys/mines')
	            local item = Item.new(itemNode, 1)
	            player.inventory:addItem(item)
              player.quest = 'To Slay An Acorn - Search for the Weapon in the mines'
              npc.menu:close(player)

            else
                    local Dialogue = require 'dialog'

                                       
                    
                     script = {
"Huh? You say you want to slay the Acorn King? Hah, you'd be a fool the challenge him! Piss off, stranger.",
"You are serious? You say he plans on destroying this town? You are as crazy as those filthy, long-haired hippies living high up in the mountains.",
"Get out of here young man, go poke your nose into businesses elsewhere!",
"...unless...",
"The world isn't free, you know what I'm saying? Suppose I did know a way to slay the Acorn King, what's in it for me?",
"At the bottom of the mountain just before the border to the Valley of Laziness, there is a secret entrance to the treetops.",
"There is a rare, {{green_light}}green mushroom{{white}} that only grows in those treetops and is very valuable.",
"Now, if you bring me that special mushroom, I'll consider helping out with your foolish quest. What do you say huh?",
}
                    Dialogue = Dialog.create(script)
                    Dialogue:open(function()
                        Dialog.finished = true
                        player.quest = 'To Slay An Acorn - Collect Mushroom for the Old Man' 
                        player.freeze = false 
                        end)
                  npc.menu:close(player)
                  npc.prompt = nil
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