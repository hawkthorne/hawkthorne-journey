--stub
local Potion = {}
Potion.__index = Potion
Potion.isPotion = true

function Potion.new(node, collider)
    local potion = {}
    setmetable(potion,Potion)
    potion.props = node
    
    return potion
end

return Potion