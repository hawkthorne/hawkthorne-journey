local Floorspaces = {}
Floorspaces.__index = Floorspaces
Floorspaces.primary = false
Floorspaces.active = false
Floorspaces.objects = {}

function Floorspaces:setPrimary( fs )
    assert( not self.primary, "You can only have one primary floorspace!" )
    fs.isPrimary = true
    self.primary = fs
    fs.isActive = true
    self.active = fs
end

function Floorspaces:getPrimary()
    return self.primary or false
end

function Floorspaces:setActive( fs )
    self.active.isActive = false
    fs.isActive = true
    self.active = fs
end

function Floorspaces:getActive()
    return self.active or false
end

function Floorspaces:addObject( fs )
    if not table.contains( self.objects, fs ) then
        table.insert( self.objects, fs )
    end
end

return Floorspaces