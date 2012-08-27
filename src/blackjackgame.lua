local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local window = require 'window'
local timer = require 'vendor/timer'
local Prompt = require 'prompt'
local Dialog = require 'dialog'
local camera = require 'camera'
local state = Gamestate.new()
local sound = require 'vendor/TEsound'

function state:init()
    math.randomseed( os.time() )
    
    self.table = love.graphics.newImage( 'images/card_table_blackjack.png' )

    self.cardSprite = love.graphics.newImage('images/cards.png' )
    self.card_width = 38
    self.card_height = 55

    self.chipSprite = love.graphics.newImage('images/chips.png' )
    self.chip_width = 13
    self.chip_height = 13
    self.chips = {
        -- black ( $100 )
        love.graphics.newQuad( self.chip_width, self.chip_height, self.chip_width, self.chip_height, self.chipSprite:getWidth(), self.chipSprite:getHeight() ),
        -- green ( $25 )
        love.graphics.newQuad( 0, self.chip_height * 2, self.chip_width, self.chip_height, self.chipSprite:getWidth(), self.chipSprite:getHeight() ),
        -- blue ( $10 )
        love.graphics.newQuad( 0, self.chip_height, self.chip_width, self.chip_height, self.chipSprite:getWidth(), self.chipSprite:getHeight() ),
        -- red ( $5 )
        love.graphics.newQuad( 0, 0, self.chip_width, self.chip_height, self.chipSprite:getWidth(), self.chipSprite:getHeight() ),
        -- white ( $1 )
        love.graphics.newQuad( self.chip_width, 0, self.chip_width, self.chip_height, self.chipSprite:getWidth(), self.chipSprite:getHeight() )
    }
    self.chip_x = 140
    self.chip_y = 208
    
    self.center_x = ( window.width / 2 )
    self.center_y = ( window.height / 2 )
    self.dealer_stack_x = 356
    self.dealer_stack_y = 37
    
    self.max_card_room = 227
    self.width_per_card = 45
    
    self.decks_to_use = 8
    
    self.card_speed = 0.5
    
    self.options_arrow = love.graphics.newImage( 'images/tiny_arrow.png' )
    self.options_x = 360
    self.options_y = 135
    self.options = {
        { name = 'HIT', action = 'hit' },
        { name = 'STAND', action = 'stand' },
        { name = 'DEAL', action = 'deal' },
        { name = 'BET +', action = 'bet_up' },
        { name = 'BET -', action = 'bet_down' },
        { name = 'QUIT', action = 'quit', active = true },
    }
    self.selection = 2

    self.money = 25

    self.bet = 2
end

function state:enter(previous, screenshot)
    sound.playMusic( "tavern" )

    self.previous = previous
    self.screenshot = screenshot
    
    self.camera_x = camera.x
    camera.max.x = 0
    camera:setPosition( 0, 0 )
    
    self.prompt = nil
    
    self:initTable()
    self:dealMenu()
    
    -- temporary, as this is the only place money is earned currently
    if self.money == 0 then
        self.money = 25
        self.bet = 2
    end
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
                self:dealHand()
            elseif self.selected == 'HIT' then
                if not self.cards_moving then self:hit() end
            elseif self.selected == 'STAND' then
                if not self.cards_moving then self:stand() end
            elseif self.selected == 'BET +' then
                if self.bet < self.money then self.bet = self.bet + 1 end
            elseif self.selected == 'BET -' then
                if self.bet > 1 then self.bet = self.bet - 1 end
            end
        end
        
        if key == ' ' then
            self.money = self.money + 1
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

function state:gameMenu()
        -- fix the menu
        self.selection = 0                  -- deal
        self.options[ 1 ].active = true     -- hit
        self.options[ 2 ].active = true     -- stand
        self.options[ 3 ].active = false    -- deal
        self.options[ 4 ].active = false    -- bet
        self.options[ 5 ].active = false    -- bet
end

function state:dealMenu()
        -- fix the menu
        self.selection = 2                  -- deal
        self.options[ 1 ].active = false    -- hit
        self.options[ 2 ].active = false    -- stand
        self.options[ 3 ].active = true     -- deal
        self.options[ 4 ].active = true     -- bet
        self.options[ 5 ].active = true     -- bet
end

function state:update(dt)
    timer.update(dt)
    if self.prompt then self.prompt:update(dt) end
    self.cards_moving = self:update_cards( self.player_cards, self.dealer_cards, dt )
    self.selected = self.options[ self.selection + 1 ].name
end

function state:update_cards( plyr, delr, dt )
    if plyr and delr then
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
            end
        end
        if not moved and self.card_complete_callback then
            self.card_complete_callback()
        end
    end
    return moved
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

