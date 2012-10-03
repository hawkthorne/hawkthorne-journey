local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Blackjack = {}
Blackjack.__index = Blackjack

function Blackjack.new(node, collider)
    local blackjack = {}
    setmetatable(blackjack, Blackjack)
    blackjack.x = node.x
    blackjack.y = node.y
    blackjack.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    blackjack.bb.node = blackjack
    collider:setPassive(blackjack.bb)
    return blackjack
end

function Blackjack:update(dt)
    if self.prompt then self.prompt:update(dt) end
end

function Blackjack:draw()
    if self.prompt then
        self.prompt:draw(self.x + 20, self.y - 35)
    end
end

function Blackjack:keypressed(key, player)
    if (key == 'rshift' or key == 'lshift') and self.prompt == nil then
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
        self.prompt:keypressed(key)
    end
end

return Blackjack


