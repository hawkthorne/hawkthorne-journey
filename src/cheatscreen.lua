local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local cheatscreen = Gamestate.new()
local cheat = require 'cheat'

-- '_' is spacebar ( 5 widths ), '|' is enter ( 2 widths ), ' ' is a full width blank and '-' is a half width blank
local keyboard = {
    'qwertyuiop 789',
    '-asdfghjkl- 456',
    ' zxcvbnm| 123',
    '  _    0'
}
local special = {}
special['_'] = { display = '', key = ' ', size = 5 }
special['|'] = { display = 'enter', key = 'enter', size = 2 }
special['0'] = { display = '0', key = '0', size = 3 }
special['-'] = { size = 0.5 }
special[' '] = { size = 1 }

local keys = {}
keys['q'] = { UP='_', DOWN='a', LEFT='9', RIGHT='w' }
keys['w'] = { UP='_', DOWN='s', LEFT='q', RIGHT='e' }
keys['e'] = { UP='_', DOWN='d', LEFT='w', RIGHT='r' }
keys['r'] = { UP='_', DOWN='f', LEFT='e', RIGHT='t' }
keys['t'] = { UP='_', DOWN='g', LEFT='r', RIGHT='y' }
keys['y'] = { UP='_', DOWN='h', LEFT='t', RIGHT='u' }
keys['u'] = { UP='_', DOWN='j', LEFT='y', RIGHT='i' }
keys['i'] = { UP='_', DOWN='k', LEFT='u', RIGHT='o' }
keys['o'] = { UP='_', DOWN='l', LEFT='i', RIGHT='p' }
keys['p'] = { UP='_', DOWN='l', LEFT='o', RIGHT='7' }
keys['a'] = { UP='q', DOWN='z', LEFT='6', RIGHT='s' }
keys['s'] = { UP='w', DOWN='x', LEFT='a', RIGHT='d' }
keys['d'] = { UP='e', DOWN='c', LEFT='s', RIGHT='f' }
keys['f'] = { UP='r', DOWN='v', LEFT='d', RIGHT='g' }
keys['g'] = { UP='t', DOWN='b', LEFT='f', RIGHT='h' }
keys['h'] = { UP='y', DOWN='n', LEFT='g', RIGHT='j' }
keys['j'] = { UP='u', DOWN='m', LEFT='h', RIGHT='k' }
keys['k'] = { UP='i', DOWN='|', LEFT='j', RIGHT='l' }
keys['l'] = { UP='o', DOWN='|', LEFT='k', RIGHT='4' }
keys['z'] = { UP='a', DOWN='_', LEFT='3', RIGHT='x' }
keys['x'] = { UP='s', DOWN='_', LEFT='z', RIGHT='c' }
keys['c'] = { UP='d', DOWN='_', LEFT='x', RIGHT='v' }
keys['v'] = { UP='f', DOWN='_', LEFT='c', RIGHT='b' }
keys['b'] = { UP='g', DOWN='_', LEFT='v', RIGHT='n' }
keys['n'] = { UP='h', DOWN='_', LEFT='b', RIGHT='m' }
keys['m'] = { UP='j', DOWN='_', LEFT='n', RIGHT='|' }
keys['_'] = { UP='v', DOWN='t', LEFT='0', RIGHT='0' }
keys['|'] = { UP='l', DOWN='_', LEFT='m', RIGHT='1' }
keys['0'] = { UP='2', DOWN='8', LEFT='_', RIGHT='_' }
keys['1'] = { UP='4', DOWN='0', LEFT='|', RIGHT='2' }
keys['2'] = { UP='5', DOWN='0', LEFT='1', RIGHT='3' }
keys['3'] = { UP='6', DOWN='0', LEFT='2', RIGHT='z' }
keys['4'] = { UP='7', DOWN='1', LEFT='l', RIGHT='5' }
keys['5'] = { UP='8', DOWN='2', LEFT='4', RIGHT='6' }
keys['6'] = { UP='9', DOWN='3', LEFT='5', RIGHT='a' }
keys['7'] = { UP='0', DOWN='4', LEFT='p', RIGHT='8' }
keys['8'] = { UP='0', DOWN='5', LEFT='7', RIGHT='9' }
keys['9'] = { UP='0', DOWN='6', LEFT='8', RIGHT='q' }

local keyboard_x = 20
local keyboard_y = 200

local keyheight = 25
local keywidth = 25
local keyspace = 5

function cheatscreen:update(dt)
    self.cmd.cursor_pos = self.cmd.offset_x + ( ( string.len( self.cmd.prompt ) + 1 + string.len( self.cmd.current ) ) * self.cmd.char_width )
    self.cycle = self.cycle + 1
    if self.cycle > self.cmd.blink_rate then
        self.cycle = 0
        self.cmd.blink_state = not self.cmd.blink_state
    end
end

function cheatscreen:enter( previous, real_previous )
    self.cmd = {
        active = true,
        offset_x = 20,
        offset_y = 20,
        current = '',
        prompt = 'C:\\hawthornelabs\\hawkthorne >',
        char_width = 6.5,
        blink_rate = 30,
        queue = {},
        line_height = 14,
        cnf = 'Command Not Found',
        max_lines = 11,
        space = '     ',
        exit = 'Exiting back to game...'
    }
    
    self.cycle = 0
    
    sound.playMusic( "daybreak" )

    fonts.set( 'courier' )
    
    camera:setPosition(0, 0)
    self.previous = real_previous
    
    self.current_key = 'g'
