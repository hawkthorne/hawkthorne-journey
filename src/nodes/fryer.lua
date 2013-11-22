-- made by Nicko21
local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local fonts = require 'fonts'
local sound = require 'vendor/TEsound'
local Fryer = {}
Fryer.__index = Fryer


function Fryer.new(node, collider)
    local fryer = {}
    setmetatable(fryer, Fryer)
    fryer.x = node.x
    fryer.y = node.y
    fryer.height = node.height
    fryer.width = node.width
    fryer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    fryer.bb.node = fryer
    fryer.image = love.graphics.newImage('images/potions/fryer.png')
    collider:setPassive(fryer.bb)
    return fryer
end

function Fryer:enter(dt)
    fonts.reset()
end

function Fryer:update(dt)
end

function Fryer:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1)
end

function Fryer:keypressed( button, player )
    if button == 'INTERACT' then
        -- Checks if the player has items to brew with
        local playerMaterials = player.inventory.pages.materials
        local itemCount = 0
        for _ in pairs(playerMaterials) do itemCount = itemCount + 1 end 
        if (itemCount == 0) then
            -- Tell the player to get ingredients
            player.freeze = true
            player.invulnerable = true
            local message = {'You need some ingredients if you want to fry!'}
            local callback = function(result)
                 self.prompt = nil
                 player.freeze = false
                 player.invulnerable = false
            end
            local options = {'Exit'}
            self.prompt = Prompt.new(message, callback, options)
            return
        end
        -- They have items
        player.freeze = true
        local message = {'Would you like to fry something?'}
        local options = {'Yes', 'No'}
        local callback = function(result) 
            self.prompt = nil
            player.freeze = false
            if result == 'Yes' then
                local screenshot = love.graphics.newImage(love.graphics.newScreenshot())
                Gamestate.stack('frying', player, screenshot)
            end
        end
        self.prompt = Prompt.new(message, callback, options)
        return true
    end
end

return Fryer
