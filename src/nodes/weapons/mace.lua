-----------------------------------------------
-- mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new mace object
-- @return the mace object created
return {
    hand_x = 9,
    hand_y = 40,
    rowAmt = 1,
    colAmt = 3,
    frameWidth = 50,
    frameHeight = 50,
    sheetWidth = frameWidth*colAmt,
    sheetHeight = frameHeight*rowAmt,
    width = frameWidth,
    height = frameHeight,
    sheet = love.graphics.newImage('images/mace_action.png'),
    wield_rate = 0.09,
    damage = 4,
    hitAudioClip = 'mace_hit',
    animations = {
        default = {'once', h(1,1), 1},
        wield = {'once', h('1,1','2,1','3,1')}
    }
}