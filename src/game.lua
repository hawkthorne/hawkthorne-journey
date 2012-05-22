local anim8 = require 'vendor/anim8'
local atl = require 'vendor/AdvTiledLoader'
local HC = require 'vendor/hardoncollider'
local camera = require 'camera'
local game = {}

game.friction = 0.046875
game.accel = 0.046875
game.deccel = 0.5
game.gravity = 20
game.step = 300
game.maxspeed = 6

atl.Loader.path = 'maps/'
atl.Loader.useSpriteBatch = true

Player = {}
Player.__index = Player

function Player.create(sheet_path)
    local sheet = love.graphics.newImage(sheet_path)
    local plyr = {}
    local g = anim8.newGrid(46, 46, sheet:getWidth(), sheet:getHeight())

    setmetatable(plyr, Player)
    plyr.width = 48
    plyr.height = 48
    plyr.sheet = sheet
    plyr.start = {x=love.graphics.getWidth() / 2 - 23, y=300}
    plyr.actions = {}
    plyr.pos = {x=0, y=0}
    plyr.position = {x=love.graphics.getWidth() / 2 - 23, y=300}
    plyr.velocity = {x=0, y=0}
    plyr.state = 'idle'         -- default animation is idle
    plyr.direction = 'right'    -- default animation faces right direction is right
    plyr.animations = {
        jump = {
            right = anim8.newAnimation('once', g('7,2'), 1),
            left = anim8.newAnimation('once', g('7,1'), 1)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return plyr
end


function Player:animation()
    return self.animations[self.state][self.direction]
end

function game.round(value)
    if value <= 0 then
        return math.floor(value)
    else
        return math.ceil(value)
    end
end

function math.sign(x)
    if x == math.abs(x) then
        return 1
    else
        return -1
    end
end

function Player:update(dt)
    local step = dt * game.step

    -- taken from sonic physics http://info.sonicretro.org/SPG:Running
    if love.keyboard.isDown('left') then

        if self.velocity.x > 0 then
            self.velocity.x = self.velocity.x - (game.deccel * step)
        elseif self.velocity.x > -game.maxspeed then
            self.velocity.x = self.velocity.x - (game.accel * step)
            if self.velocity.x < -game.maxspeed then
                self.velocity.x = -game.maxspeed
            end
        end

    elseif love.keyboard.isDown('right') then

        if self.velocity.x < 0 then
            self.velocity.x = self.velocity.x + (game.deccel * step)
        elseif self.velocity.x < game.maxspeed then
            self.velocity.x = self.velocity.x + (game.accel * step)
            if self.velocity.x > game.maxspeed then
                self.velocity.x = game.maxspeed
            end
        end

    else

        local min = math.min(math.abs(self.velocity.x), game.friction * step)
        self.velocity.x = self.velocity.x - min * math.sign(self.velocity.x)

    end

    self.position.x = game.round(self.position.x + self.velocity.x)
    -- self.position.y = math.min(game.round(self.position.y + self.velocity.y), 300)
    --
    --print(self.velocity.x)

    action = nil
    
    self.bb:moveTo(self.position.x + self.width / 2,
                   self.position.y + self.height / 2)

    if # self.actions > 0 then
        action = table.remove(self.actions)
    end

    if self.velocity.x < 0 then
        self.direction = 'left'
    elseif self.velocity.x > 0 then
        self.direction = 'right'
    end

    if action == 'jump' and self.state ~= 'jump' then

        self.state = 'jump'

    elseif self.state == 'jump' and self.position.y == 300 then

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

function Player:draw()
    self:animation():draw(self.sheet, self.position.x, self.position.y) 
end

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    print(string.format("Colliding. mtv = (%s,%s)", mtv_x, mtv_y))
    --shape_a.parent.frozen = true
    --shape_a.parent.pos.x = shape_a.parent.pos.x + math.floor(mtv_x - 1)
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
    print("Stopped colliding")
end


function game.load()
    love.audio.stop()
    bg = love.graphics.newImage("images/studyroom_scaled.png")

    player = Player.create("images/abed_sheet.png")

    map = atl.Loader.load("hallway.tmx")

    music = love.audio.newSource("audio/level.ogg")
    music:setLooping(true)
    love.audio.play(music)

    Collider = HC(100, on_collision, collision_stop)

    -- add a rectangle to the scene
    player.bb = Collider:addRectangle(0,0,17,42)
    player.bb.parent = player

    rect = Collider:addRectangle(400,248,100,100)

    -- add a circle to the scene
    --mouse = Collider:addCircle(400,300,20)
    --mouse:moveTo(love.mouse.getPosition())
end

function game.update(dt)
    dx = 0


    player:update(dt)
    camera:setPosition(player.pos.x, 0)

    Collider:update(dt)
end


function game.draw()
    camera:set()

    map:autoDrawRange(math.floor(camera.x * -1), math.floor(camera.y), 1, 0)
    map:draw()
    player:draw()

    love.graphics.setColor(255,255,255)
    rect:draw()

    -- mouse:draw('fill')

    camera:unset()
end


function game.keyreleased(key)
end

function game.keypressed(key)
    if key == ' ' then
        table.insert(player.actions, 'jump')
    end
end



return game
