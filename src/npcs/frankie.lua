-- inculdes
local Dialog = require 'dialog'
local prompt = require 'prompt'
local Timer = require('vendor/timer')
local Quest = require 'quest'
local quests = require 'npcs/quests/frankiequest'
local utils = require 'utils'
local json  = require 'hawk/json'
local app = require 'app'

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
      { ['text']='De-electrify pool', freeze = true },
      { ['text']='Lost office key!', freeze = true },
      { ['text']='Mail Diane', freeze = true },
      { ['text']='Potatoes on rooftops', freeze = true },
      { ['text']='Bones in the parking lot', freeze = true },
      { ['text']='Peanut Costume', freeze = true },
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
    ['De-electrify pool']= function(npc, player)
      local affection = player.affection.frankie or 0
      if affection >= 200 then
        local poolcompleted = Quest.alreadyCompleted(npc,player,quests.poolreturn)
        -- If we've already done this quest, give the player the congrats message without reward
        if poolcompleted then
          Dialog.new(quests.pool.complete, function()
            player.freeze = false
            npc.menu:close(player)
          end)
        elseif player.quest == 'Save Greendale - Return back to Frankie' then
          Quest.completeQuestSucceed(npc, player, quests.poolreturn)
        else
          Quest:activate(npc, player, quests.pool)
        end
      else
        Dialog.new("Frankie doesn't trust you enough yet for this task! Complete other tasks first and increase her trust.", function()
          player.freeze = false
          npc.menu:close(player)
        end)
      end
    end,
    ['Lost office key!']= function(npc, player)
      Quest:activate(npc, player, quests.officekey)
    end,
    ['Mail Diane']= function(npc, player)
      local dianecompleted = Quest.alreadyCompleted(npc,player,quests.dianereturn)
      -- If we've already done this quest, give the player the congrats message without reward
      if dianecompleted then
        Dialog.new(quests.dianemail.complete, function()
          player.freeze = false
          npc.menu:close(player)
        end)
      elseif player.quest == 'Save Greendale - Return to Frankie' then
        Quest.completeQuestSucceed(npc, player, quests.dianereturn)
      else
        if player.inventory:hasKey('document') ~= true then
          local Item = require 'items/item'
          local itemNode = require ('items/keys/document')
          local item = Item.new(itemNode, 1)
          player.inventory:addItem(item, true)
        end
        Quest:activate(npc, player, quests.dianemail)
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
