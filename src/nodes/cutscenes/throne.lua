local Scene = {}
Scene.__index = Scene

function Scene.new(node, collider, layer)
    local scene = {}
    setmetatable(scene, Scene)
    scene.x = node.x
    scene.y = node.y
    scene.finished = true --change this

    --Make it all fancy here

    return scene
end

function Scene:start(player)
    -- Put a bunch of cool things here
end

function Scene:draw(player)
    -- Pretty things go here
end

function Scene:update(dt, player)
    -- Change the world
end

function Scene:keypressed(button)

end

return Scene
