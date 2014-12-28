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
    'Congratulations! You have reached the throne of Hawkthorne.',
    '...',
    'What, you expected some kind of epic boss fight? Sorry. The game is not finished yet.',
    'Additional cutscenes and boss fights are coming. However, if you want more to explore, you now have access to the Greendale campus!',
    'To get there, exit the study room then use the door to the left. Remember to bring the key!',
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
