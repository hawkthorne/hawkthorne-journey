local Gamestate = require 'vendor/gamestate'
local Queue = require 'queue'
local anim8 = require 'vendor/anim8' local atl = require 'vendor/AdvTiledLoader'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local camera = require 'camera'
local window = require 'window'
local pause = require 'pause'
local music = {}

-- NPCs
local Cow = require 'characters/cow'

-- assest cache
local tiles = {}
local images = {}
local animations = {}

local game = {}
game.step = 10000
game.friction = 0.146875 * game.step
game.accel = 0.046875 * game.step
game.deccel = 0.5 * game.step
game.gravity = 0.21875 * game.step
game.airaccel = 0.09375 * game.step
game.airdrag = 0.96875 * game.step
game.max_x = 300
game.max_y= 600

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
    local sheet = images[sheet_path]
    sheet:setFilter('nearest', 'nearest')
    local enem = {}
    local g = anim8.newGrid(48, 48, sheet:getWidth(), sheet:getHeight())

    setmetatable(enem, Enemy)
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
    plyr.jumpQueue = Queue.new()
    plyr.halfjumpQueue = Queue.new()
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

function Player:moveBoundingBox()
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + (self.height / 2) + 2)
end

function Player:update(dt)
    if not self.invulnerable then
        self:stopBlink()
    end



    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    local goingLeft = (love.keyboard.isDown('left') or love.keyboard.isDown('a'))
    local goingRight = (love.keyboard.isDown('right') or love.keyboard.isDown('d'))
    if goingLeft and not goingRight and not self.rebounding then

        if self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (self:deccel() * dt)
        elseif self.velocity.x > -game.max_x then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < -game.max_x then
                self.velocity.x = -game.max_x
            end
        end

    elseif goingRight and not goingLeft and not self.rebounding then

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

    local jumped = self.jumpQueue:flush()
    local halfjumped = self.halfjumpQueue:flush()

    if jumped and not self.jumping and self.velocity.y == 0 and not self.rebounding then
        self.jumping = true
        self.velocity.y = -670
        love.audio.play(love.audio.newSource("audio/jump.ogg", "static"))
    end

    if halfjumped and self.velocity.y < -450 and not self.rebounding and self.jumping then
        self.velocity.y = -450
    end

    self.velocity.y = self.velocity.y + game.gravity * dt

    if self.velocity.y > game.max_y then
        self.velocity.y = game.max_y
    end
    -- end sonic physics
    
    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt

    -- These calculations shouldn't need to be offset, investigate
    -- Min and max for the level
    if self.position.x < -self.width / 4 then
        self.position.x = -self.width / 4
    elseif self.position.x > self.boundary.width - self.width * 3 / 4 then
        self.position.x = self.boundary.width - self.width * 3 / 4
    end

    action = nil
    
    self:moveBoundingBox()

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
        self.blink = Timer.addPeriodic(.12, function()
            self.flash = not self.flash
        end)
    end
end


function Player:draw()
    if self.flash then
        love.graphics.setColor(255, 0, 0)
    end

    self:animation():draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))

    self.bb:draw()

    love.graphics.setColor(255, 255, 255)
end


local function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if not shape_a.player and not shape_b.player then
        return --two enemies have hit each other
    end

    local player, shape

    if shape_a.player then
        player = shape_a.player
        shape = shape_b
    else
        player = shape_b.player
        shape = shape_a
    end

    if shape.floor then
        local _, wy1, _, wy2  = shape:bbox()
        local _, py1, _, py2 = player.bb:bbox()
        local distance = math.abs(player.velocity.y * dt) + 0.10

        if player.velocity.y >= 0 and math.abs(wy1 - py2) <= distance then
            player.velocity.y = 0
            player.position.y = wy1 - player.height -- fudge factor
            player:moveBoundingBox()

            player.jumping = false
            player.rebounding = false
        end

        return
    end

    if shape.wall and mtv_x ~= 0 then
        player.velocity.x = 0
        player.position.x = player.position.x + mtv_x
        return
    end

    if shape.enemy and not player.rebounding then
        -- http://info.sonicretro.org/SPG:Getting_Hit
        local a = player.position.x < shape.enemy.position.x and -1 or 1
        local x1,y1,x2,y2 = shape:bbox()

        if player.position.y + player.height <= y2 and player.velocity.y > 0 then -- successful attack
            shape.enemy:die()
            player.velocity.y = -450
        elseif not player.invulnerable then
            shape.enemy:hit()
            player:die()
            player.bb:move(mtv_x, mtv_y)
            player.velocity.y = -450
            player.velocity.x = 300 * a
        end

        return
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

