-- inculdes

return {
    width = 20,
    height = 25,   
    animations = {
        default = {
            'loop',{'1,1'},.5,
        },
        walking = {
            'loop',{'1,2','2,2'},.2,
        },

    },

    walking = true,
    walk_speed = 10,
    stare = true,
    minx = maxx,

    
    talk_items = {
        { ['text']='cool cool cool' },
        { ['text']='cool cool cool' },
        { ['text']='cool cool cool' },
        { ['text']='cool cool cool' },
    },
    talk_responses = {
    ["cool cool cool"]={
        "cool cool cool",
    },

    },
}