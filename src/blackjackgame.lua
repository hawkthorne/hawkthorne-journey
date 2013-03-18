local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local window = require 'window'
local fonts = require 'fonts'
local timer = require 'vendor/timer'
local Prompt = require 'prompt'
local Dialog = require 'dialog'
local camera = require 'camera'
local state = Gamestate.new()
local sound = require 'vendor/TEsound'
local cardutils = require 'cardutils'

function state:init( )
    self.table = love.graphics.newImage( 'images/cards/card_table_blackjack.png' )

    self.cardSprite = love.graphics.newImage('images/cards/cards.png' )
    self.card_width = 38
    self.card_height = 55
    self.cardbacks = 6

    self.chipSprite = love.graphics.newImage('images/cards/chips.png' )
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

    self.max_card_room = 227
    self.width_per_card = 45

    self.decks_to_use = 8

    self.card_speed = 0.5
    self.current_splits = 0
    self.activeHandNum = 1


    self.options_arrow = love.graphics.newImage( 'images/menu/tiny_arrow.png' )
    self.options = {
        { name = 'HIT', action = 'hit' },
        { name = 'STAND', action = 'stand' },
        { name = 'DOUBLE', action = 'double_down' },
        { name = 'SPLIT', action = 'split' },
        { name = 'DEAL', action = 'deal' },
        { name = 'BET +', action = 'bet_up' },
        { name = 'BET -', action = 'bet_down' },
        { name = 'QUIT', action = 'quit', active = true },
    }
    self.selection = 4

    self.player_bets={}
    self.player_bets[1] = 2
    
end

function state:enter(previous, player, screenshot)
    sound.playMusic( "tavern" )
    --lazy because i want to reset all position data
    fonts.set( 'big' )

    self.previous = previous
    self.screenshot = screenshot

    self:initTable()
    self:dealMenu()

    self.player = player

    self.cardback_idx = math.random( self.cardbacks ) - 1

    self.cardback = love.graphics.newQuad( self.cardback_idx * self.card_width, self.card_height * 4, self.card_width, self.card_height, self.cardSprite:getWidth(), self.cardSprite:getHeight() )

    self.chip_x = 168 + camera.x
    self.chip_y = 237 + camera.y

    self.center_x = ( window.width / 2 ) + camera.x
    self.center_y = ( window.height / 2 ) + camera.y
    self.dealer_stack_x = 386 + camera.x
    self.dealer_stack_y = 66 + camera.y

    self.dealer_result_pos_x = 346 + camera.x
    self.dealer_result_pos_y = 89 + camera.y
    
    self.outcome_pos_x = 225 + camera.x
    self.outcome_pos_y = 141 + camera.y

    self.options_x = 395 + camera.x
    self.options_y = 145 + camera.y
    self.selection = 4
    self.player_bets={}
    self.player_bets[1] = 2
    
    
end

function state:leave()
    fonts.reset()
    -- camera.x = self.camera_x
end

function state:keypressed( button, player )

        if button == 'JUMP' and self.selected == 'QUIT' then
            Prompt.new("Are you sure you want to exit?", function(result)
                if result == 'Yes' then
                    Gamestate.switch(self.previous)
                else
                    Prompt.currentDialog = nil
                end
            end )
        end

        if button == 'JUMP' then
            if self.selected == 'DEAL' then
                self:dealHand()
            elseif self.selected == 'HIT' then
                if not self.cards_moving then self:hit() end
            elseif self.selected == 'STAND' then
                if not self.cards_moving then self:stand() end
            elseif self.selected == 'DOUBLE' then
                if not self.cards_moving then self:double() end
            elseif self.selected == 'SPLIT' then
                if not self.cards_moving then self:split() end
            elseif self.selected == 'BET +' then
                if self.player_bets[1] < self.player.money then self.player_bets[1] = self.player_bets[1] + 1 end
            elseif self.selected == 'BET -' then
                if self.player_bets[1] > 1 then self.player_bets[1] = self.player_bets[1] - 1 end
            end
        end

        if button == 'UP' then
            repeat
                self.selection = (self.selection - 1) % #self.options
            until self.options[ self.selection + 1 ].active
        elseif button == 'DOWN' then
            repeat
                self.selection = (self.selection + 1) % #self.options
            until self.options[ self.selection + 1 ].active
        end

end

