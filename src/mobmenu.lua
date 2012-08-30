local Dialog = require 'dialog'
local window = require "window"
local sound = require 'vendor/TEsound'
local anim8 = require 'vendor/anim8'

local heartImage = love.graphics.newImage('images/selector.png')
local menuImage = love.graphics.newImage('images/human-being_menu.png')
local h = anim8.newGrid(69, 43, menuImage:getWidth(), menuImage:getHeight())

local Menu = {}
Menu.__index = Menu

local menuDefinition = { }

local responses = { }

function Menu.new(items, answers)
   	local menu = {}
	setmetatable(menu, Menu)
    menu.rootItems = items
    menu.items = items
    menu.itemWidth = 150
    menu.choice = 1
    menu.offset = 0
    menu.animation = anim8.newAnimation('once', h('1-6,1'), .08)
    menu.state = 'closed'
	menu.responses = answers
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

    local oldFont = love.graphics.getFont()
    love.graphics.setFont(window.font)
    love.graphics.setColor(0, 0, 0)

    y = y + 36

    for i, value in ipairs(self.items) do
        i = i - self.offset
        if i > 0 then
            love.graphics.printf(value.text, x - self.itemWidth, y - (i - 1) * 12,
                                 self.itemWidth, 'right')

            if self.choice == i then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(heartImage, x + 2, y - (i - 1) * 12 + 2)
                love.graphics.setColor(0, 0, 0)
            end
        end
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(oldFont)
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

return Menu