end

function cheatscreen:leave()
    fonts:reset()
end

function cheatscreen:exit()
    table.insert( self.cmd.queue, self.cmd.space .. self.cmd.exit )
    Timer.add(1, function()
        Gamestate.switch( self.previous )
    end)
    self.cmd.active = false
end

function cheatscreen:keypressed( button )
    if button == 'START' then
        if self.cmd.active then
            table.insert( self.cmd.queue, self.cmd.prompt .. ' ' .. self.cmd.current )
            cheatscreen:exit()
            return
        end
    elseif self.cmd.active then
        if button == 'SELECT' then
            table.insert( self.cmd.queue, self.cmd.prompt .. ' ' .. self.cmd.current )
            -- start parse
            if  self.cmd.current == '..' or
                self.cmd.current == 'quit' or
                self.cmd.current == 'exit' or
                self.cmd.current == 'log off' or
                self.cmd.current == 'logoff' or
                self.cmd.current == 'log out' or
                self.cmd.current == 'logout' then
                    cheatscreen:exit()
            elseif self.cmd.current == 'pop pop' then
                cheat:toggle('jump_high')
                table.insert( self.cmd.queue, self.cmd.space .. 'Extra High Jump: ' .. ( cheat:is('jump_high') and 'Enabled' or 'Disabled' ) )
            elseif self.cmd.current == 'spacetime' then
                cheat:toggle('god')
                table.insert( self.cmd.queue, self.cmd.space .. 'God Mode: ' .. ( cheat:is('god') and 'Enabled' or 'Disabled' ) )
            elseif self.cmd.current == 'go abed go' then
                cheat:toggle('super_speed')
                table.insert( self.cmd.queue, self.cmd.space .. 'Super Speed: ' .. ( cheat:is('super_speed') and 'Enabled' or 'Disabled' ) )
            elseif self.cmd.current == 'slide' then
                cheat:toggle('slide_attack')
                table.insert( self.cmd.queue, self.cmd.space .. 'Slide Attack: ' .. ( cheat:is('slide_attack') and 'Enabled' or 'Disabled' ) )
            elseif self.cmd.current == 'hello rich people' then
                cheat:toggle('give_money')
                table.insert( self.cmd.queue, self.cmd.space .. 'Money granted' )
            elseif self.cmd.current == 'seacrest hulk' then
                cheat:toggle('max_health')
                table.insert( self.cmd.queue, self.cmd.space .. 'Health filled' )
            elseif self.cmd.current == 'greendale is where i belong' then
                cheat:toggle('give_gcc_key')
                table.insert( self.cmd.queue, self.cmd.space .. 'Key granted' )
            elseif self.cmd.current == 'zombie' then
                cheat:toggle('give_taco_meat')
                table.insert( self.cmd.queue, self.cmd.space .. 'You found some taco meat in the dumpster' )
            elseif self.cmd.current == 'use respect' then
                cheat:toggle('give_weapons')
                table.insert( self.cmd.queue, self.cmd.space .. 'Weapons granted' )
            elseif self.cmd.current == 'this is more complex' then
                cheat:toggle('give_materials')
                table.insert( self.cmd.queue, self.cmd.space .. 'Materials granted' )
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
        elseif button == 'JUMP' then
            self.cmd.current = string.sub(self.cmd.current, 1, -2 )
        elseif button == 'UP' or button == 'DOWN' or button == 'LEFT' or button == 'RIGHT' then
            self.current_key = keys[self.current_key][button]
        elseif button == 'ATTACK' then
            if special[self.current_key] and special[self.current_key].key then
                if special[self.current_key].key == 'enter' then
                    self:keypressed( 'SELECT' )
                else
                    self.cmd.current = self.cmd.current .. special[self.current_key].key
                end
            else
                self.cmd.current = self.cmd.current .. self.current_key
            end
        end
    end
end

function cheatscreen:draw()
    local y = self.cmd.offset_y
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.rectangle( 'fill', 0, 0, window.width, window.height )
    love.graphics.setColor( 88, 246, 0, 255 )
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
    
    --draw the keyboard
    for y,row in pairs( keyboard ) do
        local x = 0
        for key in string.gmatch(row,".") do
            x = x + 1
            local kx = keyboard_x + x * ( keywidth + keyspace )
            local ky = keyboard_y + ( y - 1 ) * ( keyheight + keyspace )
            local w, h, display = keywidth, keyheight, key
            if special[key] then
                x = x + ( special[key].size - 1 )
                w = keywidth * special[key].size + keyspace * ( special[key].size - 1 )
                display = special[key].display
            end
            if display then
                if self.current_key == key then
                    love.graphics.setColor( 88, 246, 0, 60 )
                    love.graphics.rectangle( 'fill', kx + 0.5, ky + 0.5, w - 1, h - 1 )
                    love.graphics.setColor( 88, 246, 0, 255 )
                else
                    love.graphics.setColor( 88, 246, 0, 35 )
                    love.graphics.rectangle( 'fill', kx + 0.5, ky + 0.5, w - 1, h - 1 )
                    love.graphics.setColor( 88, 246, 0, 240 )
                end
                roundedrectangle( kx, ky, w, h, keywidth / 6 )
                love.graphics.print( display, kx + 9, ky + 6, 0, 0.6, 0.7)
            end
        end
    end

    love.graphics.setColor( 255, 255, 255, 255 )
end

return cheatscreen

