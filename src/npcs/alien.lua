-- inculdes
local Dialog = require 'dialog'
local sound = require 'vendor/TEsound'
local prompt = require 'prompt'
local Timer = require('vendor/timer')
local Quest = require 'quest'
local telescope = require 'npcs/quests/telescopejuanquest'
local quests = require 'npcs/quests/alienquest'
local player = require 'player'
local Player = player.factory()
local json  = require 'hawk/json'
local app = require 'app'
local controls = require('inputcontroller').get()
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'

return {
  width = 29,
  height = 48,
  greeting = 'An adventurer! You might just be what I need...',
  animations = {
    default = {
      'loop',{'1,2'},.5,
    },
    walking = {
      'loop',{'3-5,2'},.2,
    },
  },
  walking = true,
  walk_speed = 36,
  hurt = function(npc)
    Dialog.new("Ouch! Stop hitting me you stupid human!", function() end)
  end,
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Who are you?' },
    { ['text']='What do you do here?' },
    { ['text']='Talk about quests', freeze= true},
  },
  enter = function(npc, previous)
    npc.shake = false
    if Quest.alreadyCompleted(npc, player, quests.aliencamp) == true and Quest.alreadyCompleted(npc, player, quests.qfo) == false then
      npc.busy = true
      npc.state = 'hidden'
    end
  end,
  update = function(dt, npc, player)
    local shakeval = 0

    if npc.shake == true then
      local player_dist= {x = 1, y = 1 }
      shakeval = (math.random() * 5)-2/player_dist.x
      camera:setPosition(camera.x + shakeval, camera.y + shakeval)
    end
  end,
  talk_commands = {
    ['Talk about quests']= function(npc, player)
      npc.walking = false
      if Quest.alreadyCompleted(npc, player, quests.qfo) then
        Dialog.new("Hello, human. Oh man, I could use some quesadillas right now.", function()
          npc.menu:close(player)
        end)
      elseif player.quest == 'Aliens! - Attack alien camp and bring back alien technology' and
             player.inventory:hasKey('alien_object3') then
        player.inventory:removeManyItems(1, {name='alien_object3',type='key'})
        Dialog.new("Wow, you made it out alive?! Really impressive, human. I suppose I can now tell you what I need the objects for--", function()
          local level = npc.containerLevel
          npc.shake = true
          player.freeze = true
          sound.playSfx( "quake" )
          level.trackPlayer = false
          Timer.add(2.5, function()
            npc.shake = false
            player.freeze = false
            level.trackPlayer = true
            Quest.removeQuestItem(player)
            player.quest = nil
            player.questParent = nil
            npc.menu:close(player)
            Quest:activate(npc, player, quests.regroup)
            npc.state = 'hidden' 
          end)
        end)
      elseif Quest.alreadyCompleted(npc, player, quests.alienobject) then
        Quest:activate(npc, player, quests.aliencamp)
      elseif player.quest == 'Aliens! - Investigate Goat Farm' and not player.inventory:hasKey('alien_object') then
        local start = {
          "Well done human, you saved me! Say, you're tougher than you look. You know what? I think I'm gonna let you help me.",
          "Here, take this alien trinket and give it to that {{teal}}buffoon with the telescope{{white}}. Maybe then he'll stop poking his nose around here.",
          "After that, {{red_dark}}come back and talk to me{{white}}. I've got an extremely important mission I need your help with.",
        }
        Dialog.create(start):open(function()
          npc.menu:close(player)
          player.freeze = false
          local Item = require 'items/item'
          local itemNode = require ('items/keys/alien_object')
          local item = Item.new(itemNode, 1)
          player.inventory:addItem(item, true)
        end)
      elseif player.quest == 'Aliens! - Investigate Goat Farm' and player.inventory:hasKey('alien_object') then
        Dialog.new("Human, what are you doing? Return to me at once after you get that telescope wielding buffoon off my case. I've got big plans with you!", function()
          npc.menu:close(player)
          player.freeze = false
        end)
      elseif Quest.alreadyCompleted(npc, player, telescope.alien) then
        Quest:activate(npc, player, quests.alienobject)
      end
      player.freeze = false
      npc.walking = true
    end,
  },
  talk_responses = {
    ['Who are you?']={
      "My name is {{green_light}}Juan{{white}}, an alien from another planet.",
      "I've fallen in love with the Mexican food on this planet, so I've changed my name and decided to live among you.",
    },
    ['What do you do here?']={
      "Shhh, I'm hiding here from my other alien brethren!",
      "If they find me, they'll kill me and make sure I never taste another burrito again...oh, the horror!",
    },
    ["inventory"]={
      "Uhh, you say you want to trade?",
    },
  },
  inventory = function(npc, player)
    if Quest.alreadyCompleted(npc, player, quests.qfo) then
      local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
      Gamestate.stack("shopping", player, screenshot, "alien")
    else
      Dialog.new("Too bad, I'm not selling anything to some Earthling like you!", function()
        npc.menu:close(player)
        player.freeze = false
      end)
    end
  end,
}
