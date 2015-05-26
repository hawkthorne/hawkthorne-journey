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
      if player.quest == nil and poolcompleted then
      Dialog.new("Ugh, it seems that the pool is still not being fixed. They're distracted by murder mystery night or something...", function()
        player.freeze = false
        npc.menu:close(player)
      end)
        --if player doesn't have any quests, initiate quest
      elseif player.quest == nil then
        Dialog.new(quests.pool.giveQuestSucceed, function()
        npc.prompt = prompt.new(quests.pool.successPrompt, function(result)
          if result == 'Yes' then
            Quest:save(quests.pool)
            player.quest = 'Save Greendale - Find out what the delay with pool repairs is'
            player.questParent = 'frankie'
            npc.menu:close(player)
          end     
          npc.menu:close(player)
          npc.prompt = nil
        end)
        player.freeze = false
        end)
        --if player already has accepted the quest, tell player to go work on the quest
      elseif player.quest == 'Save Greendale - Find out what the delay with pool repairs is' then
          Dialog.new(quests.pool.completeQuestFail, function()
            player.freeze = false
            npc.menu:close(player)
          end) 
        --player completed the quest
      elseif player.quest == 'Save Greendale - Return back to Frankie' then
          Dialog.new(quests.poolreturn.completeQuestSucceed, function()
            local gamesave = app.gamesaves:active()
            local completed_quests = gamesave:get( 'completed_quests' ) or {}
            if completed_quests and type(completed_quests) ~= 'table' then
            completed_quests = json.decode( completed_quests )
            end
            table.insert(completed_quests, {questParent = player.questParent, questName = player.quest})
            gamesave:set( 'completed_quests', json.encode( completed_quests ) )
            npc:affectionUpdate(quests.poolreturn.reward.affection)
            player:affectionUpdate(player.questParent, quests.poolreturn.reward.affection)
            player.money = player.money +  quests.poolreturn.reward.money
            player.quest = nil
            player.questParent = nil
            player.freeze = false
            Quest:save({})
            npc.menu:close(player)
          end)    
      else
        --if player already has a quest        
        local abandon = "You already have quest '" .. player.quest .. "' for {{red_light}}" .. player.questParent .. "{{white}}!"
        Dialog.new(abandon, function()
        npc.prompt = prompt.new("Abandon current quest?", function(result)
        if result == 'Yes' then
          Quest:save({})
          player.quest = nil
          player.questParent = nil
        end
        npc.menu:close(player)
        npc.prompt = nil
        end)
        end)
        player.freeze = false
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
    if player.quest == nil and dianecompleted then
    Dialog.new("The wi-fi is still down apparently...but I got the document to Diane in time, so thank you for that.", function()
      player.freeze = false
      npc.menu:close(player)
    end)
    --if player doesn't have any quests, initiate quest
    elseif player.quest == nil then
    local Dialogue = require 'dialog'
    Dialog.new(quests.dianemail.giveQuestSucceed, function()
      npc.prompt = prompt.new(quests.dianemail.successPrompt, function(result)
        if result == 'Yes' then
          Quest:save(quests.dianemail)
          local Item = require 'items/item'
          local itemNode = require ('items/keys/document')
          local item = Item.new(itemNode, 1)
          player.inventory:addItem(item, true)
          player.quest = 'Save Greendale - Mail Diane'
          player.questParent = 'frankie'
          npc.menu:close(player)
        end
        npc.menu:close(player)
        npc.prompt = nil      
      end)
      player.freeze = false
      end)
    --if player already has accepted the quest, tell player to go work on the quest
    elseif player.quest == 'Save Greendale - Mail Diane' and player.inventory:hasKey('document') then
        Dialog.new(quests.dianemail.completeQuestFail, function()
          player.freeze = false
          npc.menu:close(player)
        end)
    --player completed the quest
    elseif player.quest == 'Save Greendale - Return to Frankie' then
        Dialog.new(quests.dianereturn.completeQuestSucceed, function()
          local gamesave = app.gamesaves:active()
          local completed_quests = gamesave:get( 'completed_quests' ) or {}
          if completed_quests and type(completed_quests) ~= 'table' then
          completed_quests = json.decode( completed_quests )
          end
          table.insert(completed_quests, {questParent = player.questParent, questName = player.quest})
          gamesave:set( 'completed_quests', json.encode( completed_quests ) )
          npc:affectionUpdate(quests.dianereturn.reward.affection)
          player:affectionUpdate(player.questParent, quests.dianereturn.reward.affection)
          player.quest = nil
          player.questParent = nil
          player.freeze = false
          Quest:save({})
          npc.menu:close(player)
        end)
    --if player already has a quest 
    else
          local script = "You already have quest '" .. player.quest .. "' for {{red_light}}" .. player.questParent .. "{{white}}!"
          Dialog.new(script, function()
          npc.prompt = prompt.new("Abandon current quest?", function(result)
          if result == 'Yes' then
            player.quest = nil
            player.questParent = nil
            Quest:save({})
          end
          npc.menu:close(player)
          npc.prompt = nil
        end)
      end)
      player.freeze = false
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
