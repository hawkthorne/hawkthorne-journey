local gamepad  = {}

function gamepad.isDown(button)
    if button == 'down' then
        return love.keyboard.isDown('down') or love.keyboard.isDown('s')
    elseif button == 'up' then
        return love.keyboard.isDown('up') or love.keyboard.isDown('w')
    elseif button == 'left' then
        return love.keyboard.isDown('left') or love.keyboard.isDown('a')
    elseif button == 'right' then
        return love.keyboard.isDown('right') or love.keyboard.isDown('d')
    else
        return false
    end
end

function gamepad.press(key)
    local button = {}
    button.key = key
    button.down = key == 'down' or key == 's'
    button.up = key == 'up' or key == 'w'
    button.left = key == 'left' or key == 'a'
    button.right = key == 'right' or key == 'd'
    button.start = key == 'escape'
    button.select = false
    button.a = key == 'x'
    button.b = key == 'z'
    return button
end

return gamepad
