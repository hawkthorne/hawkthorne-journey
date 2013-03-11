--MUST READ: 
-- to use this file do the following
-- 1)find and replace each capitalized instance of NodeTemplate
-- with a capitalized version of your node's name
-- 2) find and replace each lowercase instance of nodeTemplate
-- with a lowercase version of your node's name(this should be the same as the filename)
-- 3) start coding

-----------------------------------------------
-- NodeTemplate.lua
-----------------------------------------------

local NodeTemplate = {}
NodeTemplate.__index = NodeTemplate
NodeTemplate.isNodeTemplate = true

---
-- Creates a new NodeTemplate object
-- @param node the table used to create this
-- @param a collider of objects
-- @return the NodeTemplate object created
function NodeTemplate.new(node, collider)
    --creates a new object
    local nodeTemplate = {}
    --sets it to use the functions and variables defined in NodeTemplate
    -- if it doesn;t have one by that name
    setmetatable(nodeTemplate, NodeTemplate)
    
    --initialize the node's bounding box
    nodeTemplate.collider = collider
    nodeTemplate.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    nodeTemplate.bb.node = nodeTemplate
    nodeTemplate:setPassive(nodeTemplate.bb)
    
    --add more initialization code here if you want
    
    return nodeTemplate
end

---
-- Draws the NodeTemplate to the screen
-- @return nil
function NodeTemplate:draw()
    --to access the field called "foo" of this node do the following:
    -- self.foo
end

function NodeTemplate:keypressed( button, player )
end

---
-- Called when the NodeTemplate begins colliding with another node
-- @param node the node you're colliding with
-- @param dt ?
-- @param mtv_x amount the node must be moved in the x direction to stop colliding
-- @param mtv_y amount the node must be moved in the y direction to stop colliding
-- @return nil
function NodeTemplate:collide(node, dt, mtv_x, mtv_y)
end

---
-- Called when the NodeTemplate finishes colliding with another node
-- @return nil
function NodeTemplate:collide_end(node, dt)
end

---
-- Updates the NodeTemplate
-- dt is the amount of time in seconds since the last update
function NodeTemplate:update(dt)
end

return NodeTemplate
