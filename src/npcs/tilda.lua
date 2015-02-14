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
    height = 48,   
    animations = {
        default = {
            'loop',{'1,1','11,1'},.5,
        },
        walking = {
            'loop',{'1,1','2,1','3,1'},.2,
        },

    },

    walking = true,

    talk_items = {
    { ['text']='i am done with you' },
    { ['text']='You look familiar...' },
    { ['text']='How do I get out of here?'},
    { ['text']='Talk about quests', freeze = true},
    },
        talk_commands = {
        ['Talk about quests']=function(npc, player)
             npc.walking = false
            
          if player.quest ~= nil and player.questParent ~= 'Tilda' then
            Dialog.new("You already have a quest, you cannot do more than one quest at a time!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='To Slay An Acorn - Collect Mushroom for the Old Man' then
            script2 = {
            "You say you are collecting the green mushroom for the Old Man?",
            "At the bottom of the mountain, before the bridge to the Valley of Laziness, there is a secret door high up in the treetops.",
            "You will enter the top of the treeline through that door. The {{green_light}}green mushroom{{white}} should grow somewhere inside.",
            }

            Dialogue = Dialog.create(script2)
                    Dialogue:open(function()
                        Dialog.finished = true
                        end)
            npc.walking = true
            npc.menu:close(player)

          elseif player.quest=='To Slay An Acorn - Search for the Weapon in the mines' then
            script3 = {
            "The weapon that can slay the Acorn King is inside the mines?",
            "To the east of me is the entrance to the mines. I suggest you bring a weapon, I have a feeling those cult members won't be friendly!",
            }

            Dialogue = Dialog.create(script3)
                    Dialogue:open(function()
                        Dialog.finished = true
                        end)
            npc.walking = true
            npc.menu:close(player)

         elseif player.quest=='To Slay An Acorn - Return to Tilda' then
            script4 = {
            "The weapon is gone?! That is troubling news, how will the Acorn King be defeated now?",
            "Wait...I have one more idea.",
            "At the very top of the mountain is Stonerspeak, the floating rocks in the clouds where the hippies live.",
            "At the very edge of that Stonerspeak there is an old hermit who lives in recluse. He is very old and wise.",
            "Some say he was one of the founding members of the Laser Lotus cult, he must surely know how to defeat the Acorn King!",
            "The path up to Stonerspeak is extremely perilous, I am afraid that I must ask you to do this but it is the only way.",
            "Please, you must hurry!",
            }
            player.quest = 'To Slay an Acorn - Find the Old Hermit at Stonerspeak'    
            Dialogue = Dialog.create(script4)
                    Dialogue:open(function()
                        Dialog.finished = true
                        end)
            npc.walking = true
            npc.menu:close(player)
         elseif player.quest=='To Slay an Acorn - Find the Old Hermit at Stonerspeak' then
            Dialog.new("The hermit lives at the top of Stonerspeak. You must find him and ask for his aid!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='To Slay An Acorn - Talk to Old Man in Village' then
            Dialog.new("Please, you must hurry!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='collect flowers' and player.inventory:hasMaterial('flowers') then
            Dialog.new("My goodness, these flowers are beautiful!  Thank you so very much!", function()
            npc:affectionUpdate(300)
            player:affectionUpdate('hilda',300)
                    npc.walking = true
                    player.inventory:removeManyItems(1,{name='flowers',type='material'})
                    player.quest = nil
              npc.menu:close(player)
                end)
          else
              Dialog.new("Please adventurer, I fear there is a sinister plot gong on in these woods, one that may result in the very destruction of the Village. Will you not help me?", function()
                npc.prompt = prompt.new("Accept quest {{red_dark}}'To Slay An Acorn'?{{white}}", function(result)
                  if result == 'Yes' then
                    local Dialogue = require 'dialog'
                    player.quest = 'To Slay An Acorn - Talk to Old Man in Village' 
                    player.questParent = 'Tilda'                   
                     script = {
"Oh thank you, thank you so much! My name is Tilda, I used to live in the village.",
"When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the winderness.",
"Just last week while I was fetching water from a stream, I heard a great rumble as I saw the Acorn King himself walking through the woods.",
"He was angrily muttering to himself about a plan to destroy the town and all of its people, and I fled in fear before I could hear the rest.",
"Though I was banished, my family who I still dearly love including my sister Hilda live in the Village, and I cannot bear to see it destroyed!",
"Someone must do something! At the Village, there is an old man who is wise in his years. He must surely know a way to slay the King of Acorns.",
"I would do it myself but if I were to return, they would likely think I turned into one of those tree-hugging hippies and burn me at the stake.",
"Please, you must hurry!",
}
                    Dialogue = Dialog.create(script)
                    Dialogue:open(function()
                        Dialog.finished = true
                        end)
                    
                  end
                  npc.menu:close(player)
                  npc.walking = true
                  npc.prompt = nil
                end)
              end)
          end

    end,
    },
    talk_responses = {
    ['You look familiar...']={
        "My name is Tilda, I used to live in the village.",
        "When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the winderness.",   
        "You may have met my sister, Hilda. She and I resemble each other greatly.", 
    },
    ['How do I get out of here?']={
        "The mountain pass used to be open to all travellers, before Hawthorne took the throne and unleashed the Acorn King.",
        "Now it is blocked by a magical barrier that can only be opened by a key that the Acorn King personally carries around.",   
    },
 
    },
    tickImage = love.graphics.newImage('images/npc/hilda_heart.png'),
    command_items = { 
    { ['text']='back' },
    { ['text']='go home' },
    { ['text']='stay' }, 
    { ['text']='follow' },  
    },
    command_commands = {
    ['follow']=function(npc, player)
        npc.walking = true
        npc.stare = true
        npc.minx = npc.maxx
    end,
    ['stay']=function(npc, player)
        npc.walking = false
        npc.stare = false
    end,
    ['go home']=function(npc, player)
        npc.walking = true
        npc.stare = false
        npc.minx = npc.maxx - (npc.props.max_walk or 48)*2
    end,
    },
}