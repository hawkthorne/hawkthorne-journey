local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local Dialog = require 'dialog'
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
    if self.prompt then self.prompt:update(dt) end
    if self.dialog then self.dialog:update(dt) end
end

function Dealer:draw()
    if self.prompt then
        self.prompt:draw(self.x + 20, self.y - 35)
    end
    if self.dialog then
        self.dialog:draw( self.x, self.y - 30 )
    end
end

function Dealer:keypressed( button, player )
    if self.prompt then
        self.prompt:keypressed( button )
    end
    if self.dialog then
        self.dialog:keypressed(button)
    end
    
    if button == 'ACTION' and player.money == 0 and self.dialog == nil then
        player.freeze = true
        self.dialog = Dialog.new(115, 50, {'You dont have enough money!','Come back again...'}, function()
            player.freeze = false
            self.dialog = nil
        end)
    elseif button == 'ACTION' and player.money > 0 and self.prompt == nil then
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
                Gamestate.switch(state, player, screenshot)
            end
            self.prompt = nil
        end, {'Poker','Blackjack','Close'} )
    end
end

return Dealer


