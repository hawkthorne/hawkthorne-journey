-----------------------------------------------
-- recipe.lua
-- Represents a recipe when it is in the world
-- Created by HazardousPeach
-----------------------------------------------

local game = require 'game'
local collision  = require 'hawk/collision'
local Item = require 'items/item'
local utils = require 'utils'

local Recipe = {}
Recipe.__index = Recipe
Recipe.isRecipe = true

---
-- Creates a new recipe object
-- @return the recipe object created
function Recipe.new(node, collider)
  local recipe = {}
  setmetatable(recipe, Recipe)
  recipe.name = node.name
  recipe.type = 'recipe'
  recipe.image = love.graphics.newImage('images/recipes/'..recipe.name..'.png')
  recipe.image_q = love.graphics.newQuad( 0, 0, 24, 24, recipe.image:getWidth(),recipe.image:getHeight() )
  recipe.foreground = node.properties.foreground
  recipe.collider = collider
  recipe.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  recipe.bb.node = recipe
  collider:setSolid(recipe.bb)
  collider:setPassive(recipe.bb)

  recipe.position = {x = node.x, y = node.y}
  recipe.velocity = {x = 0, y = 0}
  recipe.width = node.width
  recipe.height = node.height
  recipe.bb_offset_x = (24 - node.width) / 2 -- positions bb for recipes smaller than 24px

  recipe.touchedPlayer = nil
  recipe.exists = true
  recipe.dropping = false

  return recipe
end

---
-- Draws the recipe to the screen
-- @return nil
function Recipe:draw()
  if not self.exists then
    return
  end
  love.graphics.draw(self.image, self.image_q, self.position.x, self.position.y)
end


function Recipe:keypressed( button, player )
  if button ~= 'INTERACT' then return end

  local itemNode = utils.require( 'items/recipes/' .. self.name )
  itemNode.type = 'recipe'
  local item = Item.new(itemNode, self.quantity)
  local callback = function()
    self.exists = false
    self.containerLevel:saveRemovedNode(self)
    self.containerLevel:removeNode(self)
    self.collider:remove(self.bb)
  end
  player.inventory:addItem(item, false, callback)
end

---
-- Called when the recipe begins colliding with another node
-- @return nil
function Recipe:collide(node, dt, mtv_x, mtv_y)
  if node and node.character then
    self.touchedPlayer = node
  end
end

---
-- Called when the recipe finishes colliding with another node
-- @return nil
function Recipe:collide_end(node, dt)
  if node and node.character then
    self.touchedPlayer = nil
  end
end

---
-- Updates the recipe and allows the player to pick it up.
function Recipe:update(dt, player, map)
  if not self.exists then
    return
  end
  if self.dropping then  
    local nx, ny = collision.move(map, self, self.position.x, self.position.y,
                                  self.width, self.height, 
                                  self.velocity.x * dt, self.velocity.y * dt)
    self.position.x = nx
    self.position.y = ny

    -- X velocity won't need to change
    self.velocity.y = self.velocity.y + game.gravity*dt
    
    self.bb:moveTo(self.position.x + self.width / 2 + self.bb_offset_x, self.position.y + self.height / 2)
  end
end

-- function Recipe:drop(player)
  -- if player.footprint then
    -- self:floorspace_drop(player)
    -- return
  -- end

  -- self.dropping = true
-- end

-- function Recipe:floorspace_drop(player)
  -- self.dropping = false
  -- self.position.y = player.footprint.y - self.height

  -- self.containerLevel:saveAddedNode(self)
-- end

-- function Recipe:floor_pushback()
  -- if not self.exists or not self.dropping then return end
  
  -- self.dropping = false
  -- self.velocity.y = 0
  -- self.collider:setPassive(self.bb)

  -- self.containerLevel:saveAddedNode(self)
-- end

return Recipe
