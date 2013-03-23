local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local fonts = require 'fonts'
local Dealer = {}
Dealer.__index = Dealer

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

function Dealer:enter(dt)
    fonts.reset()
end

function Dealer:update(dt)
end

function Dealer:draw()
end

function Dealer:keypressed( button, player )

    if button == 'INTERACT' then
        player.freeze = true

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
              Gamestate.switch(result:lower() .. 'game', player, screenshot)
            end
        end

        self.prompt = Prompt.new(message, callback, options)
        return true
    end
end

return Dealer


