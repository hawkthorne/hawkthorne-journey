--special mailbox node for a Save Greendale quest with Frankie

local Dialog = require 'dialog'
local anim8 = require 'vendor/anim8'
local utils = require 'utils'
local prompt = require 'prompt'
local player = require 'player'
local Quest = require 'quest'
local quests = require 'npcs/quests/frankiequest'

local Mailbox = {}
Mailbox.__index = Mailbox

function Mailbox.new(node, collider)
  local mailbox = {}
  setmetatable(mailbox, Mailbox)
  mailbox.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  mailbox.bb.node = mailbox
  Mailbox.node = node
  collider:setPassive(mailbox.bb)

  return mailbox
end

function Mailbox:keypressed( button, player )
  if button == 'INTERACT' and self.dialog == nil and not player.freeze then
    if player.quest == 'Save Greendale - Mail Diane' and player.inventory:hasKey('document') then
      self.prompt = prompt.new("Deposit document into mailbox?", function(result)
        if result == 'Yes' then
          player.freeze = true
          player.inventory:removeManyItems(1, {name='document',type='key'})
          Dialog.new("Document successfuly deposited into the mailbox! Cue montage and return to Frankie.", function()
            Quest.removeQuestItem(player)
            Quest.addQuestItem(quests.dianereturn, player)
            player.quest = 'Save Greendale - Return to Frankie'
            Quest:save(quests.dianereturn)
          end)
        end
        player.freeze = false
        self.prompt = nil
      end)
    elseif player.quest == 'Save Greendale - Mail Diane' and not player.inventory:hasKey('document') then
      player.freeze = true
      Dialog.new("The document seems to be missing from your inventory. Cue montage of trying to find it!", function()
        player.freeze = false
        Dialog.currentDialog = nil
      end)
    else
      player.freeze = true
      Dialog.new("You don't have anything to mail right now.", function()
        player.freeze = false
        Dialog.currentDialog = nil
      end)
    end
    return true
  end
end

return Mailbox
