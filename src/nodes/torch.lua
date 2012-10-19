-----------------------------------------------
-- battle_torch.lua
-- Represents a torch that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'

local Torch = {}
Torch.__index = Torch
Torch.torch = true

--
-- Creates a new battle torch object
-- @return the battle torch object created
function Torch.new(node, collider, plyr, torchItem)
    local torch = {}
    setmetatable(torch, Torch)
    torch = Global.inherits(torch,Weapon)

    torch.item = torchItem
    torch.foreground = node.properties.foreground
    torch.position = {x = node.x, y = node.y}
    torch.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    torch.width = node.width
    torch.height = node.height

    --can be local
    torch.bb_radius = 30;
    torch.bb_cx_offset= 0;
    torch.bb_cy_offset = 24;

    torch.bb = collider:addCircle(torch.position.x + torch.bb_cx_offset, torch.position.y + torch.bb_cy_offset, torch.bb_radius)
    torch.bb.node = torch
    torch.collider = collider
    torch.collider:setPassive(torch.bb)

    torch.damage = 4
    torch.dead = false
    torch.player = plyr

    torch.wield_rate = 0.09
    torch.burn_rate = 0.09

    local rowAmt = 1
    local colAmt = 8
    torch.frameWidth = 24
    torch.frameHeight = 48
    torch.sheetWidth = torch.frameWidth*colAmt
    torch.sheetHeight = torch.frameHeight*rowAmt
    torch:defaultAnimation()
    torch.sheet = love.graphics.newImage('images/torch_action.png')
    torch.wielding = false
    torch.isWeapon = true
    torch.action = 'wieldaction'
    torch.hand_x = 1
    torch.hand_y = 41


    return torch
end


--the self.animation used in this function must
-- cycle only once. This ensures that the function knows when it has
-- stopped wielding correctly
function Torch:wield()
    self.dead = false
    self.collider:setActive(self.bb)

    self.player:setSpriteStates('wielding')

    if not self.wielding then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(),
        self.player.sheet:getHeight())

        --test directions
        self.animation = anim8.newAnimation('once', h('7,1','8,1','7,1','8,1'), self.wield_rate)
        if self.player.direction == 'right' then
            self.player.animations[self.action]['right'] = anim8.newAnimation('loop', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else
            self.player.animations[self.action]['left'] = anim8.newAnimation('loop', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end
    end
    self.player.wielding = true
    self.wielding = true
    sound.playSfx( "fire_thrown" )
end

function Torch:defaultAnimation()
     local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
     self.animation = anim8.newAnimation('loop', h('1-6,1'), self.burn_rate)
end
return Torch