local function getCameraOffset(map)
    local prop = map.tileLayers.background.properties
    if not prop.offset then
        return 0
    end
    return tonumber(prop.offset) * map.tileWidth
end


local Level = {}
Level.__index = Level

function Level.load_image(path)
    images[path] = love.graphics.newImage(path)
end

function Level.load_tileset(tmx)
    tiles[tmx] = atl.Loader.load(tmx)
end


function Level.new(tmx, character)
	local level = {}
    setmetatable(level, Level)

    level.drawBoundingBoxes = false
    level.music = false
    level.character = character

    level.map = tiles[tmx]
    level.map.useSpriteBatch = true
    level.map.drawObjects = false
    level.collider = HC(100, on_collision, collision_stop)
    level.offset = getCameraOffset(level.map)

    setBackgroundColor(level.map)

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
    player.bb = level.collider:addRectangle(0,0,18,44)
    player:moveBoundingBox()
    player.bb.player = player

    level.enemies = {}

    if level.map.objectLayers.solid then
        for k,v in pairs(level.map.objectLayers.solid.objects) do
            local ledge = level.collider:addRectangle(v.x,v.y,v.width,v.height)
            if v.type == 'wall' then
                ledge.wall = true
            else
                ledge.floor = true
            end
        end
    end

    level.npcs = {}

    if level.map.objectLayers.npc then
        for k,v in pairs(level.map.objectLayers.npc.objects) do
            if v.type == 'cow' then
                local cow = Cow.create(v.x, v.y, images['images/cow.png'])
                table.insert(level.npcs, cow)
            end
        end
    end

    if level.map.objectLayers.enemies then
        for k,v in pairs(level.map.objectLayers.enemies.objects) do
            local enemy = Enemy.create("images/" .. v.type .. ".png") -- trust
            enemy.position = {x=v.x, y=v.y}
            enemy.collider = level.collider
            enemy.player = player
            enemy.bb = level.collider:addRectangle(0,0,30,25)
            enemy.bb.enemy = enemy
            table.insert(level.enemies, enemy)
        end
    end

    level.player = player

    camera.max.x = level.map.width * level.map.tileWidth - window.width

    return level
end

function Level:enter(previous)
end

function Level:init()
end

function Level:update(dt)
    self.player:update(dt)

    if self.player.position.y - self.player.height > self.map.height * self.map.tileHeight then
        local level = Level.new('studyroom.tmx', self.character)
        Gamestate.switch(level)
        return
    end
    
    if love.keyboard.isDown('up') or love.keyboard.isDown('w') or self.exit.properties.instant then
        local x = self.player.position.x + self.player.width / 2
        if x > self.exit.x and x < self.exit.x + self.exit.width then
            local level = Level.new(self.exit.properties.tmx, self.character)
            Gamestate.switch(level)
            return
        end
    end

    for i,enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end

    self.collider:update(dt)

    local x = self.player.position.x + self.player.width / 2
    local y = self.player.position.y - self.map.tileWidth * 2.5
    camera:setPosition(math.max(x - window.width / 2, 0),
                       math.min(math.max(y, 0), self.offset))
    Timer.update(dt)
end

function Level:draw()
    self.map:autoDrawRange(camera.x * -1, camera.y, 1, 0)
    self.map:draw()

    for i,npc in ipairs(self.npcs) do
        npc:draw()
    end

    for i,enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    self.player:draw()
end


function Level:keyreleased(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' then
        self.player.halfjumpQueue:push('jump')
    end
end

function Level:leave()
end

function Level:keypressed(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' then
        self.player.jumpQueue:push('jump')
    end

    if key == 'escape' then
        Gamestate.switch(pause)
        return
    end
end

return Level
