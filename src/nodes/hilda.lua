local anim8 = require 'vendor/anim8'
local Helper = require 'helper'
local Dialog = require 'dialog'
local window = require "window"

local heartImage = love.graphics.newImage('images/heart.png')
local menuImage = love.graphics.newImage('images/hilda_menu.png')
local menuBlip = love.audio.newSource('audio/click.ogg')
local h = anim8.newGrid(69, 43, menuImage:getWidth(), menuImage:getHeight())

local Menu = {}
Menu.__index = Menu

local menuDefinition = {
    { ['text']='exit' },
    { ['text']='inventory' },
    { ['text']='command' },
    { ['text']='talk', ['option']={
        { ['text']='i am done with you' },
        { ['text']='i will wear your skin' },
        { ['text']='madam, i am on a quest', ['option']={
            { ['text']='more...', ['option']={
                { ['text']='i am done with you' },
                { ['text']='frog extinction' },
                { ['text']='ostrich' },
                { ['text']='other parrot' },
                { ['text']='anglerfish' },
                { ['text']='seal' },
                { ['text']='spider' },
                { ['text']='snake' },
                { ['text']='parrot' },
                { ['text']='swordfish' },
                { ['text']='rhino' },
                { ['text']='magic carpet' },
                { ['text']='rocket ship' },
                { ['text']='albatross' },
                { ['text']='ladder bug' },
                { ['text']='hidden pipe' },
                { ['text']='subcon vase' },
                { ['text']='magic flute' },
                { ['text']='star zone' },
                { ['text']='rashes' },
                { ['text']='zits' },
                { ['text']='pimples' },
                { ['text']='dark queen' },
                { ['text']='mechanical' },
                { ['text']='stoneship' },
                { ['text']='channel wood' },
                { ['text']='space ship' },
                { ['text']='old man trainer' },
                { ['text']='fly on a bird' },
                { ['text']='cinnamon island' },
                { ['text']='seal along the shore' },
                { ['text']='black lightning' },
                { ['text']='hornet' },
                { ['text']='shredder' },
                { ['text']='avenger' },
                { ['text']='wine hat' },
                { ['text']='magic feather' },
                { ['text']='raccoon clothes' },
                { ['text']='running jump' },
                { ['text']='collect all blue coins' },
                { ['text']='island of annoying voices' },
                { ['text']='hot tub end boss' },
                { ['text']='mustached mushroom' },
                { ['text']='bell toss' },
                { ['text']='charged fireball' },
                { ['text']='time bombs' },
                { ['text']='rock punch' },
                { ['text']='blue fire' },
                { ['text']='green fire' },
                { ['text']='purple fire' },
                { ['text']='boring regular old fire' },
                { ['text']='flying war ships' },
                { ['text']='clown face helicopter' },
                { ['text']='teeter totter flying floor' },
                { ['text']='unstable bath' },
                { ['text']='impervious to lava' },
                { ['text']='underwater exploration' },
                { ['text']='hover puppy' },
                { ['text']='giant ant dance club' },
                { ['text']='good karma quests' },
                { ['text']='fun quests' },
                { ['text']='unkillable bears' },
                { ['text']='antiphysics horse' },
                { ['text']='bubble attack' },
                { ['text']='leaf attack' },
                { ['text']='time freeze attack' },
                { ['text']='metal blade attack' },
                { ['text']='egg treatment' },
                { ['text']='blue poultry' },
                { ['text']='the chicken lady' },
                { ['text']='forest fungus' },
                { ['text']='wild children' },
                { ['text']='trippy potions' },
                { ['text']='pharmacist' },
                { ['text']='sawing small trees' },
                { ['text']='carpenter camps' },
                { ['text']='broken swords' },
                { ['text']='giant rock monster' },
                { ['text']='frog prescriptions' },
                { ['text']='vision medication' },
                { ['text']='brick vouchers' },
                { ['text']='extra large swords' },
            }},
            { ['text']='i am done with you' },
            { ['text']='throne of hawkthorne' },
            { ['text']='for your hand' },
        }},
        { ['text']='stand aside' },
    }},
}

