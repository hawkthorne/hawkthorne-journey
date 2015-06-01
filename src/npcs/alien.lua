-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'
local Timer = require('vendor/timer')
local Quest = require 'quest'
local telescope = require 'npcs/quests/telescopejuanquest'
local quests = require 'npcs/quests/alienquest'

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
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Who are you?' },
    { ['text']='What do you do here?' },
    { ['text']='Talk about quests'},
  },
  --[[enter = function(npc, previous)
      if Quest.alreadyCompleted(telescopejuan, player, telescope.alien) == false then
        npc.busy = true
        npc.state = 'hidden'
      end
  end,]]
  talk_commands = {
    ['Talk about quests']= function(npc, player)
    if Quest.alreadyCompleted(npc, player, quests.alienobject) then
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
    elseif Quest.alreadyCompleted(telescopejuan, player, telescope.alien) then
      Quest:activate(npc, player, quests.alienobject)
    end
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
}
