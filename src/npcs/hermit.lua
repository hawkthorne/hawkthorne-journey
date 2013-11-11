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
    width = 24,
    height = 48,  
    animations = {
        default = {
            'loop',{'5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','5,1','1,1','2,1','1,1','2,1'},0.28,
        },
    },

    talk_items = {
        { ['text']='i am done with you' },
        { ['text']='Any useful info for me?' },
        { ['text']='Why do you live out here?' },
        { ['text']='Talk about quests' },
    },
    talk_commands = {
        ['Talk about quests']=function(npc, player)
            
            if player.quest == 'To Slay an Acorn - Find the Old Hermit at Stonerspeak' then
                    local Dialogue = require 'dialog'
                                       
                    
                     script = {
"I know why you are here adventurer, you are here seeking my advice on how to defeat the Acorn King.",
"You think you'd go unnoticed while you stomped around the mountain? I've heard about you and your quest, adventurer.",
"Fear not, I am on your side. I can tell you exactly where you can find the Acorn King.",
"He lives in a magically protected hideout in the mountains, but it's unreachable by foot. You're going to need a {{orange}}special potion{{white}}.",
"The potion will, uh--transform you into a, uh--nature spirit thus allowing you to bypass his enchantments--okay just trust me, alright?",
"I have all but one of the ingredients required to make that potion. If you bring me that last ingredient, I will make you the potion.",
"It is a special {{red_dark}}berry{{white}} that only grows up in Acornspeak, and it is crucial in brewing this potion.",
"Come back when you have collected the {{red_dark}}berry{{white}}, I only need one of them. The rope beside me will take you down from Stonerspeak.",
}
                    Dialogue = Dialog.create(script)
                    Dialogue:open(function()
                        Dialog.finished = true
                        player.quest = 'To Slay An Acorn - Collect the Special Berry for the Hermit' 
                        end)
                  npc.menu:close(player)
        elseif player.quest == 'To Slay An Acorn - Collect the Special Berry for the Hermit' and not player.inventory:hasMaterial('berry') then
          Dialog.new("Haven't gotten those berries yet? They grow up in Acornpeak, you need to collect one for me to make your potion.", function()
            npc.menu:close(player)
            end)
        elseif player.quest == 'To Slay An Acorn - Collect the Special Berry for the Hermit' and player.inventory:hasMaterial('berry') then
          Dialog.new("Quest ends here for now", function()
            npc.menu:close(player)
            end)
        else 
          Dialog.new("The woods here are dangerous these days, you gotta keep your wits about you!", function()
            npc.menu:close(player)
            end)
        end
    end,
    },
    talk_responses = {
    ["Any useful info for me?"]={
        "There's a buncha' chests hidden around these parts for some reason, check them out to see what you get!",
    },
    ["Why do you live out here?"]={
        "The nature, the trees, the wee-I mean, the water.",
        "Though it's getting dangerous these days with all them angry acorns out and about...",
    },
    },
}