local window = {}
window.width = 456
window.height = 269
window.level = 'studyroom'

local arial = love.graphics.newImage("arialfont.png")
arial:setFilter('nearest', 'nearest')

window.font = love.graphics.newImageFont(arial,
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/:;%&`'*#=\"", 12)

return window
