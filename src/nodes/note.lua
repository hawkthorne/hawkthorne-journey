local Dialog = require 'dialog'
local utils = require 'utils'

local Note = {}
Note.__index = Note
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Note.isInteractive = true

local noteImage = love.graphics.newImage('images/Note_image.png') 

function Note.new(node, collider)
    local note = {}
    setmetatable(note, Note)
    note.image = noteImage
    note.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    note.bb.node = note
    note.note = utils.split(node.properties.note, '|')

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

function Note:keypressed( button, player )
    
    if button == 'INTERACT' and self.dialog == nil and not player.freeze then
        player.freeze = true
        Dialog.new(self.note, function()
            player.freeze = false
            Dialog.currentDialog = nil
        end)
        -- Key has been handled, halt further processing
        return true
    end
end

return Note
