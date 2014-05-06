local anim8 = require 'vendor/anim8'
local window = require 'window'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local Zord = {}
Zord.__index = Zord
Zord.isZord = true

---
-- Creates a new Zord object
-- @param node the table used to create this
-- @param a collider of objects
-- @return the Zord object created
function Zord.new(node, collider)
    --creates a new object
    local zord = {}
    --sets it to use the functions and variables defined in Zord
    -- if it doesn;t have one by that name
    setmetatable(zord, Zord)
    --stores all the parameters from the tmx file
    zord.node = node
    
    zord.position = {x = node.x, y = node.y}
    zord.width = node.width
    zord.height = node.height
    
    --initialize the node's bounding box
    zord.collider = collider
    zord.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    zord.bb.node = zord
    zord.collider:setPassive(zord.bb)
    
    --define some offsets for the bounding box that can be used each update cycle
    zord.bb_offset = {x = 0,y = 0}
    
    --add more initialization code here if you want
    
    return zord
end

---
-- Draws the Zord to the screen
-- @return nil
function Zord:draw()
    --to access the field called "foo" of this node do the following:
    -- self.foo
end

function Zord:keypressed( button, player )
end

---
-- Called when the Zord begins colliding with another node
-- @param node the node you're colliding with
-- @param dt ?
-- @param mtv_x amount the node must be moved in the x direction to stop colliding
-- @param mtv_y amount the node must be moved in the y direction to stop colliding
-- @return nil
function Zord:collide(node, dt, mtv_x, mtv_y)
end

---
-- Called when the Zord finishes colliding with another node
-- @return nil
function Zord:collide_end(node, dt)
end

---
-- Updates the Zord
-- dt is the amount of time in seconds since the last update
function Zord:update(dt)

    --do this immediately before leaving the function
    -- repositions the bounding box based on your current coordinates
    local x1,y1,x2,y2 = self.bb:bbox()
    self.bb:moveTo( self.position.x + (x2-x1)/2 + self.bb_offset.x,
                 self.position.y + (y2-y1)/2 + self.bb_offset.y )
end

return Zord