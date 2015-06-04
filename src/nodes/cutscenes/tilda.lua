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
        'A disheveled woman stands in front of you, walking in circles and muttering under her breath.',
        '"The acorn king, the acorn king, the acorn king, the acorn king..."',
        'She looks familiar for some reason.',
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
