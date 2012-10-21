local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Dealer = {}
Dealer.__index = Dealer

function Dealer.new(node, collider)
    local dealer = {}
    setmetatable(dealer, Dealer)
    dealer.x = node.x
    dealer.y = node.y
    dealer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    dealer.bb.node = dealer
    collider:setPassive(dealer.bb)
    return dealer
end

function Dealer:update(dt)
    if self.prompt then self.prompt:update(dt) end
end

function Dealer:draw()
    if self.prompt then
        self.prompt:draw(self.x + 20, self.y - 35)
    end
end

function Dealer:keypressed( button, player )
    if button == 'A' and self.prompt == nil then
        player.freeze = true
        self.prompt = Prompt.new(140, 65, "Choose your game:", function(result)
            player.freeze = false
            if result ~= 3 then
                if(result == 1) then
                    state = 'pokergame'
                elseif(result == 2) then
                    state = 'blackjackgame'
                end
                local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
                Gamestate.switch(state, screenshot)
            end
            self.prompt = nil
        end, {'Poker','Blackjack','Close'} )
    end

    if self.prompt then
        self.prompt:keypressed( button, dt )
    end
end

return Dealer


