-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'
local Timer = require('vendor/timer')
local Quest = require 'quest'
local quests = require 'npcs/quests/frankiequest'
local utils = require 'utils'

return {
  width = 24,
  height = 48,
  greeting = 'I am a big believer in hierarchy. Someone needs to say that I am in charge, and that person is me.',
  animations = {
    default = {
      'loop',{'1,1','1,1','1,1','2,1'},.25,
    },
  },
  talk_items = {
    { ['text']='i am done with you' },
    { ['text']='Save Greendale!', ['option']={
      { ['text']='De-electrify pool' },
      { ['text']='Post warning signs' },
      { ['text']='Lost office key!', freeze = true },
      { ['text']='Mail Diane', freeze = true },
      { ['text']='Potatoes on rooftops', freeze = true },
      { ['text']='Bones in the parking lot', freeze = true },
      { ['text']='Cork-based Networking' },
      { ['text']='Peanut Costume', freeze = true },
      { ['text']='Pierce Hologram' },
      { ['text']='The Ass Crack Bandit' },
    }},
    { ['text']='Are you the IT lady?' },
    { ['text']='How is Greendale?' },
  },
  talk_commands = {
    ['Peanut Costume']= function(npc, player)
    local affection = player.affection.frankie or 0
      if affection >= 200 then
        Quest:activate(npc, player, quests.peanutcostume)
      else
        Dialog.new("Frankie doesn't trust you enough yet for this task! Complete other tasks first and increase her trust.", function()
          player.freeze = false
          npc.menu:close(player)
        end)
      end
      end,
    ['Bones in the parking lot']= function(npc, player)
      Quest:activate(npc, player, quests.bones)
      end,
    ['Lost office key!']= function(npc, player)
      local affection = player.affection.frankie or 0
        if affection >= 200 then
        Quest:activate(npc, player, quests.officekey)
        else
        Dialog.new("Frankie doesn't trust you enough yet for this task! Complete other tasks first and increase her trust.", function()
          player.freeze = false
          npc.menu:close(player)
        end)
      end
      end,
    ['Mail Diane']= function(npc, player)
    if player.quest == nil then
    Dialog.new("I need to mail this document to Diane. I would send an e-mail, but there is some trouble with campus wi-fi and the IT lady is nowhere to be seen.", function()
      npc.prompt = prompt.new("Could you deposit this document into the mailbox? And no montages!", function(result)
        if result == 'Yes' then
          player.freeze = true
          local Item = require 'items/item'
          local itemNode = require ('items/keys/document')
          local item = Item.new(itemNode, 1)
          player.inventory:addItem(item, true, callback)
          player.quest = 'Save Greendale - Mail Diane'
          player.questParent = 'frankie'
          npc.menu:close(player)
        end
        npc.prompt = nil      
      end)
      player.freeze = false
      npc.menu:close(player)
      end)
    elseif player.quest == 'Save Greendale - Mail Diane' and player.inventory:hasKey('document') then
        Dialog.new("Have you deposited it into the mailbox yet? The mailbox is at the west end of the campus. And no wasting time with montages!", function()
          player.freeze = false
          npc.menu:close(player)
        end)
    elseif player.quest == 'Save Greendale - Return to Frankie' then
        Dialog.new("Thank you for depositing the mail!", function()
          npc:affectionUpdate(50)
          player:affectionUpdate(player.questParent, 50)
          player.quest = nil
          player.questParent = nil
          player.freeze = false
          npc.menu:close(player)
        end)
    end
      end,
    ['Potatoes on rooftops']= function(npc, player)
    --check if there are still potatoes on campus rooftops
      Quest:activate(npc, player, quests.potatoes, function()
          for _,node in pairs(npc.containerLevel.nodes) do
            if node.name == 'potato' then
              return true
            end
          end
          return false
        end)
      end,
  },
  talk_responses = {
    ['Save Greendale!']={
      "I am part of the {{green_light}}Save Greendale Committee{{white}}, but there's just too many things to do!",
      "I would be extremely grateful if you were to lend me a hand with my tasks.",
    },
    ['Are you the IT lady?']={
      "No, I'm not! People keep asking me that and I have no idea why.",
      "I'm sure the previous IT lady had a good reason to quit her job.",
    },
    ['How is Greendale?']={
      "This school is weird, gross, and passionate.",
      "But mostly weird and gross.",
    },
  },
}