local responses = {
    ['madam, i am on a quest']={
        'I can help with that',
        'I have information on many topics...',
    },
    ['throne of hawkthorne']={
        'The throne is in Castle Hawkthorne,',
        'north of here. You unlock the castle with',
        'the white crystal of discipline,',
        'which you must free from the black caverns.',
    },
    ['frog extinction']={
        'You know what? My prank is going to cause a sea of',
        'laughter, and I am going to watch you drown in it!',
    },
    ['ostrich']={
        "I like ostriches, but also, I don't?",
        "I don't support ostriches. They're unfair to pigeons.",
        "I guess that's why you never see them",
        "on the same continent.",
    },
    ['other parrot']={
        'In the toughest jungle in the world,',
        "there are the big time parrots,",
        "and then there's the Other Parrots.",
    },
    ['anglerfish']={
        "A violent fish, prone to aggression.",
        "You wouldn't like him when he's anglery",
    },
    ['seal']={
        "You can unlock this by getting kissed,",
        "by a rose on the grey",
    },
    ['spider']={
        "We're gonna make Spiderman black now?",
        "Why don't we just have Michael Cera play Shaft?",
    },
    ['snake']={
        "Snake? Snake?!",
        "SNAAAAAAKKK EEEEEE!!!",
    },
    ['parrot']={
        "This parrot is no more!",
        "He has ceased to be!",
    },
    ['swordfish']={
        "An underrated movie starring Wolverine,",
        "it's still not as good as Blade.",
    },
    ['rhino']={
        "Oh, this was just a nickname that I got in college.",
        "Don't worry about it.",
    },
    ['magic carpet']={
        "Almost always piloted by friendly...",
        "yet sexually ambiguous Glee club instructors.",
    },
    ['rocket ship']={
        "Just as KFC's secret process seals in the flavor,",
        "I'm sealing in the cabin's air",
        "so you don't explode on your journey.",
    },
    ['albatross']={
        "Albatrosses are one of the biggest birds in the world.",
        "Many species of albatross are close to extinction,",
        "therefore we must try harder.",
    },
    ['ladder bug']={
        "Welcome to... ladders",
        "**applause**",
    },
    ['hidden pipe']=nil,
    ['subcon vase']={
        'Breaking this vase forces you into a dream-like state,',
        'filled with your subconscious.',
    },
    ['magic flute']={
        'Playing one of these may cause you to be transported',
        'to far off worlds that will frustrate you even more',
    },
    ['star zone']={
        'In my opinion, there is only one star worth studying.',
        'It is a black hole called Sagittarius A,',
        'located in the center of our galaxy.',
        'It has the density of 40 suns. Just like my wiener.',
    },
    ['rashes']={
        "I'm not getting flustered,",
        "these things on my chest are just rashes.",
        "I'm allergic to beans.",
    },
    ['zits']={
        'Like pimples, but too small to pop.',
        'Caused by poor breeding',
    },
    ['pimples']={
        'Whenever Magnitude gets a pimple,',
        'he knows what to do',
    },
    ['dark queen']=nil,
    ['mechanical']=nil,
    ['stoneship']=nil,
    ['channel wood']=nil,
    ['space ship']={
        "In the future",
        "two cardboard boxes",
        "are about to become",
        "SPACE SHIPS",
    },
    ['old man trainer']=nil,
    ['fly on a bird']=nil,
    ['cinnamon island']=nil,
    ['seal along the shore']=nil,
    ['black lightning']=nil,
    ['hornet']=nil,
    ['shredder']=nil,
    ['avenger']=nil,
    ['wine hat']=nil,
    ['magic feather']=nil,
    ['raccoon clothes']=nil,
    ['running jump']=nil,
    ['collect all blue coins']=nil,
    ['island of annoying voices']=nil,
    ['hot tub end boss']=nil,
    ['mustached mushroom']=nil,
    ['bell toss']=nil,
    ['charged fireball']=nil,
    ['time bombs']=nil,
    ['rock punch']=nil,
    ['blue fire']=nil,
    ['green fire']=nil,
    ['purple fire']=nil,
    ['boring regular old fire']=nil,
    ['flying war ships']=nil,
    ['clown face helicopter']=nil,
    ['teeter totter flying floor']=nil,
    ['unstable bath']=nil,
    ['impervious to lava']=nil,
    ['underwater exploration']=nil,
    ['hover puppy']=nil,
    ['giant ant dance club']=nil,
    ['good karma quests']=nil,
    ['fun quests']=nil,
    ['unkillable bears']=nil,
    ['antiphysics horse']=nil,
    ['bubble attack']=nil,
    ['leaf attack']=nil,
    ['time freeze attack']=nil,
    ['metal blade attack']=nil,
    ['egg treatment']=nil,
    ['blue poultry']=nil,
    ['the chicken lady']=nil,
    ['forest fungus']=nil,
    ['wild children']=nil,
    ['trippy potions']=nil,
    ['pharmacist']=nil,
    ['sawing small trees']=nil,
    ['carpenter camps']=nil,
    ['broken swords']=nil,
    ['giant rock monster']=nil,
    ['frog prescriptions']=nil,
    ['vision medication']=nil,
    ['brick vouchers']=nil,
    ['extra large swords']=nil,
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

function Menu:keypressed(button, player)
    if self.dialog and (self.state == 'closed' or self.state == 'hidden')
        and button.a then
        self.dialog:keypressed({a = true}) -- need to manually trigger a close
    end

    if self.state == 'closed' or self.state == 'hidden' then
        return
    end

    if button.up then
        love.audio.play(menuBlip)
        if self.choice == 4 then
            self.offset = math.min(self.offset + 1, #self.items - 4)
        end
        self.choice = math.min(4, self.choice + 1)
    elseif button.down then
        love.audio.play(menuBlip)
        if self.choice == 1 then
            self.offset = math.max(self.offset - 1, 0)
        end
        self.choice = math.max(1, self.choice - 1)
    elseif button.a then
        love.audio.play('audio/click.ogg')
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


local Hilda = {}
Hilda.__index = Hilda

local hildaImage = love.graphics.newImage('images/hilda.png')
local g = anim8.newGrid(32, 48, hildaImage:getWidth(), hildaImage:getHeight())

function Hilda.new(node, collider)
	local hilda = {}
	setmetatable(hilda, Hilda)
	hilda.image = hildaImage
    hilda.animations = {
        walking = {
            right = anim8.newAnimation('loop', g('1-3,1'), .18),
            left = anim8.newAnimation('loop', g('1-3,2'), .18),
        },
        standing = {
            right = anim8.newAnimation('loop', g('1,1', '10,1'), 2, {[2]=.1}),
            left = anim8.newAnimation('loop', g('1,2', '10,2'), 2, {[2]=.1}),
        },
        talking = {
            right = anim8.newAnimation('loop', g('1,1', '11,1'), .8, {[2]=.3}),
            left = anim8.newAnimation('loop', g('1,2', '11,2'), .8, {[2]=.3}),
        },
    }

	hilda.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	hilda.bb.node = hilda
    hilda.collider = collider
	hilda.collider:setPassive(hilda.bb)
    hilda.state = 'walking'
    hilda.direction = 'right'

    hilda.width = node.width
    hilda.height = node.height
	hilda.position = { x = node.x + 12, y = node.y }
	hilda.maxx = node.x + 48
	hilda.minx = node.x - 48
    hilda.menu = Menu.new(menuDefinition)
	return hilda
end

function Hilda:draw()
    local animation = self.animations[self.state][self.direction]
	animation:draw(self.image, math.floor(self.position.x), self.position.y)
    self.menu:draw(self.position.x, self.position.y - 50)
end

function Hilda:update(dt, player)
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

function Hilda:keypressed(button, player)
    if button.b then
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

    if button.b and self.state == 'walking' and not player.jumping then
        player.freeze = true
        player.state = 'idle'
        self.state = 'standing'

        self.menu:open()
    end

    if player.freeze then
        self.menu:keypressed(button, player)
    end
end

return Hilda
