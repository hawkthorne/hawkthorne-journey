-----------------------------------------------
-- mallet.lua
-- Represents a that a player can wield or pick up
-- Created by NimbusBP1729
-----------------------------------------------

--
-- Creates a new mallet object
-- @return the mallet object created
return{
    hand_x = 5,
    hand_y = 16,
    rowAmt = 1,
    colAmt = 3,
    frameWidth = 20,
    frameHeight = 30,
    width = frameWidth,
    height = frameHeight,
    sheet = love.graphics.newImage('images/mallet_action.png'),
    damage = 4,
    hitAudioClip = 'mallet_hit',
    animations = {,
        default = {'once', {'1,1'}, 1},
        wield = {'once', {'1,1','2,1','3,1','2,1'},0.09},
    },
}