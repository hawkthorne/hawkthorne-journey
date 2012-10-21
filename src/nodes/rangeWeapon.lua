local game = require 'game'

local RangeWeapon = {}
RangeWeapon.__index = RangeWeapon
RangeWeapon.rangedWeapon = true
RangeWeapon.singleton = nil

RangeWeapon.lift = game.gravity/2
RangeWeapon.supply = 3

--launch a projectile
function RangeWeapon:wield()
    local projectile = self.createNewProjectile()
    table.insert(GS.currentState().nodes, projectile)
    
    if self.swingAudioClip then
        sound.playSfx( self.swingAudioClip )
    end
end

--override generic collide to do nothing
function RangeWeapon:collide
end

--must have a method to create projectile

return RangeWeapon