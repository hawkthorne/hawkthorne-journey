local Global = {}
Global.__index = Global


--child inherits the members of parent if child doesn't
-- have a member by the same name
function Global.inherits(child,parent)
    for k,v in pairs(parent) do
        if not child[k] then
            child[k] = v
        end
    end
    return child
end

return Global