function state:gameMenu()
        -- fix the menu
        self.selection = 0                          -- hit
        self.options[ 1 ].active = true             -- hit
        self.options[ 2 ].active = true             -- stand
        if self.player_bets[1] < self.player.money then
            self.options[ 3 ].active = true         -- double
        else
            self.options[ 3 ].active = false        -- double
        end
        if self.player_bets[1] < self.player.money and 
           self.current_splits < 1 and 
           self.player_cards[self.activeHandNum][1].card==self.player_cards[self.activeHandNum][2].card then
               self.options[ 4 ].active = true      -- split
        else
            self.options[ 4 ].active = false        -- split
        end
        self.options[ 5 ].active = false            -- deal
        self.options[ 6 ].active = false            -- bet
        self.options[ 7 ].active = false            -- bet
end

function state:dealMenu()
        -- fix the menu
        self.selection = 4                          -- deal
        self.options[ 1 ].active = false            -- hit
        self.options[ 2 ].active = false            -- stand
        self.options[ 3 ].active = false            -- double
        self.options[ 4 ].active = false            -- split
        self.options[ 5 ].active = true             -- deal
        self.options[ 6 ].active = true             -- bet
        self.options[ 7 ].active = true             -- bet
end

function state:update(dt)
    self.cards_moving = self:update_cards( self.player_cards, self.dealer_cards, dt )    
    self.selected = self.options[ self.selection + 1 ].name
