local dialog = require 'dialog'

local Scene = {}
Scene.__index = Scene

function Scene.new(node, collider, layer)
    local scene = {}
    setmetatable(scene, Scene)
    scene.x = node.x
    scene.y = node.y
    scene.finished = false --change this

    --Make it all fancy here

    return scene
end

function Scene:start(player)
    script = {
        '...huh? Who are you? I thought this mine was abandoned??',
        'I see you too are searching for the map to the hideout of the Acorn King.',
        'Who am I?? You ignorant fool! I am a level 8 Laser Lotus, the great wielder of energons--',
        'I am aiding the Acorn King in the destruction of the--darn it, I have said too much!',
        'I do apologize that I have to do this, but now that you have seen me here, I have no choice but to eliminate you. Prepare yourself!',
    }
    self.dialog = dialog.create(script)
    self.dialog:open(function() self.finished = true end)
end

function Scene:draw(player)
    -- Pretty things go here
end

function Scene:update(dt, player)
    -- Change the world
end

function Scene:keypressed(button)
    if self.dialog then
        self.dialog:keypressed(button)
    end
    return true
end

return Scene
