-- quest.lua

local Dialog = require 'dialog'
local prompt = require 'prompt'
local json  = require 'hawk/json'
local app = require 'app'
local utils = require 'utils'
local Item = require 'items/item'
local Gamestate = require 'vendor/gamestate'
local app = require 'app'

local Quest = {}

function Quest.alreadyCompleted(npc, player, quest)
  local gamesave = app.gamesaves:active()
  local completed_quests = gamesave:get( 'completed_quests' ) or {}
  if completed_quests and type(completed_quests) ~= 'table' then
    completed_quests = json.decode( completed_quests )

    for k,v in pairs(completed_quests) do
      if type(v) == 'table' then
        if v['questParent'] == quest.questParent and
           v['questName'] == quest.questName then
          return true
        end
      end
    end
  end

  return false
end

function Quest:activate(npc, player, quest, condition)
  local meetsCondition = false
  -- If they aren't on a quest at the moment, check to see if they meet the requirements to accept this one
  if condition and not player.quest then
    meetsCondition = condition()
    if not meetsCondition then
      -- If they don't meet the conditions to accept the quest, congratulate them
      -- This is only used for Juanita at the moment and will need changing in the future
      Dialog.new(quest.completeQuestSucceed, function()
        npc.menu:close(player)
      end)
      return
    end
  end
  local completed = self.alreadyCompleted(npc,player,quest)
  if completed and not quest.infinite then
    -- If we've already done this quest, give the player the congrats message without reward
    Dialog.new(quest.completed or quest.completeQuestSucceed, function()
      npc.menu:close(player)
    end)
    return
  end

  if not player.quest then
    self.giveQuestSucceed(npc,player,quest)
  elseif player.quest == quest.questName then
    self:completeQuest(npc,player,quest)
  else
    self.giveQuestFail(npc,player,quest)
  end
end

function Quest:save(quest)
  local level = Gamestate.currentState()
  level.hud:startSave()
  local gamesave = app.gamesaves:active()
  gamesave:set( 'quest', json.encode( quest ) )
  level.hud:endSave()
end

function Quest:load(player)
  local gamesave = app.gamesaves:active()
  local save = gamesave:get( 'quest' )
  if save then
    local quest = json.decode( save )
    if quest then
      player.quest = quest.questName
      player.questParent = quest.questParent
    end
  end
end

function Quest.giveQuestSucceed(npc, player, quest)
  local script = quest.giveQuestSucceed
  Dialog.new (script, function()
    if quest.skipPrompt then
      
      player.quest = quest.questName
      player.questParent = quest.questParent
      Quest.addQuestItem(quest, player)
      npc.menu:close(player)
      npc.prompt = nil
    else
      npc.prompt = prompt.new(quest.successPrompt, function(result)
        if result == 'Yes' then
          player.quest = quest.questName
          player.questParent = quest.questParent
          --if there is an extra info message for player after quest prompt, display it
          if quest.promptExtra then
            Dialog.new(quest.promptExtra, function()
            npc.menu:close(player)
            end)
          end
          Quest.addQuestItem(quest, player)
        end
        npc.menu:close(player)
        npc.prompt = nil
      end)
    end
  end)
end

function Quest.addQuestItem(quest, player)
  local itemNode = utils.require( 'items/details/quest' )
  itemNode.type = 'detail'
  itemNode.description = "Quest for " .. quest.questParent
  itemNode.info = quest.questName
  local item = Item.new(itemNode)
  player.inventory:addItem(item, true)
  Quest:save(quest)
end

function Quest.removeQuestItem(player)
  local itemNode = utils.require( 'items/details/quest' )
  itemNode.type = 'detail'
  local item = Item.new(itemNode)

  playerItem, pageIndex, slotIndex = player.inventory:search(item)
  -- check to make sure item exists to remove
  if player.inventory:search(item) == false then
    return
  end
  player.inventory:removeItem(slotIndex, pageIndex)

  player.quest = nil
  player.questParent = nil
  Quest:save({})
end

function Quest.giveQuestFail(npc, player, quest)
  local script = "You already have quest '" .. player.quest .. "' for {{red_light}}" .. player.questParent .. "{{white}}!"
  script = quest.giveQuestFail or script
  Dialog.new(script, function()
    npc.prompt = prompt.new("Abandon current quest?", function(result)
      if result == 'Yes' then
        Quest.removeQuestItem(player)
      end
      npc.menu:close(player)
      npc.prompt = nil
    end)
  end)
end

function Quest:completeQuest(npc, player, quest)
  local success = self.testSuccess(player, quest)
  if success then
    self.completeQuestSucceed(npc, player, quest)
  else
    self.completeQuestFail(npc, player, quest)
  end
end

function Quest.testSuccess(player, quest)
  local success = false
  if quest.collect then
  --Quest type collect: collect and return a certain item for an NPC
    if quest.collect.type == 'consumable' then
      success = player.inventory:hasConsumable(quest.collect.name)
    elseif quest.collect.type == 'material' then
      success = player.inventory:hasMaterial(quest.collect.name)
    elseif quest.collect.type == 'key' then
      success = player.inventory:hasKey(quest.collect.name)
    end
  elseif quest.removeall then
  --Quest type removeall: empty a certain level of a certain node
    local level = Gamestate.get(quest.removeall.level)
    for _,node in pairs(level.nodes) do
      if node.name == quest.removeall.name then
        return false
      else
        success = true
      end
    end
  end
  return success
end

function Quest.completeQuestFail(npc, player, quest)
  Dialog.new(quest.completeQuestFail, function()
    npc.menu:close(player)
  end)
end

function Quest.drug(npc, player, dbSet, level, door)
  local db = app.gamesaves:active()
  local value = dbSet
  db:set(value, true)
  local current = Gamestate.currentState()
  if current.name ~= level then
    current:exit(level, door)
  end
end

function Quest.completeQuestSucceed(npc, player, quest)
  local gamesave = app.gamesaves:active()
  local completed_quests = gamesave:get( 'completed_quests' ) or {}
  if completed_quests and type(completed_quests) ~= 'table' then
    completed_quests = json.decode( completed_quests )
  end
  table.insert(completed_quests, {questParent = quest.questParent, questName = quest.questName})
  gamesave:set( 'completed_quests', json.encode( completed_quests ) )

  Dialog.new(quest.completeQuestSucceed, function()
    if quest.reward.affection then
      npc:affectionUpdate(quest.reward.affection)
      player:affectionUpdate(quest.questParent, quest.reward.affection)
    end
    if quest.reward.money then
      player.money = player.money + quest.reward.money
    end
    if quest.reward.drug then
      local dbSet = quest.reward.dbSet
      local level = quest.reward.level
      local door = quest.reward.door
      Quest.drug(npc, player, dbSet, level, door)
    end
    if quest.collect then
      player.inventory:removeManyItems(1, quest.collect)
    end
    Quest.removeQuestItem(player)
    npc.menu:close(player)
  end)
end

return Quest
