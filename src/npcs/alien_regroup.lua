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
local Gamestate = require 'vendor/gamestate'

local window = require 'window'
local camera = require 'camera'

return {
  width = 29,
  height = 48,
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
  noinventory = "Calm down there human, I'll sell you my supplies when I get back to my cave.",
  hurt = function(npc)
  Dialog.new("Ouch! Stop hittig me you stupid human!", function()
      end)
  end,
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='You are a dick.' },
    { ['text']='Aliens are everywhere!' },
    { ['text']='Talk about quests', freeze= true },
  },
  enter = function(npc, previous)
  npc.shake = false
  if Player.quest ~= 'Aliens! - Regroup with the alien at Chili Fields' then
    if Player.quest == 'Aliens! - Destroy the QFO!' then
    else
    npc.busy = true
    npc.state = 'hidden'
  end
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
    local check = app.gamesaves:active():get("bosstriggers.qfo", false) 
    if Quest.alreadyCompleted(npc, player, quests.qfo) then
      Dialog.new("Hello, human. Oh man, I could use some quesadillas right now.", function()
      npc.menu:close(player)
      end)
    elseif player.quest == 'Aliens! - Destroy the QFO!' then
      if check then
      local script3 = {
      "You...you've done it! You've defeated the {{orange}}QFO{{white}}! I can't believe it! Now I can eat Mexican food in peace, forever!",
      "I know I've treated you unfairly human, but you have my gratitude.",
      "As a token of thanks, I'll give you my standard issue {{blue_light}}alien pistol{{white}}, you'll need it more than I do. Here's some gold as well.",
      "Whenever you run out of ammo for the pistol, come back to me, I will sell some to you.",
      "It was nice working with you partner. We've defeated them!",
      }
      Dialog.new(script3, function()
      npc.menu:close(player)
      local level = npc.containerLevel
      local Item = require 'items/item'
      local itemNode = require ('items/weapons/laser_pistol')
      local item = Item.new(itemNode, 1)
      local itemNode2 = require ('items/weapons/lasercell')
      local item2 = Item.new(itemNode2, 10)
      if not player.inventory:addItem(item) then
        local Weapon = require('/nodes/' .. itemNode.type)
        itemNode.width = itemNode.width or item.image:getWidth()
        itemNode.height = itemNode.height or item.image:getHeight() - 15

        itemNode.x = level.player.position.x
        itemNode.y = level.player.position.y + (level.player.height - itemNode.height)
        itemNode.properties = {foreground = false}

        local myNewNode = Weapon.new(itemNode, level.collider)
        level:addNode(myNewNode)
      end
      if not player.inventory:addItem(item2) then
        local Projectile = require('/nodes/projectile')
        itemNode2.width = itemNode2.width or item.image:getWidth()
        itemNode2.height = itemNode2.height or item.image:getHeight() - 15

        itemNode2.x = level.player.position.x
        itemNode2.y = level.player.position.y + (level.player.height - itemNode2.height)
        itemNode2.properties = {foreground = false, dropped = true}

        local myNewNode = Projectile.new(itemNode2, level.collider)
        level:addNode(myNewNode)
      end
      player.money = player.money + 150
      local gamesave = app.gamesaves:active()
      local completed_quests = gamesave:get( 'completed_quests' ) or {}
      if completed_quests and type(completed_quests) ~= 'table' then
      completed_quests = json.decode( completed_quests )
      end
      table.insert(completed_quests, {questParent = 'alien', questName = 'Aliens! - Destroy the QFO!'})
      gamesave:set( 'completed_quests', json.encode( completed_quests ) )
      end)
      player.quest = nil
      player.questParent = nil
      Quest.removeQuestItem(player)
      else
        Dialog.new("Come on, human. The {{orange}}QFO{{white}} is just outside! Its shields are down, now is the time to attack!", function()
          npc.menu:close(player)
          npc.walking = true
          end)
      end
    elseif player.quest == 'Aliens! - Regroup with the alien at Chili Fields' then
      local script2 = {
      "Howdy there partner! So glad to see you alive.",
      "Alright, so I'll tell you my plan for defeating those aliens. You've earned it.",
      "The aliens' main source of power is the {{orange}}QFO{{white}}, a giant spaceship that can teleport and transport them in numbers.",
      "My device, completed with the parts you brought me, will shut down the shields protecting the ship, enabling you to attack and kill it.",
      "The {{orange}}QFO{{white}} is just right outside the {{red_light}}Chili Fields{{white}} near the coast right now. Now is the perfect time to go attack it.",
      "Good luck huh, human? I believe in you. Go destroy that {{orange}}QFO{{white}}!",
      }
      Dialog.new(script2, function()
      npc.menu:close(player)
      Quest.removeQuestItem(player)
      Quest.addQuestItem(quests.qfo, player)
      player.quest = 'Aliens! - Destroy the QFO!'
      player.questParent = 'alien'
      Quest:save(quests.qfo)
      end)
    end
    player.freeze = false
    npc.walking = true
    end,
  },
  talk_responses = {
    ['You are a dick.']={
      "Yeeeah...I do some questionable things, not even gonna lie.",
    },
    ['Aliens are everywhere!']={
      "They're crawling everywhere, I know! The invasion has pretty much started.",
    },
  },
}
