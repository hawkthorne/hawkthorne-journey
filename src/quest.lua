-- quest.lua

local Dialog = require 'dialog'
local prompt = require 'prompt'


local Quest = {}

function Quest:activate(npc, player, quest)
  if not player.quest then
    self.giveQuestSucceed(npc,player,quest)
  elseif player.quest == quest.questName then
    self:completeQuest(npc,player,quest)
  else
    self.giveQuestFail(npc,player,quest)
  end
end

function Quest.giveQuestSucceed(npc, player, quest)
  local script = quest.giveQuestSucceed
  Dialog.new (script, function()
    npc.prompt = prompt.new(quest.successPrompt, function(result)
      if result == 'Yes' then
        player.quest = quest.questName
        player.questParent = quest.questParent
      end
      npc.menu:close(player)
      npc.prompt = nil
    end)
  end)
end

function Quest.giveQuestFail(npc, player, quest)
  local script = "You already have quest '" .. player.quest .. "' for {{red_light}}" .. player.questParent .. "{{white}}!"
  script = quest.giveQuestFail or script
  Dialog.new(script, function()
    npc.menu:close(player)
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
    if quest.collect.type == 'consumable' then
      success = player.inventory:hasConsumable(quest.collect.name)
    elseif quest.collect.type == 'material' then
      success = player.inventory:hasMaterial(quest.collect.name)
    end
  end
  return success
end

function Quest.completeQuestFail(npc, player, quest)
  Dialog.new(quest.completeQuestFail, function()
    npc.menu:close(player)
  end)
end

function Quest.completeQuestSucceed(npc, player, quest)
  Dialog.new(quest.completeQuestSucceed, function()
    if quest.reward.affection then
      npc:affectionUpdate(quest.reward.affection)
      player:affectionUpdate(quest.questParent, quest.reward.affection)
    end
    if quest.collect then
      player.inventory:removeManyItems(1, quest.collect)
    end
    player.quest = nil
    npc.menu:close(player)
  end)
end

return Quest
