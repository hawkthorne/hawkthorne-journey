local sound = require 'vendor/TEsound'
local Timer = require('vendor/timer')
local tween = require 'vendor/tween'
local character = require 'character'
local Gamestate = require 'vendor/gamestate'
local utils = require 'utils'
local anim8 = require 'vendor/anim8'
local Dialog = require 'dialog'
local Quest = require 'quest'
local quests = require 'npcs/quests/tildaquest'
local prompt = require 'prompt'
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
        local check = app.gamesaves:active():get("bosstriggers.acorn", false)
        if check then
          Dialog.new("Thank you for defeating the Acorn King adventurer, you have saved us all!", function()
            npc.menu:close(player)
          end)
          return
        end
        if player.quest=='To Slay An Acorn - Explore the Mines for a Map to the Acorn King' then
          Quest:activate(npc, player, quests.explore_mines)
        elseif player.quest=='To Slay an Acorn - Return to Tilda' then
          Quest.removeQuestItem(player)
          Quest:activate(npc, player, quests.find_hermit)
        elseif player.quest=='To Slay an Acorn - Find the Old Hermit at Stonerspeak' then
          Quest:activate(npc, player, quests.find_hermit)
        elseif player.quest=='To Slay An Acorn - Collect the Special Berry for the Hermit' then
          Dialog.new("The hermit lives at the top of Stonerspeak. You must find him and ask for his aid!", function()
            npc.menu:close(player)
          end)
        else
          Quest:activate(npc, player, quests.slay_acorn)
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