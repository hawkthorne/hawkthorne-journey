local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8' local atl = require 'vendor/AdvTiledLoader'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local camera = require 'camera'
local window = require 'window'
local pause = require 'pause'
local music = {}


local game = {}
game.step = 10000
game.friction = 0.146875 * game.step
game.accel = 0.046875 * game.step
game.deccel = 0.5 * game.step
game.gravity = 0.21875 * game.step
game.airaccel = 0.09375 * game.step
game.airdrag = 0.96875 * game.step
game.max_x = 300
game.max_y= 300


atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true


function math.sign(x)
    if x == math.abs(x) then
        return 1
    else
        return -1
    end
end


local Enemy = {}
Enemy.__index = Enemy

function Enemy.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    sheet:setFilter('nearest', 'nearest')
    local enem = {}
    local g = anim8.newGrid(48, 48, sheet:getWidth(), sheet:getHeight())

    setmetatable(enem, Enemy)
    enem.is_player = false
    enem.dead = false
    enem.width = 48
    enem.height = 48
    enem.sheet = sheet
    enem.position = {x=0, y=0}
    enem.velocity = {x=0, y=0}
    enem.state = 'crawl'         -- default animation is idle
    enem.direction = 'left'    -- default animation faces right direction is right
    enem.animations = {
        dying = {
            right = anim8.newAnimation('once', g('5,2'), 1),
            left = anim8.newAnimation('once', g('5,1'), 1)
        },
        crawl = {
            right = anim8.newAnimation('loop', g('3-4,2'), 0.25),
            left = anim8.newAnimation('loop', g('3-4,1'), 0.25)
        },
        attack = {
            right = anim8.newAnimation('loop', g('1-2,2'), 0.25),
            left = anim8.newAnimation('loop', g('1-2,1'), 0.25)
        }
    }
    return enem
end


function Enemy:animation()
    return self.animations[self.state][self.direction]
end

function Enemy:hit()
    self.state = 'attack'
    Timer.add(1, function() self.state = 'crawl' end)
end


function Enemy:die()
    love.audio.play(love.audio.newSource("audio/hippie_kill.ogg", "static"))
    self.state = 'dying'
    self.collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
end

function Enemy:update(dt)
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' or self.state == 'attack' then
        return
    end


    if self.position.x > self.player.position.x then
        self.direction = 'left'
    else
        self.direction = 'right'
    end

    if math.abs(self.position.x - self.player.position.x) < 2 then
        -- stay put
    elseif self.direction == 'left' then
        self.position.x = self.position.x - (10 * dt)
    else
        self.position.x = self.position.x + (10 * dt)
    end

    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + self.height / 2 + 10)
end

function Enemy:draw()
    if self.dead then
        return
    end

    self:animation():draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))
end

local Player = {}
Player.__index = Player

function Player.create(character)
    local plyr = {}

    setmetatable(plyr, Player)
    plyr.is_player = true
    plyr.rebounding = false
    plyr.invulnerable = false
    plyr.jumping = false
    plyr.flash = false
    plyr.width = 48
    plyr.height = 48
    plyr.sheet = character.sheet
    plyr.actions = {}
    plyr.position = {x=0, y=0}
    plyr.velocity = {x=0, y=0}
    plyr.state = 'idle'         -- default animation is idle
    plyr.direction = 'right'    -- default animation faces right direction is right
    plyr.animations = character.animations
    return plyr
end


function Player:animation()
    return self.animations[self.state][self.direction]
end



function Player:accel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.accel
    end
end

function Player:deccel()
    if self.velocity.y < 0 then
        return game.airaccel
    else
        return game.deccel
    end
end


function Player:update(dt)
    if not self.invulnerable then
        self:stopBlink()
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if (love.keyboard.isDown('left') or love.keyboard.isDown('a')) and not self.rebounding then

        if self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (self:deccel() * dt)
        elseif self.velocity.x > -game.max_x then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < -game.max_x then
                self.velocity.x = -game.max_x
            end
        end

    elseif (love.keyboard.isDown('right') or love.keyboard.isDown('d')) and not self.rebounding then

        if self.velocity.x < 0 then
            self.velocity.x = self.velocity.x + (self:deccel() * dt)
        elseif self.velocity.x < game.max_x then
            self.velocity.x = self.velocity.x + (self:accel() * dt)
            if self.velocity.x > game.max_x then
                self.velocity.x = game.max_x
            end
        end

    else
        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + game.friction * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - game.friction * dt, 0)
        end
    end

    self.velocity.y = self.velocity.y + game.gravity * dt
    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
    end
    -- end sonic physics
    
    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = math.min(self.position.y + self.velocity.y * dt, self.floor)

    if self.position.y == self.floor then
        self.jumping = false

        if self.rebounding then
            self.rebounding = false
            self.collider:setSolid(self.bb)
        end
    end

    -- These calculations shouldn't need to be offset, investigate
    -- Min and max for the level
    if self.position.x < -self.width / 4 then
        self.position.x = -self.width / 4
    elseif self.position.x > self.boundary.width - self.width * 3 / 4 then
        self.position.x = self.boundary.width - self.width * 3 / 4
    end

    action = nil
    
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + self.height / 2)


    if self.velocity.x < 0 then
        self.direction = 'left'
    elseif self.velocity.x > 0 then
        self.direction = 'right'
    end

    if self.velocity.y < 0 then

        self.state = 'jump'
        self:animation():update(dt)

    elseif self.state == 'jump' and not self.jumping then

        self.state = 'walk'
        self:animation():update(dt)

    elseif self.state == 'idle' and self.velocity.x ~= 0 then

        self.state = 'walk'
        self:animation():gotoFrame(1)

    elseif self.state == 'walk' and self.velocity.x == 0 then

        self.state = 'idle'
        self:animation():update(dt)
    else

        self:animation():update(dt)

    end
