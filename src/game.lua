local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local atl = require 'vendor/AdvTiledLoader'
local HC = require 'vendor/hardoncollider'
local Timer = require 'vendor/timer'
local camera = require 'camera'
local music = {}
local game = Gamestate.new()

-- taken from sonic physics http://info.sonicretro.org/SPG:Running
game.step = 10000
game.friction = 0.146875 * game.step
game.accel = 0.046875 * game.step
game.deccel = 0.5 * game.step
game.gravity = 0.21875 * game.step
game.airaccel = 0.09375 * game.step
game.airdrag = 0.96875 * game.step
game.max_x = 300
game.max_y= 300
game.drawBoundingBoxes = false

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true

local Enemy = {}
Enemy.__index = Enemy

function Enemy.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local enem = {}
    local g = anim8.newGrid(46, 46, sheet:getWidth(), sheet:getHeight())

    setmetatable(enem, Enemy)
    enem.dead = false
    enem.width = 48
    enem.height = 48
    enem.sheet = sheet
    enem.position = {x=love.graphics.getWidth() - 23, y=300}
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
    Collider:setGhost(self.bb)
    Timer.add(.75, function() self.dead = true end)
end

function Enemy:update(dt)
    if self.dead then
        return
    end

    self:animation():update(dt)

    if self.state == 'dying' then
        return
    end


    if self.position.x > player.position.x then
        self.direction = 'left'
    else
        self.direction = 'right'
    end

    if self.direction == 'left' then
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
    if game.drawBoundingBoxes then
        self.bb:draw()
    end
end

local Player = {}
Player.__index = Player

function Player.create(character)
    local plyr = {}

    setmetatable(plyr, Player)
    plyr.rebounding = false
    plyr.invulnerable = false
    plyr.jumping = false
    plyr.flash = false
    plyr.width = 48
    plyr.height = 48
    plyr.sheet = character.sheet
    plyr.actions = {}
    plyr.position = {x=love.graphics.getWidth() / 2 - 23, y=300}
    plyr.velocity = {x=0, y=0}
    plyr.state = 'idle'         -- default animation is idle
    plyr.direction = 'right'    -- default animation faces right direction is right
    plyr.animations = character.animations
    return plyr
end


function Player:animation()
    return self.animations[self.state][self.direction]
end

function math.sign(x)
    if x == math.abs(x) then
        return 1
    else
        return -1
    end
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
    if self.invulnerable then
        self.flash = not self.flash
    end

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if love.keyboard.isDown('left') and not player.rebounding then

        if self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (self:deccel() * dt)
        elseif self.velocity.x > -game.max_x then
            self.velocity.x = self.velocity.x - (self:accel() * dt)
            if self.velocity.x < -game.max_x then
                self.velocity.x = -game.max_x
            end
        end

    elseif love.keyboard.isDown('right') and not player.rebounding then

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
    self.position.y = math.min(self.position.y + self.velocity.y * dt, 300)

    if self.position.y == 300 then
        self.jumping = false
        self.rebounding = false
    end

    -- These calculations shouldn't need to be offset, investigate
    -- Min and max for the level
    if self.position.x < -player.width / 4 then
        self.position.x = -player.width / 4
    elseif self.position.x > map.width * map.tileWidth - player.width * 3 / 4 then
        self.position.x = map.width * map.tileWidth - player.width * 3 / 4
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

    elseif self.state == 'jump' and not self.jumping then

        self.state = 'walk'

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
    love.audio.play(love.audio.newSource("audio/hit.wav", "static"))
    Collider:setGhost(player.bb)
    self.rebounding = true
    self.invulnerable = true

    Timer.add(2, function() 
        Collider:setSolid(self.bb)
        self.invulnerable = false
        self.flash = false
    end)

end

function Player:draw()
    if self.flash then
        return
    end

    self:animation():draw(self.sheet, math.floor(self.position.x),
                                      math.floor(self.position.y))

    if game.drawBoundingBoxes then
        self.bb:draw()
    end
end

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if shape_a.parent == player then
        enemy = shape_b.parent
    else
        enemy = shape_a.parent
    end


    -- http://info.sonicretro.org/SPG:Getting_Hit
    a = 1
    if player.position.x < enemy.position.x then
        a = -1
    end

    local x1,y1,x2,y2 = enemy.bb:bbox()
    if player.position.y + player.height <= y2 then
        enemy:die()
    else
        enemy:hit()
        player:die()
    end

    player.velocity.y = -450
    player.velocity.x = 300 * a
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
end

function game:enter(previous, character)
    love.audio.stop()
    player = Player.create(character)
    enemy = Enemy.create("images/hippy.png")

    map = atl.Loader.load("hallway.tmx")

    music.background = love.audio.newSource("audio/level.ogg")
    music.background:setLooping(true)
    love.audio.play(music.background)


    Collider = HC(100, on_collision, collision_stop)

    for _, o in pairs(map.objectLayers.solid.objects) do
        rect = Collider:addRectangle(o.x, o.y, o.width * map.tileWidth, 
                                     o.height * map.tileHeight)
    end

    camera.max.x = map.width * map.tileWidth - love.graphics:getWidth()

    -- playe bounding box
    player.bb = Collider:addRectangle(0,0,18,42)
    player.bb.parent = player

    enemy.bb = Collider:addRectangle(0,0,30,25)
    enemy.bb.parent = enemy

end


function game:init()
end

function game:update(dt)
    player:update(dt)
    enemy:update(dt)
    Collider:update(dt)

    local x = math.max(player.position.x - love.graphics:getWidth() / 2, 0)
    camera:setPosition(x, 0)

    Timer.update(dt)
end


function game:draw()
    camera:set()

    map:autoDrawRange(camera.x * -1, camera.y, 1, 0)
    map:draw()
    player:draw()

    enemy:draw()

    camera:unset()
end


function game:keyreleased(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' and not player.rebounding and player.state == 'jump' then
        if player.velocity.y < 0 and player.velocity.y < -450 then
            player.velocity.y = -450
        end
    end
end

function game:keypressed(key)
    -- taken from sonic physics http://info.sonicretro.org/SPG:Jumping
    if key == ' ' and not player.rebounding then
        if player.state ~= 'jump' then
            player.jumping = true
            player.velocity.y = -650
            love.audio.play(love.audio.newSource("audio/jump.ogg", "static"))
        end
    end
end


return game
