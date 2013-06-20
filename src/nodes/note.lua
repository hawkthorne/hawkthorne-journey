local Prompt = require 'prompt'

local Note = {}
Note.__index = Note

local noteImage = love.graphics.newImage('images/Note_image.png') 

function Note.new(node, collider)
    local note = {}
    setmetatable(note, Note)
    note.image = noteImage
    note.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    note.collider = collider
    note.bb.node = note
    note.note = split( node.properties.note, '|' )
    table.insert(note.note, "Did you get all that?")

    note.x = node.x
    note.y = node.y
    note.height = node.height
    note.width = node.width
    note.position = { x = node.x, y = node.y }


    collider:setPassive(note.bb)
    
    note.current = nil

    return note
end

function Note:update(dt, player)
end

function Note:die()
    self.collider:remove(self.bb)
    self.bb = nil
    if self.containerLevel then
      self.containerLevel:removeNode(self)
    end
end

function Note:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
    --FIXME: put these coordinates in main
    --self.dialog:draw( self.x, self.y - 30 )
end

function Note:keypressed( button, player )
    
    if button == 'INTERACT' and self.dialog == nil and not player.freeze then
        player.freeze = true
        Prompt.new(self.note, function(result)
            player.freeze = false
            Prompt.currentDialog = nil
            if result == "Yes" then
                self:die()
            end
        end)
        return true
    end
end

return Note
