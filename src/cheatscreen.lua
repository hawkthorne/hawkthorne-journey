local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local state = Gamestate.new()
local cheat = require 'cheat'

function state:init()

end

function state:update(dt)
    self.cmd.cursor_pos = self.cmd.offset_x + ( ( string.len( self.cmd.prompt ) + 1 + string.len( self.cmd.current ) ) * self.cmd.char_width )
    self.cycle = self.cycle + 1
    if self.cycle > self.cmd.blink_rate then
        self.cycle = 0
        self.cmd.blink_state = not self.cmd.blink_state
    end
    Timer.update(dt)
end

function state:enter( previous, real_previous )
    self.cmd = {
        active = true,
        offset_x = 20,
        offset_y = 20,
        current = '',
        prompt = 'C:\\hawthornelabs\\hawkthorne >',
        font_size = 20,
        char_width = 6,
        blink_rate = 30,
        queue = {},
        line_height = 14,
        cnf = 'Command Not Found',
        max_lines = 16,
        space = '     ',
        exit = 'Exiting back to game...'
    }
    
    self.cycle = 0
    
    sound.playMusic( "audio/daybreak.ogg" )

    self.orig_font = love.graphics.getFont()
    love.graphics.setFont( love.graphics.newFont("courier.ttf", self.cmd.font_size ) )
    
    camera:setPosition(0, 0)
    self.previous = real_previous
	
end

function state:leave()
    love.graphics.setFont( self.orig_font )
end

function state:exit()
    table.insert( self.cmd.queue, self.cmd.space .. self.cmd.exit )
    Timer.add(1, function()
        Gamestate.switch( self.previous )
    end)
    self.cmd.active = false    
end

function state:keypressed(key)
    if key == 'escape' then
        table.insert( self.cmd.queue, self.cmd.prompt .. ' ' .. self.cmd.current )
        state:exit()
        return
    elseif self.cmd.active then
        if key == 'return' then
            table.insert( self.cmd.queue, self.cmd.prompt .. ' ' .. self.cmd.current )
            -- start parse
            if  self.cmd.current == '..' or
                self.cmd.current == 'quit' or
                self.cmd.current == 'exit' or
                self.cmd.current == 'log off' or
                self.cmd.current == 'logoff' or
                self.cmd.current == 'log out' or
                self.cmd.current == 'logout' then
                    state:exit()
            elseif self.cmd.current == 'pop pop' then
                cheat.jump_high = not cheat.jump_high
                table.insert( self.cmd.queue, self.cmd.space .. 'Extra High Jump: ' .. ( cheat.jump_high and 'Enabled' or 'Disabled' ) )
            elseif self.cmd.current == 'spacetime' then
                cheat.god = not cheat.god
                table.insert( self.cmd.queue, self.cmd.space .. 'God Mode: ' .. ( cheat.god and 'Enabled' or 'Disabled' ) )
            else
                table.insert( self.cmd.queue, self.cmd.space .. self.cmd.cnf )
            end
            -- end parse
            self.cmd.current = ''
            if #self.cmd.queue > self.cmd.max_lines - 1 then
                for x = 1, #self.cmd.queue - self.cmd.max_lines + 1 do 
                    table.remove( self.cmd.queue, 1 )
                end
            end
        elseif key == 'backspace' then
            self.cmd.current = string.sub(self.cmd.current, 1, -2 )
        elseif ( key ~= '[' and key ~= ']' and key ~= '.' ) then
            if string.find( ' abcdefghijklmnopqrstuvwxyz1234567890', key ) then
                self.cmd.current = self.cmd.current .. key
            end
        end
    end
end

function state:draw()
    local y = self.cmd.offset_y
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle( 'fill', 0, 0, window.width, window.height )
    love.graphics.setColor(88, 246, 0)
    for i,n in pairs(self.cmd.queue) do
        love.graphics.print( n, self.cmd.offset_x, y, 0, 0.5, 0.5 )
        y = y + self.cmd.line_height
    end
    if self.cmd.active then
        love.graphics.print( self.cmd.prompt, self.cmd.offset_x, y, 0, 0.5, 0.5)
        love.graphics.print( self.cmd.current, self.cmd.offset_x + ( ( string.len( self.cmd.prompt ) + 1 ) * self.cmd.char_width ), y, 0, 0.5, 0.5 )
        if self.cmd.blink_state then
            love.graphics.rectangle( 'fill', self.cmd.cursor_pos, y, 5, 10)
        end
    end

    love.graphics.setColor(255, 255, 255)
end


return state

