local sound = require 'vendor/TEsound'
local Dialog = require 'dialog'
local Timer = require 'vendor/timer'
local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local fonts = require 'fonts'
local Dealer = {}

Dealer.__index = Dealer
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Dealer.isInteractive = true

function Dealer.new(node, collider)
  local dealer = {}
  setmetatable(dealer, Dealer)
  dealer.x = node.x
  dealer.y = node.y
  dealer.height = node.height
  dealer.width = node.width
  dealer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  dealer.bb.node = dealer
  collider:setPassive(dealer.bb)
  return dealer
end

function Dealer:enter(previous)
  fonts.reset()

  --Dealer says "Let's play poker" after a few seconds when player enters the tavern.
  if not self.dialog then
    self.dialog = Timer.add(math.random(3,4), function()
      self.poker_dialog = Dialog.new("Let's play {{yellow}}poker{{white}}.")
      sound.playSfx("letsPlayPoker")
    end)
  end
end

function Dealer:leave()
  --The timers are canceled upon leaving so the dialog and sound don't occur outside the tavern.
  Timer.cancel(self.dialog)
  if self.poker_dialog then
    self.poker_dialog:close()
  end
end

function Dealer:keypressed( button, player )
  if button == 'INTERACT' then
    player.freeze = true

    --Timers for "Let's play poker" cancel upon interaction with the dealer.
    Timer.cancel(self.dialog)

    local message = {'Choose a card game to play'}
    local options = {'Poker', 'Blackjack', 'Exit'}

    if player.money == 0 then
      message = {'You dont have enough money!','Come back again...'}
      options = {'Exit'}
    end

    local callback = function(result)
      self.prompt = nil
      player.freeze = false
      if result == 'Poker' or result == 'Blackjack' then
        local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
        Gamestate.stack(result:lower() .. 'game', player, screenshot)
      end
    end

    self.prompt = Prompt.new(message, callback, options)
    return true
  end
end

return Dealer
