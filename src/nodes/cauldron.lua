-- made by Nicko21
local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local fonts = require 'fonts'
local sound = require 'vendor/TEsound'
local Cauldron = {}
Cauldron.__index = Cauldron


function Cauldron.new(node, collider)
  local cauldron = {}
  setmetatable(cauldron, Cauldron)
  cauldron.name = node.name ~= "" and node.name or 'cauldron'
  cauldron.message = node.properties.message or 'brew a potion'
  cauldron.x = node.x
  cauldron.y = node.y
  cauldron.height = node.height
  cauldron.width = node.width
  cauldron.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  cauldron.bb.node = cauldron
  cauldron.image = love.graphics.newImage('images/potions/'..cauldron.name..'.png')
  collider:setPassive(cauldron.bb)
  return cauldron
end

function Cauldron:enter(dt)
  fonts.reset()
end

function Cauldron:update(dt)
end

function Cauldron:draw()
  love.graphics.draw(self.image, self.x, self.y, 0, 1)
end

function Cauldron:keypressed( button, player )
  if button == 'INTERACT' then
    -- Checks if the player has items to brew with
    local playerMaterials = player.inventory.pages.materials
    local count = #playerMaterials
    if count == 0 then
      -- Tell the player to get ingredients
      player.freeze = true
      player.invulnerable = true
      local message = {'You will need some ingredients if you want to '..self.message..'!'}
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
    local message = {'Would you like to '..self.message..'?'}
    local options = {'Yes', 'No'}
    local callback = function(result) 
      self.prompt = nil
      player.freeze = false
      if result == 'Yes' then
        local screenshot = love.graphics.newImage(love.graphics.newScreenshot())
        Gamestate.stack('brewing', player, screenshot, self.name)
      end
    end
    self.prompt = Prompt.new(message, callback, options)
    return true
  end
end

return Cauldron
