local SM = {}
SM.__index = SM

local DEBUG = true

--============
--DEFINE STATES
--@pose the state that is drawn by the player
--@action the function that is called when the state is entered
--@name name of the state for debugging purposes
--============
function SM.new(player)
    local sm = {}
    setmetatable(sm, SM)
    sm = {
        holding = {
            lookUp   = {pose = 'gaze',     action = nil, name="sm.holding.lookup"},
            lookDown = {pose =  nil,       action = nil, name="sm.holding.lookDown"},
            walkLeft = {pose = 'holdwalk', action = player.doWalking, name="sm.holding.walkLeft"},
            walkRight= {pose = 'holdwalk', action = player.doWalking, name="sm.holding.walkRight"},
            walkUp   = {pose = 'holdwalk', action = player.doWalking, name="sm.holding.walkUp"},
            walkDown = {pose = 'holdwalk', action = player.doWalking, name="sm.holding.walkDown"},
            crouch   = {pose = 'crouch',   action = player.doCrouching, name="sm.holding.crouc"},
            drop     = {pose = 'idle',   action = player.doDrop, name="sm.holding.drop"},
            throw     = {pose = 'idle',   action = player.doThrow, name="sm.holding.throw"},
            throwVertical = {pose = 'idle',   action = player.doThrowVertical, name="sm.holding.throwVertical"},
            jumping  = {pose = 'holdwalk',     action = player.doNormalJumping, name="sm.holding.jumping"},
            idle     = {pose = 'hold',     action = player.doIdling, name="sm.holding.idle"},
        },
        default = {
            lookUp   = {pose = 'gaze',      action = nil, name="sm.default.lookUp"},
            lookDown = {pose =  nil,        action = nil, name="sm.default.lookDown"},
            walkLeft = {pose = 'walk',      action = player.doWalking, name="sm.default.walkLeft"},
            walkRight= {pose = 'walk',      action = player.doWalking, name="sm.default.walkRight"},
            walkUp   = {pose = 'gazewalk',  action = player.doWalking, name="sm.default.walkUp"},
            walkDown = {pose = 'crouchwalk',action = player.doWalking, name="sm.default.walkDown"},
            crouch   = {pose = 'crouch',    action = player.doCrouching, name="sm.default.crouch"},
            pickUp   = {pose = 'hold',      action = player.doPickUp, name="sm.default.pickUp"},
            jumping  = {pose = 'jump',      action = player.doNormalJumping, name="sm.default.jumping"},
            idle     = {pose = 'idle',      action = player.doIdling, name="sm.default.idle"},
        },
    }
    --============
    --DEFINE STATE TRANSITIONS
    --UP,DOWN,LEFT,RIGHT,attack,jump,land,pickUp,idle,crouch
    --============
    --assign all look reactions
    for k,v in pairs(sm) do
        for l,w in pairs(v) do
            if string.find(l,"look") then
                sm[k][l].UP   = sm[k].walkUp
                sm[k][l].DOWN   = sm[k].walkDown
                sm[k][l].LEFT   = sm[k].walkLeft
                sm[k][l].RIGHT  = sm[k].walkRight
                sm[k][l].normalJump = sm[k].jumping
                sm[k][l].idle   = sm[k].idle
            end
        end
    end
    
    --assign all idle actions
    for k,v in pairs(sm) do
        sm[k].idle.UP   = sm[k].walkUp
        sm[k].idle.DOWN   = sm[k].walkDown
        sm[k].idle.LEFT   = sm[k].walkLeft
        sm[k].idle.RIGHT  = sm[k].walkRight
        sm[k].idle.normalJump = sm[k].jumping
        sm[k].idle.pickUp = sm[k].pickUp
        sm[k].idle.drop = sm[k].drop
        sm[k].idle.throw = sm[k].throw
        sm[k].idle.throwVertical = sm[k].throwVertical
    end
    for k,v in pairs(sm.holding) do
        print(k)
        sm.holding[k].drop = sm.holding.drop
        sm.holding[k].throw = sm.holding.throw
        sm.holding[k].throwVertical = sm.holding.throwVertical
    end
    
    --handle landing(walkUp is hacky because I don't want to make a new state)
    for k,v in pairs(sm) do
        sm[k].jumping.land = sm[k].walkUp
    end
    
    --handle pickup
    sm.default.pickUp.idle = sm.holding.idle

    --handle dropping
    sm.holding.drop.idle = sm.default.idle
    sm.holding.throw.idle = sm.default.idle
    sm.holding.throw.idle = sm.default.idle

    --assign all motion positions
    for k,v in pairs(sm) do
        for l,w in pairs(v) do
            if string.find(l,"walk") then
                sm[k][l].goUp = sm[k].walkUp
                sm[k][l].goDown = sm[k].walkDown
                sm[k][l].goLeft = sm[k].walkLeft
                sm[k][l].goRight = sm[k].walkRight
                sm[k][l].normalJump = sm[k].jumping
                sm[k][l].idle = sm[k].idle
            end
        end
        sm[k].walkDown.goUp = sm[k].idle
        sm[k].walkUp.goDown = sm[k].idle
        sm[k].walkRight.goLeft = sm[k].idle
        sm[k].walkLeft.goRight = sm[k].idle
    end
    return sm.default.idle
end

--============
--DEFINE STATES
--@pose the state that is drawn by the player
--@action the function that is called when the state is entered
--@name name of the state for debugging purposes
--============

function SM.advanceState(actor,event)
    assert(actor.spriteState,"Object requires a spriteState key referring to its current statemachine state")
    local nextSpriteState = actor.spriteState[event]
    if not nextSpriteState then return end

    debugPrint("from:"..actor.spriteState.name)
    debugPrint("cmd:"..event)
    if nextSpriteState.action then
        --io.write("func:")
        debugPrint(nextSpriteState.action)
        nextSpriteState.action(actor)
    else
        debugPrint("no function")
    end
    
    actor.spriteState = nextSpriteState
    actor.character.state = actor.spriteState.pose
    debugPrint("pose:"..actor.character.state)
    debugPrint("to:"..actor.spriteState.name)
    debugPrint()
    return actor.character.state
end

function debugPrint(...)
    if DEBUG then
        print(...)
    end
end
return SM
