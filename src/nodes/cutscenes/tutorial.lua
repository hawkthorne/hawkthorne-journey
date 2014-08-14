local Timer = require 'vendor/timer'
local tween = require 'vendor/tween'
local fonts = require 'fonts'

local Scene = {}
Scene.__index = Scene

function Scene.new(node, collider, layer)
    local scene = {}
    setmetatable(scene, Scene)
    scene.x = node.x
    scene.y = node.y
    scene.finished = false --change this
    A = 255
    How_long_it_will_take_in_seconds = 1
    --Make it all fancy here
    love.graphics.setColor(90, 145, 111, 0)

    --scene.text = love.graphics.printf('DOWN, DOWN',(player.position.x-15),(player.position.y-40),love.graphics.getWidth())
    scene.text = node.properties.text--love.graphics.printf('DOWN, DOWN',(love.graphics.getWidth()/2),(love.graphics.getHeight()/2),love.graphics.getWidth())

    return scene
end

function Scene:start(player)
    
    Timer.add(1, function()
        self.finished = true
    end)
end

function Scene:draw(player)
    -- Pretty things go here
    fonts.set( 'big' )
    love.graphics.setColor(90, 145, 111, A)
    love.graphics.printf(self.text,(player.position.x-15),(player.position.y-40),love.graphics.getWidth())
end

function Scene:update(dt, player)
    -- Change the world
    A = A-(255/How_long_it_will_take_in_seconds*dt)
end

function Scene:keypressed(button)
    if self.dialog then
        self.dialog:keypressed(button)
    end
    return true
end

return Scene