function state:initTable()
    -- clear everyones cards
    self.dealer_cards = {}
    self.player_cards = {}
    
    -- make a new deck
    self.deck = newDeck( self.decks_to_use )
    
    -- no scores yet
    self.dealer_hand = nil
    self.player_hand = nil
    
    self.player_done = false
    self.dealer_done = false
    
    self.outcome = nil
end

function state:dealHand()
    self:initTable()
    
    -- deal first 4 cards
    self:dealCard( 'player' )
    self:dealCard( 'dealer' )
    self:dealCard( 'player' )
    self:dealCard( 'dealer' )
    
    self:gameMenu()
    
    --check for 21
    if self:bestScore( self.player_hand ) == 21 then
        self:stand()
    end
end

function state:dealCard( to )
    deal_card = table.remove( self.deck, 1 )
    x = 266
    face_up = true
    tbl = self.player_cards
    y = 140
    if to == 'dealer' then
        -- second card is not shown
        if #self.dealer_cards == 1 then
            face_up = false
            -- when drawing complete, peek at the card and check for blackjack
            self.card_complete_callback = function()
                self.card_complete_callback = nil
                if ( self.dealer_cards[1].card == 1 and self.dealer_cards[2].card >= 10 ) or
                   ( self.dealer_cards[1].card >= 10 and self.dealer_cards[2].card == 1 ) then
                    self:stand()
                end
            end
        end
        tbl = self.dealer_cards
        y = 37
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

    if to == 'dealer' then 
        self:updateScore( self.dealer_cards )
    else
        self:updateScore( self.player_cards )
    end

    -- adjust widths when we've run out of room
    if #tbl * self.width_per_card >= self.max_card_room then
        new_width = self.max_card_room / #tbl
        for i,n in pairs( tbl ) do
            -- no idea why I need this hocus pocus, but it seems to work
            n.x = x - math.floor( ( new_width - 2 ) * ( i - 1 ) )
        end
    end
end

function state:hit()
    -- throw a card
    self:dealCard( 'player' )
    -- bust or still alive?
    self.card_complete_callback = function()
        self.card_complete_callback = nil
        _alive = false
        if self:bestScore( self.player_hand ) < 21 then
            _alive = true
        end
        if not _alive then
            self:stand()
        end
    end
end

function state:stand()
    self.player_done = true
    
    -- if not a bust or blackjack, play out the dealers hand
    if self:bestScore( self.player_hand ) < 21 then
        while self:bestScore( self.dealer_hand ) < 17 do
            if not self.dealer_cards[ 2 ].face_up then
                self.dealer_cards[ 2 ].face_up = true
                self:updateScore( self.dealer_cards )
            else
                self:dealCard( 'dealer' )
            end
        end
    else
        --flip the dealer over and move on
        self.dealer_cards[ 2 ].face_up = true
        self:updateScore( self.dealer_cards )
    end
    
    self.card_complete_callback = function()
        self.card_complete_callback = nil
        
        self.dealer_done = true

        -- determine win, loss, push
        -- allocate winnings accordingly
        if self:bestScore( self.player_hand ) == 21 and #self.player_cards == 2
            and self:bestScore( self.dealer_hand ) ~= 21 then
            -- player got blackjack!
            self.money = self.money + ( self.bet * 2 )
            self.outcome = 'You have Blackjack!\nYou Win!'
        elseif self:bestScore( self.dealer_hand ) == 21 and #self.dealer_cards == 2
            and self:bestScore( self.player_hand ) ~= 21 then
            -- dealer got blackjack!
            self.money = self.money - self.bet
            self.outcome = 'Dealer has Blackjack.\nYou Lose.'
        elseif self:bestScore( self.dealer_hand ) == 22 then
            -- dealer bust, player wins
            self.money = self.money + self.bet
            self.outcome = 'Dealer busted.\nYou Win!'
        elseif self:bestScore( self.player_hand ) == 22 then
            -- player pust, player loses
            self.money = self.money - self.bet
            self.outcome = 'Busted. You Lose.'
        elseif self:bestScore( self.dealer_hand ) == self:bestScore( self.player_hand ) then
            -- push, no winner
            self.outcome = 'It\'s a push.'
        elseif self:bestScore( self.dealer_hand ) < self:bestScore( self.player_hand ) then
            -- player beat dealer, player wins
            self.money = self.money + self.bet
            self.outcome = 'You Win!'
        else
            -- player lost to dealer, player loses
            self.money = self.money - self.bet
            self.outcome = 'You Lost.'
        end
        
        if self.money == 0 then
            self:gameOver()
        end
        
        if self.money < self.bet then
            self.bet = self.money
        end

        self:dealMenu()
        
    end
end

function state:gameOver()
    self.prompt = Dialog.new( 120, 55, "Game Over.", function(result)
        Gamestate.switch(self.previous)
    end )
end

