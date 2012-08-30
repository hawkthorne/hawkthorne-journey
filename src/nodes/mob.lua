local Helper = require 'helper'
local anim8 = require 'vendor/anim8'
local Menu = require 'mobmenu'

local Mob = {}
Mob.__index = Mob

local menuDefinition = {
    { ['text']='exit' },
    { ['text']='inventory' },
    { ['text']='command' },
    { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='directions' },
        { ['text']='help' },
        { ['text']='classes' },
    }},
}

local menuResponses = {
    ["directions"]={
        "Only way out of Greendale is through the library.",
        },
}


function Mob.new(node, collider)

    local mob = {}
    local mobImage = love.graphics.newImage(node.properties.sprites)

    setmetatable(mob, Mob)

    mob.image = mobImage

    if (node.properties.sheetformat == 1) then
        local g = anim8.newGrid(36, 48, mobImage:getWidth(), mobImage:getHeight())
        mob.animations = {
            walking = {
                right = anim8.newAnimation('loop', g('4-6,2'), .18),
                left = anim8.newAnimation('loop', g('4-6,1'), .18),
            },
            standing = {
                right = anim8.newAnimation('loop', g('1,2', '2,2'), 2, {[2]=.1}),
                left = anim8.newAnimation('loop', g('1,1', '2,1'), 2, {[2]=.1}),
            },
            talking = {
                right = anim8.newAnimation('loop', g('1,2', '3,2'), .8, {[2]=.3}),
                left = anim8.newAnimation('loop', g('1,1', '3,1'), .8, {[2]=.3}),
            },
        }
    else
        local g = anim8.newGrid(48, 48, mobImage:getWidth(), mobImage:getHeight())
        mob.animations = {
            walking = {
                right = anim8.newAnimation('loop', g('2-4,2'), .18),
                left = anim8.newAnimation('loop', g('2-4,1'), .18),
            },
            standing = {
                right = anim8.newAnimation('loop', g('1,2', '8,2'), 2, {[2]=.4}),
                left = anim8.newAnimation('loop', g('1,1', '8,1'), 2, {[2]=.4}),
            },
            talking = {
                right = anim8.newAnimation('loop', g('1,2', '5,2'), .8, {[2]=.3}),
                left = anim8.newAnimation('loop', g('1,1', '5,1'), .8, {[2]=.3}),
            },
        }
    end

    mob.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    mob.bb.node = mob
    mob.collider = collider
    mob.collider:setPassive(mob.bb)
    mob.state = 'walking'
    mob.direction = 'right'

    mob.width = node.width
    mob.height = node.height
    mob.position = { x = node.x + 12, y = node.y }
    mob.maxx = node.x + node.properties.roam
    mob.minx = node.x - node.properties.roam
    mob.menu = Menu.new(menuDefinition, menuResponses)
    return mob
end

function Mob:draw()
    local animation = self.animations[self.state][self.direction]
    animation:draw(self.image, math.floor(self.position.x), self.position.y)
    self.menu:draw(self.position.x, self.position.y - 50)
end

function Mob:update(dt, player)
    local animation = self.animations[self.state][self.direction]
    animation:update(dt)

    if self.position.x > self.maxx then
        self.direction = 'left'
    elseif self.position.x < self.minx then
        self.direction = 'right'
    end

    local direction = self.direction == 'right' and 1 or -1

    if self.state == 'walking' then
        self.position.x = self.position.x + 18 * dt * direction
        Helper.moveBoundingBox(self)
    elseif self.menu.dialog == nil or self.menu.dialog.state == 'closed' then
        self.state = 'standing'
    else
        self.state = 'talking'
    end

    if self.menu.state == 'closed' then
        self.state = 'walking'
    end

    self.menu:update(dt)
end

function Mob:keypressed(key, player)
    if (key == 'rshift' or key == 'lshift') then
        if player.position.x < self.position.x then
            self.direction = 'left'
            player.direction = 'right'
            self.position.x = player.position.x+35
        else
            self.direction = 'right'
            player.direction = 'left'
            self.position.x = player.position.x-20
        end
    end

    if (key == 'rshift' or key == 'lshift') and self.state == 'walking' and not player.jumping then
        player.freeze = true
        player.state = 'idle'
        self.state = 'standing'

        self.menu:open()
    end

    if player.freeze then
        self.menu:keypressed(key, player)
    end
end

return Mob
