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
    { ['text']='You look so worried!', freeze = true },
    },
        talk_commands = {
        ['You look so worried!']=function(npc, player)
                npc.walking = false
                npc.stare = false
            
            if player.quest~=nil and player.quest~='collect flowers' then
            Dialog.new("You already have quest '" .. player.quest .. "' for " .. player.questParent .. "!", function()
            npc.walking = true
            npc.menu:close(player)
            end)
          elseif player.quest=='collect flowers' and not player.inventory:hasMaterial('flowers') then
            Dialog.new("Have you found any flowers?  Try looking beyond the town.", function()
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
              Dialog.new("Please, oh adventurer, I fear there is a sinister plot going on in these woods, one that may result in the very destruction of the Village. Will you not help me?", function()
                npc.prompt = prompt.new("Accept quest 'To Slay An Acorn'?", function(result)
                  if result == 'Yes' then
                    player.quest = 'To Slay An Acorn - Talk to Old Man in Village'
                    local Dialog = require 'dialog'
                    player.questParent = 'tilda'
                     script = {
"Oh thank you, thank you so much! My name is Tilda, I used to live in the village.",
"When I was forced into marrying a man I did not love, I fled deep into these woods and now I fend for myself in the winderness.",
"Just last week while I was fetching water from a stream, I heard a great rumble as I saw the Acorn King himself walking through the woods.",
"He was angrily muttering to himself about a plan to destroy the town and all of its people, and I fled in fear before I could hear the rest.",
"Though I was banished, my family who I still dearly love including my sister Hilda live in the Village, and I cannot bear to see it destroyed!",
"Someone must do something! At the Village, there is an old man who is wise in his years. He must surely know a way to slay the King of Acorns.",
"I would do it myself but if I were to return, they would likely think I turned into one of those tree-hugging hippies and burn me at the stake",
}
                    Dialog.new(script)
                    
                  end
                  npc.menu:close(player)
                  npc.fixed = result == 'Yes'
                  npc.walking = true
                  npc.prompt = nil
                  Timer.add(2, function() 
                    npc.fixed = false
                  end)
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