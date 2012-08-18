local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local window = require 'window'
local timer = require 'vendor/timer'
local Prompt = require 'prompt'
local camera = require 'camera'
local state = Gamestate.new()

function state:init()
    math.randomseed( os.time() )
    
    self.table = love.graphics.newImage( 'images/card_table.png' )
    self.cardSprite = love.graphics.newImage('images/cards.png' )
    self.chipSprite = love.graphics.newImage('images/chips.png' )
    self.card_width = 38
    self.card_height = 55
    
    self.center_x = ( window.width / 2 )
    self.center_y = ( window.height / 2 )
    self.dealer_stack_x = 350
    self.dealer_stack_y = 40
    
    self.max_card_room = 220
    self.width_per_card = 44
    
    self.decks_to_use = 8
    
    self.card_speed = .5
    
    self.score = 25
    
    self.options_x = 350
    self.options_y = 120
    self.options = {
        { name = 'HIT', action = 'hit', active = false },
        { name = 'STAND', action = 'stand', active = false },
        { name = 'DEAL', action = 'deal', active = true },
        { name = 'BET +', action = 'bet_up', active = true },
        { name = 'BET -', action = 'bet_down', active = true },
        { name = 'QUIT', action = 'quit', active = true },
    }
    self.selection = 2
    
end

function state:update(dt)
    timer.update(dt)
    if self.prompt then self.prompt:update(dt) end
    self:update_cards( self.player_cards, self.dealer_cards, dt )
    self.selected = self.options[ self.selection + 1 ].name
end

