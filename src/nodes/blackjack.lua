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
        self.prompt:draw(self.x + 78, self.y - 35)
    end
end

function Blackjack:keypressed(button, player)
    if button.a and (self.prompt == nil or self.prompt.state ~= 'closed') then
        player.freeze = true
        self.prompt = Prompt.new(120, 55, "Play Blackjack?", function(result)
            player.freeze = false
            if result then
                local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
                Gamestate.switch('blackjackgame', screenshot)
            end
        end)
    end

    if self.prompt then
        self.prompt:keypressed(button)
    end
end

return Blackjack


