local SM = {}
SM.__index = SM

function SM.new(player)
    local sm = {}
    setmetatable(sm, SM)
    sm = {
    holding = {
        lookup   = {pose = 'gaze',     action = nil},
        lookdown = {pose =  nil,       action = nil},
        walkLeft = {pose = 'holdwalk', action = player.walking},
        walkRight= {pose = 'holdwalk', action = player.walking},
        walkUp   = {pose = 'gazewalk', action = player.walking},
        walkDown = {pose = 'gazewalk', action = player.walking},
        crouch   = {pose = 'crouch',   action = player.beginCrouching},
        drop     = {pose = 'crouch',   action = player.drop},
        jumping  = {pose = 'hold',     action = player.normalJumping},
        --landing  = {pose = 'hold',     action = player.landing},
        idle     = {pose = 'hold',     action = nil},
    },
    default = {
        lookup   = {pose = 'gaze',      action = nil},
        lookdown = {pose =  nil,        action = nil},
        walkLeft = {pose = 'walk',      action = player.walking},
        walkRight= {pose = 'walk',      action = player.walking},
        walkUp   = {pose = 'gazewalk',  action = player.walking},
        walkDown = {pose = 'crouchwalk',action = player.walking},
        crouch   = {pose = 'crouch',    action = player.beginCrouching},
        pickup   = {pose = 'current',   action = player.pickUp},
        jumping  = {pose = 'jump',      action = player.normalJumping},
        --landing  = {pose = 'idle',      action = player.landing},
        idle     = {pose = 'idle',      action = player.idling},
    },
    
    }
    
    
    --up,down,left,right,attack,jump,land,pickup,idle,crouch
sm.default.lookup.DOWN   = sm.default.idle
sm.default.lookup.LEFT   = sm.default.walkLeft
sm.default.lookup.RIGHT  = sm.default.walkRight
sm.default.lookup.normalJump      = sm.default.jumping
sm.default.lookup.idle   = sm.default.idle

sm.default.lookdown.UP     = sm.default.idle
sm.default.lookdown.LEFT   = sm.default.walkLeft
sm.default.lookdown.RIGHT  = sm.default.walkRight
sm.default.lookdown.normalJump      = sm.default.jumping
sm.default.lookdown.idle   = sm.default.idle

sm.default.walkLeft.goUp     = sm.default.walkUp
sm.default.walkLeft.goDown   = sm.default.walkDown
sm.default.walkLeft.goLeft   = sm.default.walkLeft
sm.default.walkLeft.goRight  = sm.default.walkRight
sm.default.walkLeft.normalJump      = sm.default.jumping
sm.default.walkLeft.idle   = sm.default.idle

sm.default.walkRight.goUp     = sm.default.walkUp
sm.default.walkRight.goDown   = sm.default.walkDown
sm.default.walkRight.goLeft   = sm.default.walkLeft
sm.default.walkRight.goRight  = sm.default.walkRight
sm.default.walkRight.normalJump      = sm.default.jumping
sm.default.walkRight.idle   = sm.default.idle

sm.default.walkUp.goUp     = sm.default.walkUp
sm.default.walkUp.goDown   = sm.default.walkDown
sm.default.walkUp.goLeft   = sm.default.walkLeft
sm.default.walkUp.goRight  = sm.default.walkRight
sm.default.walkUp.normalJump      = sm.default.jumping
sm.default.walkUp.idle   = sm.default.idle

sm.default.walkDown.goUp    = sm.default.walkUp
sm.default.walkDown.goDown  = sm.default.walkDown
sm.default.walkDown.goLeft  = sm.default.walkLeft
sm.default.walkDown.goRight = sm.default.walkRight
sm.default.walkDown.normalJump     = sm.default.jumping
sm.default.walkDown.idle  = sm.default.idle

sm.default.jumping.land = sm.default.walkRight

--rewrite
sm.default.idle.UP    = sm.default.walkUp   --sm.default.lookup 
sm.default.idle.DOWN  = sm.default.walkDown --sm.default.lookdown 
sm.default.idle.LEFT  = sm.default.walkLeft
sm.default.idle.RIGHT = sm.default.walkRight
sm.default.idle.normalJump     = sm.default.jumping

    return sm.default.idle
end

return SM