function state:update_cards( plyr, delr, dt )
    max = math.max( #plyr, #delr )
    moved = false
    for i = 1, max, 1 do
        if not moved then
            if plyr[i] then
                moved = self:move_card( plyr[i], dt )
            end
            if delr[i] and not moved then
                moved = self:move_card( delr[i], dt )
            end
            self:updateScore( plyr )
            self:updateScore( delr )
        end
    end
end

function state:move_card( card, dt )
    moved = false
    if card.move_idx < self.card_speed then
        moved = true
        card.move_idx = card.move_idx + dt
    else
        card.move_idx = self.card_speed
    end

    if card.face_up then
        if card.flip_idx < self.card_speed then
            moved = true
            card.flip_idx = card.flip_idx + dt
        else
            card.flip_idx = self.card_speed
        end
    end
    return moved
end

function state:enter(previous, screenshot)
    self.music = love.audio.play("audio/daybreak.ogg", "stream", true)

    self.previous = previous
    self.screenshot = screenshot
    
    self.camera_x = camera.x
    camera.max.x = 0
    camera:setPosition( 0, 0 )
    
    self.dealer_cards = {}
    self.player_cards = {}
    
    self.deck = newDeck( self.decks_to_use )
    
    if self.score <= 0 then
        self.score = 25
    end
    
    self.dealer_score = nil
    self.player_score = nil
end

function state:leave()
    camera.x = self.camera_x
end

function state:keypressed(key, player)
    if self.prompt then
        self.prompt:keypressed(key)
    else
    
        if key == 'escape' or ( key == 'return' and self.selected == 'QUIT' ) then
            self.prompt = Prompt.new( 120, 55, "Are you sure you want to exit?", function(result)
                if result then
                    Gamestate.switch(self.previous)
                else
                    self.prompt = nil
                end
            end )
        end

        if key == 'return' then
            if self.selected == 'DEAL' then
                state:dealHand()
            elseif self.selected == 'HIT' then
                self:dealCard( 'player' )
            elseif self.selected == 'STAY' then
                -- stop hand
            end
        end
        
        if key == ' ' then
            if not self.dealer_cards[ 2 ].face_up then
                self.dealer_cards[ 2 ].face_up = true
            else
                self:dealCard( 'dealer' )
            end
        end
    
        if key == 'up' or key == 'w' then
            repeat
                self.selection = (self.selection - 1) % #self.options
            until self.options[ self.selection + 1 ].active
        elseif key == 'down' or key == 's' then
            repeat
                self.selection = (self.selection + 1) % #self.options
            until self.options[ self.selection + 1 ].active
        end
        
    end
end

function state:dealHand()
    self:dealCard( 'player' )
    self:dealCard( 'dealer' )
    self:dealCard( 'player' )
    self:dealCard( 'dealer' )
    self.selection = 0 -- hit
    self.options[ 1 ].active = true --hit
    self.options[ 2 ].active = true --stand
    self.options[ 3 ].active = false --deal
    self.options[ 4 ].active = false --bet
    self.options[ 5 ].active = false --bet
end

function state:dealCard( to )
    deal_card = table.remove( self.deck, 1 )
    x = 270
    face_up = true
    tbl = self.player_cards
    y = 150
    if to == 'dealer' then
        if #self.dealer_cards == 1 then
            face_up = false
        end
        tbl = self.dealer_cards
        y = 70
    end
    table.insert(
        tbl,
        {
            card = deal_card.card,
            suit = deal_card.suit,
            x = x - ( self.width_per_card * #tbl ),
            y = y,
            move_idx = 0,
            flip_idx = 0,
            face_up = face_up
        }
    )

    -- adjust widths when we've run out of room
    if #tbl * self.width_per_card > self.max_card_room then
        new_width = self.max_card_room / #tbl
        for i,n in pairs( tbl ) do
            n.x = x - ( new_width * ( i - 1 ) )
        end
    end
end

function state:updateScore( tbl )
    score = {}
    for i,n in pairs( tbl ) do
        if n.face_up and n.flip_idx == self.card_speed then
            points = { n.card }
            if n.card == 1 then -- ace
                points = { 1, 11 }
            elseif n.card > 10 then -- face
                points = { 10 }
            end
            score = self:addPointsToScore( points, score )
        end
    end
    if tbl == self.dealer_cards then
        self.dealer_score = score
    else
        self.player_score = score
    end
end

function state:addPointsToScore( points, score )
    _new = {}
    if #score == 0 then
        _new = points
    else
        for i = 1, #score, 1 do
            for j = 1, #points, 1 do
                table.insert( _new, score[i] + points[j] )
            end
        end
    end
    table.sort( _new )
    _no_dup = {}
    for x = 1, #_new, 1 do
        if _new[x] ~= last then
            table.insert( _no_dup, _new[x] )
            last = _new[x]
        end
    end
    return _no_dup
end

function state:draw()
    if self.screenshot then
        love.graphics.draw( self.screenshot, 0, 0, 0, 0.5, 0.5 )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    love.graphics.draw( self.table, self.center_x - ( self.table:getWidth() / 2 ), self.center_y - ( self.table:getHeight() / 2 ) )

    -- dealers stack
    if #self.deck > 0 then
        _card = love.graphics.newQuad( 0, self.card_height * 4, self.card_width, self.card_height, self.cardSprite:getWidth(), self.cardSprite:getHeight() )
        love.graphics.drawq( self.cardSprite, _card, self.dealer_stack_x, self.dealer_stack_y )
    end
    
    for i,n in pairs( self.dealer_cards ) do
        self:drawCard(
            n.card, n.suit,                                                    -- card / suit
            map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
            map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
            map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y )    -- y
        )
    end

    for i,n in pairs( self.player_cards ) do
        self:drawCard(
            n.card, n.suit,                                                    -- card / suit
            map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
            map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
            map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y )    -- y
        )
    end
    
    for i,n in pairs( self.options ) do
        local x = self.options_x
        local y = self.options_y + ( i * 15 )
        co = 0 -- color offset
        if not n.active then co = 180 end
        if i == self.selection + 1 then co = 255 end
        love.graphics.setColor( 255 - co, 255 - co, 255 - co )
        love.graphics.print( n.name, x + 3, y + 3, 0, 0.5 )
    end
    
    if self.dealer_score then
        love.graphics.print( table.concat( self.dealer_score, "\n" ), 310, 90, 0, 0.5 )
    end
    if self.player_score then
        love.graphics.print( table.concat( self.player_score, "\n" ), 310, 170, 0, 0.5 )
    end
    
    if self.prompt then
        self.prompt:draw( self.center_x, self.center_y )
    end
    
    love.graphics.setColor( 255, 255, 255, 255 )
    
    love.graphics.print( 'score: ' .. self.score, 100, 5, 0, 0.5 )
    love.graphics.print( 'selection: ' .. self.selection, 200, 5, 0, 0.5 )

    love.graphics.setColor( 255, 255, 255, 255 )
end

function state:drawCard( card, suit, flip, x, y )
    -- flip is a number from 0 to 100, where 0 is completely face down, and 100 is completely face up
    local w = self.card_width   -- card width
    local h = self.card_height  -- card height
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
        self.cardSprite, _card,                             -- image, quad
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

function newDeck(_decks)
    if _decks == nil then _decks = 1 end
    deck = {}
    for _deck = 1,_decks,1 do
        for _suit = 1,4,1 do
            for _card = 1,13,1 do
                table.insert( deck, { card = _card, suit = _suit } )
            end
        end
    end
    deck = shuffle( deck, math.random( 5 ) + 5 ) -- shuffle the deck between 5 and 10 times
    return deck
end

function shuffle( deck, n )
    -- http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
    if n == nil then n = 1 end
    for i = 1, #deck, 1 do
        j = math.random( #deck )
        _temp = deck[i]
        deck[i] = deck[j]
        deck[j] = _temp
    end
    n = n - 1
    if n > 0 then
        return shuffle( deck, n )
    else
        return deck
    end
end

return state