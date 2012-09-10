local anim8 = require 'vendor/anim8'
local Helper = require 'helper'
local Dialog = require 'dialog'
local window = require 'window'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'

local heartImage = love.graphics.newImage('images/selector.png')
local menuImage = love.graphics.newImage('images/human-being_menu.png')
local h = anim8.newGrid(69, 43, menuImage:getWidth(), menuImage:getHeight())

local Menu = {}
Menu.__index = Menu

local menuDefinition = {
    { ['text']='exit' },
    { ['text']='inventory' },
    { ['text']='command' },
    { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='where is ...', ['option']={
            { ['text']='i am done with you' },
            { ['text']="the registrar" },
            { ['text']="the ac repair school" },
            { ['text']="my valentine" },
            { ['text']="my dignity" },
            { ['text']="magnitude" },
            { ['text']="the dean's office", },

        }},
        { ['text']='why are you mumbling?' },
        { ['text']='who are you?' },
    }},
}

local responses = {
    ["who are you?"]={"Mi um a MuUnnn Meee-Ming!",},
    ["why are you mumbling?"]={"Mummmm?",},
    ["the dean's office"]={"Mummmf Ummm!",},
    ["the registrar"]={"Mum Ummf Ummm. Muuurk",},
    ["the ac repair school"]={"Mummf, 'Mor Oy 'un ut ent",},
    ["my valentine"]={"Mummentine?",},
    ["my dignity"]={"?",},
    ["magnitude"]={"Mummop, Mummop",},
}

function Menu.new(items)
   	local menu = {}
	setmetatable(menu, Menu)
    menu.rootItems = items
    menu.items = items
    menu.itemWidth = 150
    menu.choice = 1
    menu.offset = 0
    menu.animation = anim8.newAnimation('once', h('1-6,1'), .08)
    menu.state = 'closed'
    return menu
end

function Menu:keypressed(key, player)
    if self.dialog and (self.state == 'closed' or self.state == 'hidden')
        and key == 'return' then
        self.dialog:keypressed('return')
    end

    if self.state == 'closed' or self.state == 'hidden' then
        return
    end

    if key == 'w' or key == 'up' then
        sound.playSfx( 'click' )
        if self.choice == 4 then
            self.offset = math.min(self.offset + 1, #self.items - 4)
        end
        self.choice = math.min(4, self.choice + 1)
    elseif key == 's' or key == 'down' then
        sound.playSfx( 'click' )
        if self.choice == 1 then
            self.offset = math.max(self.offset - 1, 0)
        end
        self.choice = math.max(1, self.choice - 1)
    elseif key == 'return' then
        sound.playSfx( 'click' )
        local item  = self.items[self.choice + self.offset]
        if item == nil or item.text == 'exit' or item.text == 'i am done with you' then
            self:close()
            player.freeze = false
        elseif responses[item.text] then
            self:hide()
            if item.option then
                self.items = item.option
                self.choice = 4
            end
            self.dialog = Dialog.new(115, 50, responses[item.text], function()
                self:show()
            end)
        elseif type(item.option) == 'table' then
            self.items = item.option
        end
    end
end


function Menu:update(dt)
    if self.state == 'closed' or self.state == 'hidden' then
        if self.dialog then self.dialog:update(dt) end
        return
    end

    if self.state == 'hiding' and self.animation.position == 1 then
        self.state = 'hidden'
    end

    if self.state == 'closing' and self.animation.position == 1 then
        self.state = 'closed'
    end

    self.animation:update(dt)
end

function Menu:draw(x, y)
    fonts.set('arial')
    if self.state == 'closed' or self.state == 'hidden' then
        if self.dialog then self.dialog:draw(x, y) end
        return
    end

    self.animation:draw(menuImage, x + 3, y + 4)

    if self.state == 'opening' and self.animation.position >= 5 then
        self.state = 'opened'
    end

    if self.state ~= 'opened' then
        return
    end

    love.graphics.setColor(0, 0, 0)
    Font = love.graphics.getFont()

    y = y + 36

    for i, value in ipairs(self.items) do
        i = i - self.offset
        if i > 0 then
            love.graphics.printf(value.text, x - self.itemWidth, y - (i - 1) * 12,
                                 self.itemWidth, 'right')

            if self.choice == i then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(heartImage, x - (Font:getWidth(value.text)+8), y - (i - 1) * 12 + 2)
                love.graphics.setColor(0, 0, 0)
            end
        end
    end
    love.graphics.setColor(255, 255, 255)
    fonts.revert()
end

function Menu:open()
    self.items = self.rootItems
    self.choice = 4
    self.offset = 0
    self:show()
end

function Menu:show()
    self.state = 'opening'
    self.animation.direction = 1
    self.animation:gotoFrame(1)
end

function Menu:hide()
    self.animation.direction = -1
    self.state = 'hiding'
end


function Menu:close()
    self.animation.direction = -1
    self.state = 'closing'
end


local Human = {}
Human.__index = Human

local humanImage = love.graphics.newImage('images/human-being.png')
local g = anim8.newGrid(32, 48, humanImage:getWidth(), humanImage:getHeight())

function Human.new(node, collider)
	local human = {}
	setmetatable(human, Human)
	human.image = humanImage
    human.animations = {
        standing = {
            right = anim8.newAnimation('loop', g('1-2,1', '1,1'), 2, {[2]=.1}),
            left = anim8.newAnimation('loop', g('4-5,1', '4,1'), 2, {[2]=.1}),
        },
        talking = {
            right = anim8.newAnimation('loop', g('3,1', '3,1'), .8, {[2]=.3}),
            left = anim8.newAnimation('loop', g('6,1', '6,1'), .8, {[2]=.3}),
        },
    }

	human.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	human.bb.node = human
    human.collider = collider
	human.collider:setPassive(human.bb)
    human.state = 'standing'
    human.direction = 'left'

    human.width = node.width
    human.height = node.height
	human.position = { x = node.x + 12, y = node.y }
	human.maxx = node.x + 48
	human.minx = node.x - 48
    human.menu = Menu.new(menuDefinition)
	return human
end

function Human:draw()
    local animation = self.animations[self.state][self.direction]
	animation:draw(self.image, math.floor(self.position.x), self.position.y)
    self.menu:draw(self.position.x, self.position.y - 50)
end

function Human:update(dt, player)
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
        self.state = 'standing'
    end

    self.menu:update(dt)
end

function Human:keypressed(key, player)
    if (key == 'rshift' or key == 'lshift') then
        if player.position.x < self.position.x then
            self.direction = 'left'
            player.direction = 'right'
        else
            self.direction = 'right'
            player.direction = 'left'
        end
    end

    if (key == 'rshift' or key == 'lshift') and self.state == 'standing' and not player.jumping and self.menu.state == 'closed' then
        player.freeze = true
        player.state = 'idle'
        self.state = 'standing'
        self.menu:open()
    end

    if player.freeze then
        self.menu:keypressed(key, player)
    end
end

return Human
