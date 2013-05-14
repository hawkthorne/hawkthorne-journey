local config = require 'hawk/config'

function love.conf(t)
    local c = config.load('config.json')

    t.title             = c.title
    t.url               = c.url
    t.author            = c.author
    t.version           = c.version
    t.identity          = c.indentity
    t.screen.width      = c.screen.width
    t.screen.height     = c.screen.height
    t.screen.fullscreen = c.screen.fullscreen
    t.console           = c.console
    t.modules.physics   = c.modules.physics
    t.modules.joystick  = c.modules.joystick
    t.release           = c.release
end