end
--fix it
function state:update_cards( plyr, delr, dt )
    curPlyr = plyr[self.activeHandNum]
    if curPlyr and delr then
        max = math.max( #curPlyr, #delr )
        moved = false
        for i = 1, max, 1 do
            if not moved then
                if curPlyr[i] then
                    moved = self:move_card( curPlyr[i], dt )
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
    self.player_cards = {} --multidimensional array of cards

    -- make a new deck
    self.deck = cardutils.newDeck( self.decks_to_use )

    -- no scores yet
    self.dealer_hand = nil
    self.player_hands = {}
    _myBet = self.player_bets[1]
    self.player_bets = {}
    self.player_bets[1] = _myBet

    self.player_done = false
    self.dealer_done = false

    self.outcome = nil
end

function state:dealHand()
    self:initTable()

    self.player_cards[1]={}
    self.original_bet = self.player_bets[1]
    -- deal first 4 cards
    self:dealCard( 'player' ,1)
    self:dealCard( 'dealer' ,0) --should always be zero
    self:dealCard( 'player' ,1)
    self:dealCard( 'dealer' ,0) --should always be zero

    self:gameMenu()
    
    if self.player_cards[self.activeHandNum][1].card==self.player_cards[self.activeHandNum][2].card then
       self.options[ 4 ].active = true     -- split
    else
       self.options[ 4 ].active = false     -- split
    end
    

    if self:bestScore( self.player_hands[1]) == 21 then
    --check for 21
        self:stand()
    end
end

--handNum indicates current hand in split
function state:dealCard( to)
    deal_card = table.remove( self.deck, 1 )
    
    x = 293 + camera.x
    face_up = true
    hand = self.player_cards[ self.activeHandNum ]
    
    y = 169 + ( self.activeHandNum - 1 ) * 9 + camera.y
    
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
        hand = self.dealer_cards
        y = 66 + camera.y
    end
    table.insert(
        hand,
        {
            card = deal_card.card,
            suit = deal_card.suit,
            x = x - ( self.width_per_card * #hand ),
            y = y,
            move_idx = 0,
            flip_idx = 0,
            face_up = face_up
        }
    )

    if to == 'dealer' then
        self:updateScore( self.dealer_cards)
    else
        self:updateScore( self.player_cards)
    end
    

    -- adjust widths when we've run out of room
    if #hand * self.width_per_card >= self.max_card_room then
        new_width = self.max_card_room / #hand
        for i,n in pairs( hand ) do
            -- no idea why I need this hocus pocus, but it seems to work
            n.x = x - math.floor( ( new_width - 2 ) * ( i - 1 ) )
        end
    end
end

function state:hit()
    if #self.player_cards[self.activeHandNum] > 1 then
        self.options[ 3 ].active = false     -- disable doubling
    end

    self.options[ 4 ].active = false     -- disable splitting

    -- throw a card
    self:dealCard( 'player' )
    -- bust or still alive?
    self.card_complete_callback =function()
        self.card_complete_callback = nil
        _alive = false
        if self:bestScore( self.player_hands[self.activeHandNum] ) < 21 then
            _alive = true
        end
        if not _alive then
            self:stand()
        end
    end
end

function state:double()
    -- double bet
    self.player_bets[ self.activeHandNum ] = self.player_bets[ self.activeHandNum ] * 2

    -- throw a card
    self:dealCard( 'player' )

    -- stand
    self.card_complete_callback =function()
        self.card_complete_callback = nil
        self:stand()
    end

end

function state:split()
    self.selection = 0 -- hit

    --split stub
    self.current_splits = self.current_splits + 1;

    --add a new hand
    newHandNum = self.current_splits + 1;

    --reallocate money
    self.player_bets[newHandNum] = self.player_bets[newHandNum-1]

    --move 2nd card to new row
    self.player_cards[newHandNum] = {}
    self.player_cards[newHandNum][1] = self.player_cards[1][newHandNum]
    self.player_cards[newHandNum][1].y = 169 + camera.y + ( newHandNum - 1 ) * 9
    self.player_cards[newHandNum][1].x = self.player_cards[1][1].x

    self.player_cards[1][2] = nil

    --deal cards
    self.activeHandNum=newHandNum-1
    self:hit();
end

function state:stand()
    if self.current_splits == self.activeHandNum then
        self.activeHandNum = self.activeHandNum + 1
        self:hit()
        return
    end
    
    self.player_done = true
    self.current_splits = 0
    self.activeHandNum = 1

    -- if not a bust or blackjack, play out the dealers hand
    doPlayDealer=false;
    for curHandNum=1,#self.player_bets do
        if self:bestScore( self.player_hands[curHandNum] ) < 21 then
            doPlayDealer = true
            break
        end
    end

    if doPlayDealer then
        while self:bestScore( self.dealer_hand ) < 17 do
            if not self.dealer_cards[ 2 ].face_up then
                self.dealer_cards[ 2 ].face_up = true
                self:updateScore( self.dealer_cards)
            else
                self:dealCard( 'dealer' )
            end
        end
    else
        --flip the dealer over and move on
        self.dealer_cards[ 2 ].face_up = true
        self:updateScore( self.dealer_cards, 0 )
    end

    self.card_complete_callback = function()
        self.card_complete_callback = nil
        self.dealer_done = true

        for curHandNum=1,#self.player_bets do

        -- determine win, loss, push
        -- allocate winnings accordingly
        if self:bestScore( self.player_hands[curHandNum] ) == 21 and #self.player_cards[curHandNum] == 2
            and self:bestScore( self.dealer_hand ) ~= 21 then
            -- player got blackjack!
            self.player.money = self.player.money + ( self.player_bets[curHandNum] * 2 )
            self.outcome = 'You have Blackjack!\nYou Win!'
        elseif self:bestScore( self.dealer_hand ) == 21 and #self.dealer_cards == 2
            and self:bestScore( self.player_hands[1] ) ~= 21 then
            -- dealer got blackjack!
            self.player.money = self.player.money - self.player_bets[curHandNum]
            self.outcome = 'Dealer has Blackjack.\nYou Lose.'
        elseif self:bestScore( self.dealer_hand ) == 22 then
            -- dealer bust, player wins
            self.player.money = self.player.money + self.player_bets[curHandNum]
            self.outcome = 'Dealer busted.\nYou Win!'
        elseif self:bestScore( self.player_hands[curHandNum] ) == 22 then
            -- player pust, player loses
            self.player.money = self.player.money - self.player_bets[curHandNum]
            self.outcome = 'Busted. You Lose.'
        elseif self:bestScore( self.dealer_hand ) == self:bestScore( self.player_hands[curHandNum] ) then
            -- push, no winner
            self.outcome = 'It\'s a push.'
        elseif self:bestScore( self.dealer_hand ) < self:bestScore( self.player_hands[curHandNum] ) then
            -- player beat dealer, player wins
            self.player.money = self.player.money + self.player_bets[curHandNum]
            self.outcome = 'You Win!'
        else
            -- player lost to dealer, player loses
            self.player.money = self.player.money - self.player_bets[curHandNum]
            self.outcome = 'You Lost.'
        end

    end
        if self.player.money == 0 then
            self:gameOver()
        end
        
        self.player_bets[1] = self.original_bet
        
        if self.player.money < self.player_bets[1] then
            self.player_bets[1] = self.player.money
        end

        self:dealMenu()

    end
end

function state:gameOver()
    Dialog.new("Game Over.", function(result)
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

function state:scoreCounter(tbl)
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
    return score
end

function state:updateScore( tbl )
    score = {}
    if tbl == self.dealer_cards then
        score = self:scoreCounter(tbl);
        self.dealer_hand = score
    else
        score = self:scoreCounter(tbl[self.activeHandNum]);
        self.player_hands[self.activeHandNum] = score
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
        love.graphics.draw( self.screenshot, camera.x, camera.y, 0, window.width / love.graphics:getWidth(), window.height / love.graphics:getHeight() )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    love.graphics.draw( self.table, self.center_x - ( self.table:getWidth() / 2 ), self.center_y - ( self.table:getHeight() / 2 ) )

    --dealer stack
    love.graphics.drawq( self.cardSprite, self.cardback, self.dealer_stack_x, self.dealer_stack_y )

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

    for idx = 1, #self.player_cards do
    if self.player_cards[idx] then
        for i,n in pairs( self.player_cards[idx] ) do
            self:drawCard(
                n.card, n.suit,                                                    -- card / suit
                map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y ),   -- y
                idx ~= self.activeHandNum and not self.player_done
            )
        end
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
    for color,count in pairs( cardutils.getChipCounts( self.player.money ) ) do
        cy = 0 -- chip offset y ( start at top )
        -- draw full stacks first
        for s = 1, math.floor( count / 5 ), 1 do
            for i = 0, 4, 1 do
                love.graphics.drawq( self.chipSprite, self.chips[ color ], self.chip_x + cx - i, self.chip_y + cy - i )
            end
            -- change the coords
            if s % 2 == 0 then --even
                cy = 0 --top
                cx = cx + self.chip_width --shift over
            else --odd
                cy = self.chip_height --bottom
            end
        end
        for i = 0, count % 5 - 1, 1 do
             love.graphics.drawq( self.chipSprite, self.chips[ color ], self.chip_x + cx - i, self.chip_y + cy - i )
        end
        -- shift the drawpoint left for the next stack
        if count > 0 then -- something was actually drawn
            if count % 5 == 0 and cy == 0 then
                cx = cx + 4
            else
                cx = cx + self.chip_width + 4
            end
        end
    end

    if self.dealer_done then
        _score = self:bestScore( self.dealer_hand )
        if _score == 22 then
            love.graphics.print( "BUST", self.dealer_result_pos_x, self.dealer_result_pos_y, 0, 0.5 )
        else
            love.graphics.print( _score, self.dealer_result_pos_x + 7, self.dealer_result_pos_y, 0, 0.5 )
        end
    end

    --fix
    if self.player_done then
      for i=1,#self.player_hands do
        _score = self:bestScore( self.player_hands[i] )
        if _score == 22 then
            love.graphics.print( "BUST", self.dealer_result_pos_x, self.dealer_result_pos_y +101+(i-1)*14, 0, 0.5 )
        else
            love.graphics.print( _score, self.dealer_result_pos_x + 7, self.dealer_result_pos_y +101+(i-1)*14, 0, 0.5 )
        end
      end
    end

    if self.outcome then
        love.graphics.print( self.outcome, self.outcome_pos_x, self.outcome_pos_y, 0, 0.5 )
    end

    --FIXME: remember to add this to global dialog
    --self.prompt:draw( self.center_x, self.center_y )

    love.graphics.print( 'On Hand\n $ ' .. self.player.money, 110+camera.x, 244+camera.y, 0, 0.5 )
    
    love.graphics.print( 'Bet $ ' .. self.player_bets[1], 361+camera.x, 141+camera.y, 0, 0.5 )

    love.graphics.setColor( 255, 255, 255, 255 )
end

function state:drawCard( card, suit, flip, x, y, overlay )
    -- flip is a number from 0 to 100, where 0 is completely face down, and 100 is completely face up
    local w = self.card_width   -- card width
    local h = self.card_height  -- card height
    local st = 0.2              -- stretched top
    local sh = h * ( 1 + st )   -- stretched height
    local limit
    if flip > 50 then
        limit = 100
        _card = love.graphics.newQuad( ( card - 1 ) * w, ( suit - 1 ) * h, w, h, self.cardSprite:getWidth(), self.cardSprite:getHeight() )
    else
        limit = 0
        _card = self.cardback
    end
    darkness = map( flip, 50, limit, 100, 255 )
    if(overlay) then
        darkness = 150
    end
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

return state