function state:bestScore( tbl )
    -- scores should be sorted
    _best = 22
    for _,v in pairs( tbl ) do
        if v <= 21 then
            _best = v
        end
    end
    return _best
end

function state:updateScore( tbl )
    score = {}
    for i,n in pairs( tbl ) do
        if n.face_up then
            if n.card == 1 then -- ace
                points = { 1, 11 }
            elseif n.card > 10 then -- face
                points = { 10 }
            else
                points = { n.card }
            end
            score = self:addPointsToScore( points, score )
        end
    end
    if tbl == self.dealer_cards then
        self.dealer_hand = score
    else
        self.player_hand = score
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
    last = nil
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
    
    if self.dealer_cards then
        for i,n in pairs( self.dealer_cards ) do
            self:drawCard(
                n.card, n.suit,                                                    -- card / suit
                map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y )    -- y
            )
        end
    end

    if self.player_cards then
        for i,n in pairs( self.player_cards ) do
            self:drawCard(
                n.card, n.suit,                                                    -- card / suit
                map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y )    -- y
            )
        end
    end
    
    for i,n in pairs( self.options ) do
        local x = self.options_x
        local y = self.options_y + ( i * 15 )
        co = 0 -- color offset
        if not n.active then co = 180 end
        if i == self.selection + 1 then
            love.graphics.setColor( 255, 255, 255, 255 )
            love.graphics.draw( self.options_arrow, x - 5, y + 4 )
            co = 255
        end
        love.graphics.setColor( 255 - co, 255 - co, 255 - co )
        love.graphics.print( n.name, x + 3, y + 3, 0, 0.5 )
    end
    love.graphics.setColor( 255, 255, 255, 255 )
    
    cx = 0 -- chip offset x
    for color,count in pairs( getChipCounts( self.money ) ) do
        cy = 0 -- chip offset y
        -- draw full stacks first
        for s = 1, math.floor( count / 5 ), 1 do
            for i = 0, 4, 1 do
                love.graphics.drawq( self.chipSprite, self.chips[ color ], self.chip_x + cx - i, self.chip_y + cy - i )
            end
            -- change the coords
            if s % 2 == 0 then --odd
                cy = 0
                cx = cx + 12
            else --even
                cy = 12
            end
        end
        for i = 0, count % 5 - 1, 1 do
             love.graphics.drawq( self.chipSprite, self.chips[ color ], self.chip_x + cx - i, self.chip_y + cy - i )
        end
        if count > 0 then cx = cx + 18 end
    end
    
    if self.dealer_done then
        _score = self:bestScore( self.dealer_hand )
        if _score == 22 then
            love.graphics.print( "BUST", 315, 60, 0, 0.5 )
        else
            love.graphics.print( _score, 321, 60, 0, 0.5 )
        end
    end
    if self.player_done then
        _score = self:bestScore( self.player_hand )
        if _score == 22 then
            love.graphics.print( "BUST", 315, 163, 0, 0.5 )
        else
            love.graphics.print( _score, 321, 163, 0, 0.5 )
        end
    end
    
    if self.outcome then
        love.graphics.print( self.outcome, 200, 112, 0, 0.5 )
    end
    
    if self.prompt then
        self.prompt:draw( self.center_x, self.center_y )
    end
    
    love.graphics.print( 'On Hand\n $ ' .. self.money, 80, 213, 0, 0.5 )
    
    love.graphics.print( 'Bet $ ' .. self.bet , 315, 112, 0, 0.5 )

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
    darkness = map( flip, 50, limit, 100, 255 )
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

function getChipCounts( amount )
    _c = { 0, 0, 0, 0, 0 } -- chip stacks
    _min = { 0, 5, 15, 15, 15 } -- min stacks per denomination
    _amt = { 100, 25, 10, 5, 1 } -- value of each denomination
    -- build out the min stacks first, then the rest
    for x = 5, 1, -1 do
        --take up to _min[x] off the amount
        if amount < ( _min[x] * _amt[x] ) then
            _c[x] = math.floor( amount / _amt[x] )
            amount = amount - ( _c[x] * _amt[x] )
        else
            _c[x] = _min[x]
            amount = amount - ( _min[x] * _amt[x] )
        end
    end
    _c[1] = _c[1] + math.floor( amount / 100 )
        amount = amount - ( math.floor( amount / 100 ) * 100 )
    _c[2] = _c[2] + math.floor( amount / 25 )
        amount = amount - ( math.floor( amount / 25 ) * 25 )
    _c[3] = _c[3] + math.floor( amount / 10 )
        amount = amount - ( math.floor( amount / 10 ) * 10 )
    _c[4] = _c[4] + math.floor( amount / 5 )
        amount = amount - ( math.floor( amount / 5 ) * 5 )
    _c[5] = _c[5] + math.floor( amount / 1 )
    return _c
end

return state