local Dialog = require 'dialog'

local Note = {}
Note.__index = Note

local noteImage = love.graphics.newImage('images/Note_image.png') 

function Note.new(node, collider)
    local note = {}
    setmetatable(note, Note)
    note.image = noteImage
    note.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    note.bb.node = note
    note.note = split( node.properties.note, '|' )

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

function Note:draw()
    love.graphics.draw(self.image, self.position.x, self.position.y)
    --FIXME: put these coordinates in main
    --self.dialog:draw( self.x, self.y - 30 )
end

function Note:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        node.interactive_collide = true
    end
end

function Note:collide_end(node, dt)
    if node.isPlayer then
        node.interactive_collide = false
    end
end

function Note:keypressed( button, player )
    
    if button == 'INTERACT' and self.dialog == nil and not player.freeze then
        player.freeze = true
        Dialog.new(self.note, function()
            player.freeze = false
            Dialog.currentDialog = nil
        end)
        return true
    end
end

return Note
