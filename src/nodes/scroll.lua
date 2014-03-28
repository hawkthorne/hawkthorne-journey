local anim8 = require 'vendor/anim8'
local game = require 'game'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local window = require 'window'
local Player = require 'player'
local sound = require 'vendor/TEsound'
local Gamestate = require 'vendor/gamestate'

local Scroll = {}
Scroll.__index = Scroll

-- This is the class that handles scrolls when dropped
-- Some of the functions left here to support future physics

function Scroll.new(node, collider)
    local scroll = {}
    setmetatable(scroll, Scroll)

    local name = node.name
    
    scroll.type = 'scroll'
    scroll.name = name
    scroll.props = require( 'nodes/projectiles/' .. name )
    
    scroll.width = scroll.props.drop_width or 15
    scroll.height = scroll.props.drop_height or 15

    local dir = node.directory or "scrolls"
    scroll.sheet = love.graphics.newImage('images/'..dir..name..'.png')
    local quadY = scroll.sheet:getHeight() - 15
    scroll.thumbnail = love.graphics.newQuad(0, quadY, scroll.width, scroll.height,
                                             scroll.sheet:getWidth(), scroll.sheet:getHeight())
    scroll.foreground = scroll.props.foreground

    scroll.collider = collider
    scroll.bb = collider:addRectangle(node.x, node.y, scroll.width , scroll.height ) -- uses drop_image height 
    scroll.bb.node = scroll
    collider:setSolid(scroll.bb)
    
    scroll.dropping = false

    scroll.position = { x = node.x, y = node.y }
    scroll.velocity = { x = node.x, y = node.y }
    
    return scroll
end

function Scroll:draw()
    if self.dead then return end
    love.graphics.draw(self.sheet, self.thumbnail, math.floor(self.position.x), self.position.y)
end

function Scroll:update(dt)
    if self.dropping then
        -- gravity
        self.position = {x = self.position.x + self.velocity.x*dt,
                         y = self.position.y + self.velocity.y*dt
                        }
        -- X velocity won't need to change
        self.velocity.y = self.velocity.y + game.gravity*dt
        
        self.bb:moveTo(self.position.x + self.width / 2, self.position.y + self.height / 2)
    end
end

function Scroll:keypressed( button, player)
    if self.player then return end

    if button == 'INTERACT' then
        --the following invokes the constructor of the specific item's class
        local Item = require 'items/item'
        local itemNode = require ('items/misc/'..self.name)
        local item = Item.new(itemNode, self.quantity)
        if player.inventory:addItem(item) then
            if self.bb then
                self.collider:remove(self.bb)
            end
            self.containerLevel:removeNode(self)
            self.dead = true
            if not player.currently_held then
                item:select(player)
            end
            -- Key has been handled, halt further processing
            return true
        end
    end
end

function Scroll:moveBoundingBox()
    if self.dead then return end
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + self.height / 2 )
end

function Scroll:drop(player)
    if player.footprint then
        self:floorspace_drop(player)
        return
    end
    
    self.dropping = true
end

function Scroll:floorspace_drop(player)
    self.dropping = false
    self.position.y = player.footprint.y - self.height
end

function Scroll:floor_pushback(node, new_y)
    if not self.dropping then return end
    
    self.dropping = false
    self.position.y = new_y
    self.velocity.y = 0
    self.collider:setPassive(self.bb)
end

function Scroll:wall_pushback(node, new_x)
end

return Scroll

