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
local utils = require 'utils'
local app = require 'app'

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
    { ['text']='Any useful info for me?'},
    { ['text']='Talk about quests', freeze = true},
    },
        talk_commands = {
        ['Talk about quests']=function(npc, player)
        npc.walking = false
        local check = app.gamesaves:active():get("bosstriggers.acorn", false)
        if check ~= false then
        Dialog.new("Thank you for defeating the Acorn King adventurer, you have saved us all!", function()
        npc.menu:close(player)
        end)
        return end
          if player.quest ~= nil and player.questParent ~= 'Tilda' then
            Dialog.new("You already have a quest, you cannot do more than one quest at a time!", function()
            npc.walking = true
            npc.menu:close(player)
            end)

          elseif player.quest=='To Slay An Acorn - Explore the Mines for a Map to the Acorn King' then
            script3 = {
            "The map to the Acorn King's hideout is in the mines with the cultists?",
            "To my east is the entrance to the mines. I hear it is a dangerous place, bring a weapon and be ready for trouble!",
            }

            Dialogue = Dialog.create(script3)
            Dialogue:open(function()
            Dialog.finished = true
            end)
            npc.walking = true
            npc.menu:close(player)

         elseif player.quest=='To Slay an Acorn - Return to Tilda' then
            script4 = {
            "The map is gone?! That is troubling news, how will the Acorn King be defeated now?",
            "Wait...I have one more idea.",
            "At the very top of the mountain is {{green_light}}Stonerspeak{{white}}, the floating rocks in the clouds where the hippies live.",
            "At the very edge of that {{green_light}}Stonerspeak{{white}} there is an old hermit who lives in recluse. He is very old and wise.",
            "If there is anybody that has any information on how to defeat the Acorn King, it is the hermit.",
            "However, the path to {{green_light}}Stonerspeak{{white}} is extremely perilous. I was afraid to ask of you to do this but it is the only way.",
            "Please, you must hurry!",
            }             
            Dialogue = Dialog.create(script4)
            Dialogue:open(function()
            Dialog.finished = true
            player.quest = 'To Slay an Acorn - Find the Old Hermit at Stonerspeak' 
            end)
            npc.walking = true
            npc.menu:close(player)
         elseif player.quest=='To Slay an Acorn - Find the Old Hermit at Stonerspeak' then
            Dialog.new("The hermit lives at the top of Stonerspeak. You must find him and ask for his aid!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
        elseif player.quest=='To Slay An Acorn - Collect the Special Berry for the Hermit' then
            Dialog.new("The hermit lives at the top of Stonerspeak. You must find him and ask for his aid!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='To Slay An Acorn - Ask Around the Village about the Acorn King' then
            Dialog.new("Have you talked to the villagers yet? Try the elderly residents, they must know a few things.", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          else
              Dialog.new("Please adventurer, I fear there is a sinister plot going on in these woods, one that may result in the very destruction of the Village. Will you not help me?", function()
                npc.prompt = prompt.new("Accept quest {{red_light}}'To Slay An Acorn'?{{white}}", function(result)
                  if result == 'Yes' then
                    local Dialogue = require 'dialog'
                    player.quest = 'To Slay An Acorn - Ask Around the Village about the Acorn King'
                    player.questParent = 'Tilda'                 
                     script = {
"Oh thank you, thank you so much! My name is Tilda, I used to live in the village.",
"When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the wilderness.",
"Just last week while I was fetching water from a stream, I heard a great rumble as I saw the Acorn King himself walking through the woods.",
"He was angrily muttering to himself about a plan to destroy the town and all of its people, and I fled in fear before I could hear the rest.",
"Though I was banished, my family I still dearly love including my sister Hilda live in the Village, and I cannot bear to see it destroyed!",
"I must prevent that. Though I do not know how, if you ask around at the {{olive}}Village{{white}} there must be someone who knows how to defeat the Acorn King.",
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
    ['Any useful info for me?']={
        "Watch out for those acorns, traveler! They are small, but can be quite aggressive when attacked.",
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