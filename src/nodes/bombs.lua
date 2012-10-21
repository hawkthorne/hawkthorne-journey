-----------------------------------------------
-- bombs.lua
-- Represents a set of bombs that a player can throw
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local RangeWeapon = require 'nodes/rangeWeapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'

local Bomb = {}
Bomb.__index = Bomb
Bomb.bomb = true

function Bomb.new(node, collider, plyr, malletItem)



return Bomb