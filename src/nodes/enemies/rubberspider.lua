local sound = require 'vendor/TEsound'

return { 
    name = 'rubberspider',
    die_sound = 'jump',
    height = 24,
    width = 24,
    antigravity = true,
    hp = 100000,
    vulnerabilities = {'blunt'},
    damage = 0,
    dyingdelay = 0.1,
    peaceful = true,
    tokens = 3,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.9 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        default = {
            left = {'loop', {'1,1'}, 1},
            right ={'loop', {'1,1'}, 1}
        },
        hurt = {
            left = {'once', {'2-5,1'}, 1},
            right ={'once', {'2-5,2'}, 1}
        },
        dying = {
            left = {'once', {'2-5,1'}, 1},
            right ={'once', {'2-5,1'}, 1}
        }
    }
}