function love.conf(t)
    t.title             = "Journey to the Center of Hawkthorne v{{ version }}"
    t.url               = "http://projecthawkthorne.com"
    t.author            = "https://github.com/hawkthorne?tab=members"
    t.version           = "0.9.0"
    t.identity          = "hawkthorne_release"
    t.window.width      = 1056
    t.window.height     = 672
    t.window.fullscreen = false
    t.console           = false
    t.modules.physics   = false
    t.modules.joystick  = false
    t.release           = true
end
