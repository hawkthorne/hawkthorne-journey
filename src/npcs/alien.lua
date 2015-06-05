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
  Dialog.new("Ouch! Stop hittig me you stupid human!", function()
      end)
  end,
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Who are you?' },
    { ['text']='What do you do here?' },
    { ['text']='Talk about quests'},
  },
  enter = function(npc, previous)
  npc.shake = false
  if Quest.alreadyCompleted(npc, player, quests.aliencamp) == true and Player.quest ~= 'Aliens! - Regroup with the alien at Chili Fields' 
    and Player.quest ~= 'Aliens! - Destroy the QFO!' and npc.exist == false then
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
    local check = app.gamesaves:active():get("bosstriggers.qfo", true) 
    if player.quest == 'Aliens! - Destroy the QFO!' and Quest.alreadyCompleted(npc, player, quests.qfo) then
      Dialog.new("Hello, human. Oh man, I could use some quesadillas right now.", function()
      npc.menu:close(player)
      end)
    elseif player.quest == 'Aliens! - Destroy the QFO!' then
      if check == true then
      local script3 = {
      "You...you've done it! You've defeated the {{orange}}QFO{{white}}! I can't believe it! Now I can eat Mexican food in peace, forever!",
      "What, the aliens didn't automatically die when the mothership blew up? Well, I guess that's pretty realistic, I don't know what I was thinking.",
      "I know I've treated you unfairly human, but you have my gratitude.",
      "As a token of thanks, I'll give you my standard issue alien pistol, you'll need it more than I do. Here's some gold as well.",
      "Whenever you run out of ammo for the pistol, come back to me, I will sell some to you.",
      "It was nice working with you partner. We've defeated them!",
      }
      Dialog.new(script3, function()
      npc.menu:close(player)
      local Item = require 'items/item'
      local itemNode = require ('items/weapons/laser_pistol')
      local item = Item.new(itemNode, 1)
      local itemNode2 = require ('items/weapons/lasercell')
      local item2 = Item.new(itemNode2, 10)
      player.inventory:addItem(item, true)
      player.inventory:addItem(item2, true)
      player.money = player.money + 150
      local gamesave = app.gamesaves:active()
      local completed_quests = gamesave:get( 'completed_quests' ) or {}
      if completed_quests and type(completed_quests) ~= 'table' then
      completed_quests = json.decode( completed_quests )
      end
      table.insert(completed_quests, {questParent = 'alien', questName = 'Aliens! - Destroy the QFO!'})
      gamesave:set( 'completed_quests', json.encode( completed_quests ) )
      end)
      else
        Dialog.new("Come on, human. The {{orange}}QFO{{white}} is just outside! Its shields are down, now is the time to attack!", function()
          npc.menu:close(player)
          npc.walking = true
          end)
      end
    elseif player.quest == 'Aliens! - Regroup with the alien at Chili Fields' then
      local script2 = {
      "Well, howdy there partner! So glad to see you alive.",
      "Oh man you look angry...okay, I guess it wasn't right leaving you behind like that but hey! You made it!",
      "Alright, so I'll tell you my plan for defeating those aliens. You've earned it.",
      "The aliens' main source of power is the {{orange}}QFO{{white}}, a giant spaceship that can teleport and transport them in numbers.",
      "If the {{orange}}QFO{{white}} is destroyed, all the aliens will inexplicably die as well for some really convenient reason. Thank god, huh?",
      "I don't know if you've tried attacking the spaceship yet but you would have noticed that it will not take any damage thanks to its shield.",
      "My device, which I've completed just seconds ago, will shut down the shields enabling you to attack and kill it.",
      "The {{orange}}QFO{{white}} is just right outside the {{red_light}}Chili Fields{{white}} right now. Now is the perfect time to go attack it.",
      "Alright, this will be your final mission. Good luck huh, human? I believe in you. Go destroy that {{orange}}QFO{{white}}!",
      }
      Dialog.new(script2, function()
      npc.menu:close(player)
      player.quest = 'Aliens! - Destroy the QFO!'
      player.questParent = 'alien'
      Quest:save(quests.qfo)
      end)
    elseif player.quest == 'Aliens! - Attack alien camp and bring back alien technology' and player.inventory:hasKey('alien_object3') then
      Quest:activate(npc, player, quests.aliencamp)      
      Dialog.new("Wow, you made it out alive?! Really impressive, human. I suppose I can now tell you what I need the objects for--", function()
      local level = npc.containerLevel
      npc.shake = true
      sound.playSfx( "quake" )
      level.trackPlayer = false
      Timer.add(2.5, function()
        npc.shake = false
        level.trackPlayer = true
        local script = {
      "Holy crap, what the hell is that???",
      "Damn it, you stupid human! The aliens followed you when you were coming back here, and now they've found us! We're under attack!",
      "No, no, no, no, the device was so close to being complete! Then you had to go and mess it all up!",
      "Okay, well, survival first eh? Come meet me at the {{red_light}}Chili Fields{{white}}, we gotta regroup!",
      "Erm so, unfortunately, I've only got room for one in this teleporter, and I'm not good with spaces-- so you're gonna have to make it there on foot.",
      "The whole Valley will be crawling with alien soldiers trying to find us...well, to find you. Of course, I'll be at Chili Fields. Anyways, good luck!",
      "Ooh, I almost forgot to take with me the device you brought. I'll take that...",
      "Alright, toodles!",
      }
      Dialog.new(script, function()
      npc.menu:close(player)
      player.quest = 'Aliens! - Regroup with the alien at Chili Fields'
      player.questParent = 'alien'
      Quest:save(quests.regroup)
      npc.state = 'hidden'
      end)
      end)
      end)
      npc.walking = false
      
      
    elseif Quest.alreadyCompleted(npc, player, quests.alienobject) then
      Quest:activate(npc, player, quests.aliencamp)
    elseif player.quest == 'Aliens! - Investigate Goat Farm' and not player.inventory:hasKey('alien_object') then
      local start = {
      "Well done, human, you saved me! Say, you're tougher than you look. You know what? I think I'm gonna let you help me.",
      "Here, take this alien trinket and give it to that buffoon with the telescope. Maybe then he'll stop poking his nose around here.",
      "After that, come back and talk to me. I've got an extremely important mission I need your help with.",
      }
      local Dialogue = require 'dialog'
      Dialogue = Dialog.create(start)
      Dialogue:open(function()
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
    end,
  },
  talk_responses = {
    ['Who are you?']={
      "My name is {{green_light}}Juan{{white}}, an alien from another planet.",
      "I've' fallen in love with the Mexican food on this planet, so I've changed my name and decided to live among you.",
    },
    ['Any useful info for me?']={
      "Shhh, I'm hiding here from my other alien brethren!",
      "If they find me, they'll kill me and make sure I never taste another burrito again...oh, the horror!",
    },
  },
  inventory = function(npc, player)
    local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
    Gamestate.stack("shopping", player, screenshot, "alien")
  end,
}