end

function Player:die()
    if self.invulnerble then
        return
    end

    love.audio.play(love.audio.newSource("audio/hit.wav", "static"))
    self.rebounding = true
    self.invulnerable = true
    self.collider:setGhost(self.bb)

    Timer.add(1.5, function() 
        self.invulnerable = false
        self.flash = false
    end)

    self:startBlink()
end


function Player:stopBlink()
    if self.blink then
        Timer.cancel(self.blink)
        self.blink = nil
    end
    self.flash = false
end


function Player:startBlink()
    if not self.blink then
        self.blink = Timer.addPeriodic(.09, function()
            self.flash = not self.flash
        end)
    end
end


function Player:draw()
    if self.flash then
        return
    end

    self:animation():draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))
end


local function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if not shape_a.parent.is_player and not shape_b.parent.is_player then
        return --two enemies have hit each other
    end

    if shape_a.parent.is_player then
        player = shape_a.parent
        enemy = shape_b.parent
    else
        player = shape_b.parent
        enemy = shape_a.parent
    end

    -- http://info.sonicretro.org/SPG:Getting_Hit
    a = 1
    if player.position.x < enemy.position.x then
        a = -1
    end

    local x1,y1,x2,y2 = enemy.bb:bbox()

    if player.position.y + player.height <= y2 and player.velocity.y > 0 then -- successful attack
        enemy:die()
        player.velocity.y = -450
    elseif not player.invulnerable then
        enemy:hit()
        player:die()
        player.velocity.y = -450
        player.velocity.x = 300 * a
    end

end

-- this is called when two shapes stop colliding
local function collision_stop(dt, shape_a, shape_b)
end

local function findFloor(map)
    local tiles = tonumber(map.tileLayers.background.properties.floor)
    return map.tileWidth * tiles - 48
end

local function setBackgroundColor(map)
    local prop = map.tileLayers.background.properties
    if not prop.red then
        return
    end
    love.graphics.setBackgroundColor(tonumber(prop.red),
                                     tonumber(prop.green),
                                     tonumber(prop.blue))
end

local function setCameraOffset(map)
    local prop = map.tileLayers.background.properties
    if not prop.offset then
        return
    end
    camera:setPosition(nil, tonumber(prop.offset) * map.tileWidth)
end


local Level = {}
Level.__index = Level

function Level.new(tmx, character)
	local level = {}
    setmetatable(level, Level)


    level.drawBoundingBoxes = false
    level.character = character

    level.map = atl.Loader.load(tmx)
    level.map.useSpriteBatch = true
    level.map.drawObjects = false
    level.collider = HC(100, on_collision, collision_stop)


    setBackgroundColor(level.map)
    setCameraOffset(level.map)

    local player = Player.create(character)
    player.floor = findFloor(level.map)

    for k,v in pairs(level.map.objectLayers.locations.objects) do
        if v.type == 'entrance' then
            player.position = {x=v.x, y=v.y}
        elseif v.type == 'exit' then
            level.exit = v 
        end
    end

    player.collider = level.collider
    player.boundary = {width=level.map.width * level.map.tileWidth}
    player.bb = level.collider:addRectangle(0,0,18,42)
    player.bb.parent = player

    level.enemies = {}

    if level.map.objectLayers.enemies then
        for k,v in pairs(level.map.objectLayers.enemies.objects) do
            local enemy = Enemy.create("images/" .. v.type .. ".png") -- trust
            enemy.position = {x=v.x, y=v.y}
            enemy.collider = level.collider
            enemy.bb = level.collider:addRectangle(0,0,30,25)
            enemy.bb.parent = enemy
            enemy.player = player
            table.insert(level.enemies, enemy)
        end
    end

    level.player = player

    camera.max.x = level.map.width * level.map.tileWidth - window.width

    return level
end

function Level:enter(previous)
    love.audio.stop()

    local background = love.audio.newSource("audio/level.ogg")
    background:setLooping(true)
    love.audio.play(background)
end

function Level:init()
end

function Level:update(dt)
    self.player:update(dt)

    for i,enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end

    self.collider:update(dt)

    local x = self.player.position.x + self.player.width / 2
    camera:setPosition(math.max(x - window.width / 2, 0), nil)
    Timer.update(dt)
end


function Level:draw()
    self.map:autoDrawRange(camera.x * -1, camera.y, 1, 0)
    self.map:draw()
    self.player:draw()

    for i,enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end


function Level:keyreleased(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' and not self.player.rebounding and self.player.state == 'jump' then
        if self.player.velocity.y < 0 and self.player.velocity.y < -450 then
            self.player.velocity.y = -450
        end
    end
end

function Level:leave()
end

function Level:keypressed(key)
    if key == 'w' or key == 'up' then
        local x = self.player.position.x + self.player.width / 2
        if x > self.exit.x and x < self.exit.x + self.exit.width then
            local level = Level.new(self.exit.properties.tmx, self.character)
            Gamestate.switch(level)
            return
        end
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' and not self.player.rebounding then
        if self.player.state ~= 'jump' then
            self.player.jumping = true
            self.player.velocity.y = -650
            love.audio.play(love.audio.newSource("audio/jump.ogg", "static"))
        end
    end

    if key == 'escape' then
        Gamestate.switch(pause)
        return
    end
end

return Level
