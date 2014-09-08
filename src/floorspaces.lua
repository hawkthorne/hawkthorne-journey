local utils = require 'utils'

local Floorspaces = {}
Floorspaces.__index = Floorspaces

function Floorspaces:init()
  self.primary = false
  self.active = false
  self.objects = {}
end

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
  if self.active then self.active.isActive = false end
  fs.isActive = true
  self.active = fs
end

function Floorspaces:getActive()
  return self.active or false
end

function Floorspaces:addObject( fs )
  if not utils.contains( self.objects, fs ) then
    table.insert( self.objects, fs )
  end
end

return Floorspaces
