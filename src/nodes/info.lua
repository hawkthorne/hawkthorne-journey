local Dialog = require 'dialog'

local Info = {}
Info.__index = Info
 
function Info.new(node, collider)
    local info = {}
    setmetatable(info, Info)
    info.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    info.bb.node = info
    info.info = split( node.properties.info, '|' )

    info.x = node.x
    info.y = node.y
    info.foreground = 'true'

    collider:setPassive(info.bb)
    
    info.dialog = nil
    info.current = nil

    return info
end

function Info:update(dt, player)
    if self.dialog then self.dialog:update(dt) end
end

function Info:draw()
    if self.dialog then
        self.dialog:draw( self.x, self.y - 30 )
    end
end

function Info:keypressed(key, player)
    if self.dialog then
        self.dialog:keypressed('return')
    end
    
    if (key == 'rshift' or key == 'lshift') and self.dialog == nil then
        player.freeze = true
        self.dialog = Dialog.new(115, 50, self.info, function()
            player.freeze = false
            self.dialog = nil
        end)
    end
end

function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

return Info