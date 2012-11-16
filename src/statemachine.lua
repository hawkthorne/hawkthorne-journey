local SM = {}
SM.__index = SM

function SM.new()
    local Player = require 'player'
    local sm = {}
    setmetatable(sm, SM)
    sm = {
    holding = {
        lookup   = {pose = 'gaze',     action = nil},
        lookdown = {pose =  nil,       action = nil},
        walkLeft = {pose = 'holdwalk', action = Player.walking},
        walkRight= {pose = 'holdwalk', action = Player.walking},
        walkUp   = {pose = 'gazewalk', action = Player.walking},
        walkDown = {pose = 'gazewalk', action = Player.walking},
        crouch   = {pose = 'crouch',   action = Player.beginCrouching},
        drop     = {pose = 'crouch',   action = Player.drop},
        jumping  = {pose = 'hold',     action = Player.normalJumping},
        land     = {pose = 'hold',     action = Player.landing},
        idle     = {pose = 'hold',     action = nil},
    },
    default = {
        lookup   = {pose = 'gaze',      action = nil},
        lookdown = {pose =  nil,        action = nil},
        walkLeft = {pose = 'walk',      action = Player.walking},
        walkRight= {pose = 'walk',      action = Player.walking},
        walkUp   = {pose = 'gazewalk',  action = Player.walking},
        walkDown = {pose = 'crouchwalk',action = Player.walking},
        crouch   = {pose = 'crouch',    action = Player.beginCrouching},
        pickup   = {pose = 'current',   action = Player.pickUp},
        jumping  = {pose = 'jump',      action = Player.normalJumping},
        land     = {pose = 'idle',      action = Player.landing},
        idle     = {pose = 'idle',      action = Player.idling},
    },
    
    }
    
    
    --up,down,left,right,attack,jump,land,pickup,idle,crouch
sm.default.lookup.DOWN   = sm.default.idle
sm.default.lookup.LEFT   = sm.default.walkLeft
sm.default.lookup.RIGHT  = sm.default.walkRight
sm.default.lookup.normal_jump      = sm.default.jumping
sm.default.lookup.idle   = sm.default.idle

sm.default.lookdown.UP     = sm.default.idle
sm.default.lookdown.LEFT   = sm.default.walkLeft
sm.default.lookdown.RIGHT  = sm.default.walkRight
sm.default.lookdown.normal_jump      = sm.default.jumping
sm.default.lookdown.idle   = sm.default.idle

sm.default.walkLeft.goUp     = sm.default.walkUp
sm.default.walkLeft.goDown   = sm.default.walkDown
sm.default.walkLeft.goLeft   = sm.default.walkLeft
sm.default.walkLeft.goRight  = sm.default.walkRight
sm.default.walkLeft.normal_jump      = sm.default.jumping
sm.default.walkLeft.idle   = sm.default.idle

sm.default.walkRight.goUp     = sm.default.walkUp
sm.default.walkRight.goDown   = sm.default.walkDown
sm.default.walkRight.goLeft   = sm.default.walkLeft
sm.default.walkRight.goRight  = sm.default.walkRight
sm.default.walkRight.normal_jump      = sm.default.jumping
sm.default.walkRight.idle   = sm.default.idle

sm.default.walkUp.goUp     = sm.default.walkUp
sm.default.walkUp.goDown   = sm.default.walkDown
sm.default.walkUp.goLeft   = sm.default.walkLeft
sm.default.walkUp.goRight  = sm.default.walkRight
sm.default.walkUp.normal_jump      = sm.default.jumping
sm.default.walkUp.idle   = sm.default.idle

sm.default.walkDown.goUp    = sm.default.walkUp
sm.default.walkDown.goDown  = sm.default.walkDown
sm.default.walkDown.goLeft  = sm.default.walkLeft
sm.default.walkDown.goRight = sm.default.walkRight
sm.default.walkDown.normal_jump     = sm.default.jumping
sm.default.walkDown.idle  = sm.default.idle

sm.default.jumping.UP    = sm.default.jumping
sm.default.jumping.DOWN  = sm.default.jumping
sm.default.jumping.LEFT  = sm.default.jumping
sm.default.jumping.RIGHT = sm.default.jumping
sm.default.jumping.land  = sm.default.landing

sm.default.land          = sm.default.idle

--rewrite
sm.default.idle.UP    = sm.default.walkUp   --sm.default.lookup 
sm.default.idle.DOWN  = sm.default.walkDown --sm.default.lookdown 
sm.default.idle.LEFT  = sm.default.walkLeft
sm.default.idle.RIGHT = sm.default.walkRight
sm.default.idle.normal_jump     = sm.default.jumping

    return sm.default.idle
end

function SM:getStart()

    return self.default.idle

end
return SM
