local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local window = require 'window'
local Prompt = require 'prompt'
local camera = require 'camera'
local state = Gamestate.new()

function state:init()
    self.table = love.graphics.newImage( 'images/card_table.png' )
    self.cardSprite = love.graphics.newImage('images/cards.png' )
    self.chipSprite = love.graphics.newImage('images/chips.png' )
    self.card = { ace = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10, jack = 11, queen = 12, king = 13 }
    self.suit = { spade = 1, club = 2, heart = 3, diamond = 4 }
    
    self.center = {}
    self.center.x = ( window.width / 2 )
    self.center.y = ( window.height / 2 )
    self.frame = -100
end

function state:update(dt)
    if self.prompt then self.prompt:update(dt) end
    self.frame = self.frame + 2
    if self.frame >= 200 then self.frame = -50 end
end

function state:enter(previous, screenshot)
    self.music = love.audio.play("audio/daybreak.ogg", "stream", true)

    self.previous = previous
    self.screenshot = screenshot
    
    self.camera_x = camera.x
    camera.max.x = 0
    camera:setPosition( 0, 0 )
end

function state:leave()
    camera.x = self.camera_x
end

function state:draw()
    if self.screenshot then
        love.graphics.draw( self.screenshot, 0, 0, 0, 0.5, 0.5 )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    love.graphics.draw( self.table, self.center.x - ( self.table:getWidth() / 2 ), self.center.y - ( self.table:getHeight() / 2 ) )
    
    -- dealers stack
    local frame = self.frame
    if frame < 0 then frame = 0 end
    if frame > 100 then frame = 100 end
    self:drawCard( self.card.ace, self.suit.diamond, frame, map( frame, 0, 100, 300, 300 ), 40 )
    self:drawCard( self.card.ace, self.suit.diamond, frame, map( frame, 0, 100, 60, 120 ), 40 )
    self:drawCard( self.card.jack, self.suit.club, frame, map( frame, 0, 100, 300, 120 ), 100 )
    self:drawCard( self.card.five, self.suit.heart, frame, map( frame, 0, 100, 60, 300 ), 160 )
    
    if self.prompt then
        self.prompt:draw( self.center.x, self.center.y )
    end

end

function state:keypressed(key, player)
    if key == 'escape' then
        self.prompt = Prompt.new( 120, 55, "Are you sure you want to exit?", function(result)
            if result then Gamestate.switch(self.previous) end
        end )
    end

    if self.prompt then
        self.prompt:keypressed(key)
    end
end

function state:drawCard( card, suit, flip, x, y )
    -- flip is a number from 0 to 100, where 0 is completely face down, and 100 is completely face up
    local w = 38                -- card width
    local h = 55                -- card height
    local st = 0.2              -- stretched top
    local sh = h * ( 1 + st )   -- stretched height
    if flip > 50 then
        limit = 100
        _card = love.graphics.newQuad( ( card - 1 ) * w, ( suit - 1 ) * h, w, h, self.cardSprite:getWidth(), self.cardSprite:getHeight() )
    else
        limit = 0
        _card = love.graphics.newQuad( 0, h * 4, w, h, self.cardSprite:getWidth(), self.cardSprite:getHeight() )
    end
    darkness = map( flip, 50, limit, 0, 250 )
    love.graphics.setColor( darkness, darkness, darkness )
    love.graphics.drawq(
        self.cardSprite, _card,                                  -- image, quad
        x + map( flip, 50, limit, w / 2, 0 ),               -- offset for flip
        map( flip, 50, limit, y - ( ( sh - h ) / 2 ), y ),  -- height offset
        0,                                                  -- no rotation
        map( flip, 50, limit, 0, 1 ),                       -- scale width for flip
        map( flip, 50, limit , 1 + st, 1 )                  -- scale height for flip
    )

    love.graphics.setColor( 255, 255, 255, 255 )
end

function map( x, in_min, in_max, out_min, out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end

return state