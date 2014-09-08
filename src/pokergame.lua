local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local window = require 'window'
local fonts = require 'fonts'
local timer = require 'vendor/timer'
local Prompt = require 'prompt'
local Dialog = require 'dialog'
local camera = require 'camera'
local utils = require 'utils'
local state = Gamestate.new()
local sound = require 'vendor/TEsound'
local cardutils = require 'cardutils'

function state:init()
    self.table = love.graphics.newImage( 'images/cards/card_table_poker.png' )

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

    self.card_queue = {}

    self.max_card_room = 227
    self.width_per_card = 45
    
    -- to avoid crazy poker hands
    self.decks_to_use = 1
    
    self.card_speed = 0.5
    
    self.options_arrow = love.graphics.newImage( 'images/menu/tiny_arrow.png' )

    self.options = {
        { name = 'DRAW', action = 'poker_draw' },
        { name = 'DEAL', action = 'deal_hand' },
        { name = 'BET +', action = function() 
            if (self.bet < self.player.money and self.bet < 15) then 
                self.bet = self.bet + 1
            elseif (self.bet < self.player.money - 5 and self.bet < 50) then
                self.bet = self.bet + 5
            elseif (self.bet < self.player.money - 10 and self.bet < 100) then
                self.bet = self.bet + 10
            elseif (self.bet < self.player.money - 25 and self.bet < 250) then
                self.bet = self.bet + 25
            elseif (self.bet < self.player.money - 100) then
                self.bet = self.bet + 100
            else
                self.bet = self.player.money      
            end 
        end },
        { name = 'BET -', action = function() 
            if (self.bet > 250 and (self.bet -250)%100 ~= 0) then
                self.bet = self.bet - (self.bet - 250)%100
            elseif self.bet > 250 then
                self.bet = self.bet - 100
            elseif self.bet > 125 then
                self.bet = self.bet - 25
            elseif self.bet > 100 then
                self.bet = 100
            elseif self.bet > 60 then
                self.bet = self.bet - 10
            elseif self.bet > 50 then
                self.bet = 50
            elseif self.bet > 20 then
                self.bet = self.bet - 5
            elseif self.bet > 15 then
                self.bet = 15
            elseif self.bet > 1 then
                self.bet = self.bet - 1 
            end 
        end },
        { name = 'QUIT', action = 'quit', active = true },
    }
    self.selection = 2

    -- overwritten in enter(..)
    self.bet = 2

    self.horizontal_selection = 0
end

function state:enter(previous, player, screenshot)
    sound.playMusic( "tavern" )

    self.previous = previous
    self.screenshot = screenshot

    self.prompt = nil
    
    self.player = player
    
    self:init_table()
    self:deal_menu()
    
    self.cardback_idx = math.random( self.cardbacks ) - 1
    
    self.cardback = love.graphics.newQuad( self.cardback_idx * self.card_width, self.card_height * 4, self.card_width, self.card_height, self.cardSprite:getWidth(), self.cardSprite:getHeight() )


    self.chip_x = 138+36 + camera.x
    self.chip_y = 208+33 + camera.y
    
    self.center_x = ( window.width / 2 ) + camera.x
    self.center_y = ( window.height / 2 ) +  camera.y
    self.dealer_stack_x = 356+36 + camera.x
    self.dealer_stack_y = 37+33 + camera.y

    self.options_x = 360+36 + camera.x
    self.options_y = 135+33 + camera.y
    self.selection = 2

    -- Don't allow the player to bet more money than they have
    if self.player.money > 1 then
        self.bet = 2
    else
        self.bet = 1
    end

    self.horizontal_selection = 0
end

function state:keypressed( button, player )
    if self.prompt then
        self.prompt:keypressed( button )
    else
        if button == 'JUMP' then
            if(self.horizontal_selection == 0) then
                local action = self.options[self.selection + 1].action
                if(type(action) == 'string') then
                    self[action](self)
                else --function
                    action()
                end
            else
                self.player_cards[self.horizontal_selection].raised = not self.player_cards[self.horizontal_selection].raised
            end
        end

        if self.options[1].active then
            if button == 'LEFT' then
                self.horizontal_selection = (self.horizontal_selection + 1) % 6
            elseif button == 'RIGHT' then
                self.horizontal_selection = (self.horizontal_selection - 1) % 6
            end
        end

        -- make sure the game menu is selected
        if self.horizontal_selection == 0 then
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
    end
end

function state:game_menu()
        -- fix the menu
        self.selection = 0                  
        self.options[ 1 ].active = true     
        self.options[ 2 ].active = false    
        self.options[ 3 ].active = false    
        self.options[ 4 ].active = false
        self.horizontal_selection = 1
end

function state:deal_menu()
        -- fix the menu
        self.selection = 1                  
        self.options[ 1 ].active = false    
        self.options[ 2 ].active = true     
        self.options[ 3 ].active = true     
        self.options[ 4 ].active = true
        self.horizontal_selection = 0
end

function state:no_menu()
        -- fix the menu
        self.selection = 4                
        self.options[ 1 ].active = false    
        self.options[ 2 ].active = false     
        self.options[ 3 ].active = false    
        self.options[ 4 ].active = false    
        self.horizontal_selection = 0
end

function state:update(dt)
    self.cards_moving = self:update_cards(dt)
end

function state:update_cards(dt)
    if(#self.card_queue > 0 and self.card_queue.asynchronous) then
        moves = {}
        for i = 1, #self.card_queue do
            table.insert(moves, self:move_card( self.card_queue[i], dt ))
        end
        for i = #self.card_queue, 1 do
            if(not moves[i]) then
                table.remove(moves, i)
            end
        end
    elseif(#self.card_queue > 0) then
        if not self:move_card( self.card_queue[1], dt ) then
            table.remove(self.card_queue, 1)
        end
    else
        if self.card_complete_callback then
            self.card_complete_callback()
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

function state:init_table()
    -- clear everyones cards
    self.dealer_cards = {}
    self.player_cards = {}
    self.dealer_hand = nil
    self.player_hand = nil

    self.card_queue.asynchronous = false

    -- make a new deck
    self.deck = cardutils.newDeck( self.decks_to_use )
    
    self.outcome = nil
end

function state:deal_hand()
    self:init_table()
    
    self:no_menu()
    
    self.card_complete_callback = function()
        self.card_complete_callback = nil
        self:game_menu()
        pick_to_trade(self.dealer_cards)
    end

    -- deal first 5 cards
    for i=1, 5 do
        self:deal_card( 'player' )
        self:deal_card( 'dealer' )
    end

end

-- Handles the user selecting the 'Quit' option
function state:quit()
    self.prompt = Prompt.new("Are you sure you want to exit?", function(result)
        if result == 'Yes' then
            self.card_complete_callback = nil
            Gamestate.switch(self.previous)
        else
            self.prompt = nil
        end
    end )
    return
end

function state:poker_draw()
    self:no_menu()
    
    self.card_complete_callback = function()
        self.card_complete_callback = nil
        self:deal_menu()
        for _, card in pairs(self.dealer_cards) do
            card.face_up = true
            table.insert(self.card_queue, card)
            self.card_queue.asynchronous = true
        end
        self.player_hand = evaluate_hand(self.player_cards)
        self.dealer_hand = evaluate_hand(self.dealer_cards)
        
        local comp = compare_hands(self.player_hand, self.dealer_hand)
        if(comp == -1) then
            self.outcome = "You Win!"
            self.player.money = self.player.money + self.bet
        elseif(comp == 1) then
            self.outcome = "Dealer Wins!"
            self.player.money = self.player.money - self.bet
        else
            self.outcome = "Tie!"
        end
        if self.player.money < 1 then
            self.player.money = 0
            self:game_over()
        end
        
        if self.player.money < self.bet then
            self.bet = self.player.money
        end
    end
    
    for i = 1, 5 do
        if self.player_cards[i].raised then
            self.player_cards[i] = nil
            self:deal_card('player')
        end
    end
    for i = 1, 5 do
        if self.dealer_cards[i].raised then
            self.dealer_cards[i] = nil
            self:deal_card('dealer')
        end
    end
    
end

function state:deal_card( to )
    deal_card = table.remove( self.deck, 1 )
    x = 266+33 + camera.x
    face_up = true
    tbl = self.player_cards
    y = 140+33 + camera.y
    if to == 'dealer' then
        -- second card is not shown
       face_up = false
        tbl = self.dealer_cards
        y = 37+33 + camera.y
    end
    index = get_first_nil(tbl) 
    tbl[index] = {
        card = deal_card.card,
        suit = deal_card.suit,
        x = x - ( self.width_per_card * (index - 1) ),
        y = y,
        move_idx = 0,
        flip_idx = 0,
        face_up = face_up
    }
    -- adjust widths when we've run out of room
    if #tbl * self.width_per_card >= self.max_card_room then
        new_width = self.max_card_room / #tbl
        for i,n in pairs( tbl ) do
            -- no idea why I need this hocus pocus, but it seems to work
            n.x = x - math.floor( ( new_width - 2 ) * ( i - 1 ) )
        end
    end
    table.insert(self.card_queue, tbl[index])
end

function state:game_over()
    self.prompt = Dialog.new("Game Over.", function(result)
        Gamestate.switch(self.previous)
    end )
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
    love.graphics.draw( self.cardSprite, self.cardback, self.dealer_stack_x, self.dealer_stack_y )
    
    if self.dealer_cards then
        for i,n in pairs( self.dealer_cards ) do
            self:draw_card(
                n.card, n.suit,                                                    -- card / suit
                utils.map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y ),   -- y
                0
            )
        end
    end

    -- Ensure correct font is set
    fonts.set('big')

    if self.player_cards then
        for i,n in pairs( self.player_cards ) do
            self:draw_card(
                n.card, n.suit,                                                    -- card / suit
                utils.map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y ),    -- y
                n.raised and -10 or 0,
                i == self.horizontal_selection
            )
        end
    end
    
    for i,n in pairs( self.options ) do
        local x = self.options_x
        local y = self.options_y + ( i * 15 )
        co = 0 -- color offset
        if not n.active then co = 180 end
        if i == self.selection + 1 and self.horizontal_selection == 0 then
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
            --print( color, s, s % 2 == 0 )
            for i = 0, 4, 1 do
                love.graphics.draw( self.chipSprite, self.chips[ color ], self.chip_x + cx - i, self.chip_y + cy - i )
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
             love.graphics.draw( self.chipSprite, self.chips[ color ], self.chip_x + cx - i, self.chip_y + cy - i )
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
    
    if self.outcome then
        love.graphics.print( self.outcome, 200+36+camera.x, 112+33+camera.y, 0, 0.5 )
    end
    
    if(self.player_hand and self.dealer_hand) then
        x = 80+36 + camera.x
        love.graphics.print( self.dealer_hand.hand.friendly_name, x, 97+33+camera.y, 0, 0.5)
        love.graphics.print( self.player_hand.hand.friendly_name, x, 128+33+camera.y, 0, 0.5 )
    end

    love.graphics.print( 'On Hand\n $ ' .. self.player.money, 80+36 + camera.x, 213+33+camera.y, 0, 0.5 )

    love.graphics.print( 'Bet $ ' .. self.bet , 315+36+camera.x, 112+33+camera.y, 0, 0.5 )

    love.graphics.setColor( 255, 255, 255, 255 )

    -- Ensure font is reverted
    fonts.revert()
end

function state:draw_card( card, suit, flip, x, y, offset, overlay )
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
    darkness = utils.map( flip, 50, limit, 100, 255 )
    if(overlay) then
        darkness = 150
    end
    love.graphics.setColor( darkness, darkness, darkness )
    love.graphics.draw(
        self.cardSprite, _card,                             -- image, quad
        x + utils.map( flip, 50, limit, w / 2, 0 ),               -- offset for flip
        utils.map( flip, 50, limit, y - ( ( sh - h ) / 2 ), y ) + offset,  -- height offset
        0,                                                  -- no rotation
        utils.map( flip, 50, limit, 0, 1 ),                       -- scale width for flip
        utils.map( flip, 50, limit , 1 + st, 1 )                  -- scale height for flip
    )

    love.graphics.setColor( 255, 255, 255, 255 )
end

function get_first_nil(t)
    for i = 1, #t do
        if(t[i] == nil) then
            return i
        end
    end
    return #t + 1
end

function evaluate_hand(hand)
    
    card_to_text = {
        {'Ace', 'Aces'},
        {'Two', 'Twos'},
        {'Three', 'Threes'},
        {'Four', 'Fours'},
        {'Five', 'Fives'},
        {'Six', 'Sixes'},
        {'Seven', 'Sevens'},
        {'Eight', 'Eights'},
        {'Nine', 'Nines'},
        {'Ten', 'Tens'},
        {'Jack', 'Jacks'},
        {'Queen', 'Queens'},
        {'King', 'Kings'},
        {'Ace', 'Aces'}
    }

    HIGH_CARD = {value = 0, name = "High Card", format_string = "High Card: %s"}
    PAIR = {value = 1, name = "Pair", format_string = "Pair of %s"}
    TWO_PAIR = {value = 2, name = "Two Pair", format_string = "Two Pair: %s and %s"}
    THREE_OF_A_KIND = {value = 3, name = "Three of a Kind", format_string = "Three %s"}
    STRAIGHT = {value = 4, name = "Straight", format_string = "%s High Straight"}
    FLUSH = {value = 5, name = "Flush", friendly_name = "Flush"}
    FULL_HOUSE = {value = 6, name = "Full House", format_string = "%s Full of %s"}
    FOUR_OF_A_KIND = {value = 7, name = "Four of a Kind", format_string = "Four %s"}
    STRAIGHT_FLUSH = {value = 8, name = "Straight Flush", format_string = "%s High Straight Flush"}
    ROYAL_FLUSH = {value = 9, name = "Royal Flush", friendly_name = "Royal Flush"}
    
    suits = nil
    values = {}
    straight = true
    flush = true
    return_value = {}
    sorted_hand = {}
    min = 1
    max = 14
    has_ace = false
    local suit = nil
    for _, card in pairs(hand) do
        if(not suit) then
            suit = card.suit
        elseif(suit ~= card.suit) then
            flush = false
        end    
        
        values[card.card] = (values[card.card] or 0) + 1
        if(values[card.card] > 1) then
            straight = false
        end
        
        table.insert(sorted_hand, card.card == 1 and 14 or card.card)
        
        if card.card == 1 then
            has_ace = true
        elseif straight then
            if card.card <= max and card.card >= min then
                min = card.card - 4 >= min and card.card - 4 or min
                max = card.card + 4 <= max and card.card + 4 or max
            else
                straight = false
            end
        end
    end
    
    if straight and has_ace and  (not (min == 1 or max == 14)) then
        straight = false
    end
    
    utils.reverse_sort(sorted_hand)
    
    if straight then        
        return_value.straight = true
        return_value[1] = max
        
        if flush and return_value[1] == 14 then --royal flush
            return_value.hand = ROYAL_FLUSH
        elseif flush then --straight flush
            return_value.hand = STRAIGHT_FLUSH
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[return_value[1]][1])
        else
            return_value.hand = STRAIGHT
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[return_value[1]][1])
        end
    elseif flush then
        return_value.hand = FLUSH
        return_value[1] = sorted_hand
    else -- handle pairs
        pair_index = {}
        for i = 0, 4 do
            pair_index[i] = {}
        end
        for card, count in pairs(values) do
            if card == 1 then
                card = 14
            end
            table.insert(pair_index[count], card)
        end    
        -- Sort in reverse for later comparisons
        for i = 1, 4 do
            utils.reverse_sort(pair_index[i])
        end
        
        if #pair_index[4] == 1 then
            return_value.hand = FOUR_OF_A_KIND
            return_value[1] = pair_index[4]
            return_value[2] = pair_index[1]
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[pair_index[4][1]][2])
        elseif #pair_index[3] == 1 and #pair_index[2] == 1 then 
            return_value.hand = FULL_HOUSE
            return_value[1] = pair_index[3]
            return_value[2] = pair_index[2]
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[pair_index[3][1]][2], card_to_text[pair_index[2][1]][2])
        elseif #pair_index[3] == 1 then
            return_value.hand = THREE_OF_A_KIND
            return_value[1] = pair_index[3]
            return_value[2] = pair_index[1]
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[pair_index[3][1]][2])
        elseif #pair_index[2] == 2 then
            return_value.hand = TWO_PAIR
            return_value[1] = pair_index[2]
            return_value[2] = pair_index[1]
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[pair_index[2][1]][2], card_to_text[pair_index[2][2]][2])
        elseif #pair_index[2] == 1 then
            return_value.hand = PAIR
            return_value[1] = pair_index[2]
            return_value[2] = pair_index[1]
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[pair_index[2][1]][2])
        else 
            return_value.hand = HIGH_CARD
            return_value[1] = sorted_hand
            return_value.hand.friendly_name = string.format(return_value.hand.format_string, card_to_text[sorted_hand[1]][1])
        end
        return_value.ones = pair_index[1]
    end
    
    return return_value
end

function pick_to_trade(hand)
    value = evaluate_hand(hand)
    if(value.hand.value > 3) then
        return
    elseif(value.hand.value > 0) then
        for _, card in pairs(hand) do 
            if(utils.contains(value.ones, card.card)) then
                card.raised = true
            end
        end
    else
        -- probably need to test for 1 offs here
        for _, card in pairs(hand) do 
            if card.card ~= value[1][1] and card.card ~= 1 then -- trick for ruling out aces (in the hand as 1, in thte value array as 14)
                card.raised = true    
            end
        end
    end
end

function compare_hands(a,b)
    if(a.hand.value > b.hand.value) then
        return -1
    elseif(a.hand.value < b.hand.value) then
        return 1
    else
        local i = 1
        while a[i] and b[i] do
            local ret = compare(a[i], b[i])
            if(ret ~= 0) then
                return ret
            end
        end
    end
    return 0
end

function compare(a,b)
    if(type(a) == 'table' and type(b) == 'table') then
        for k,v in pairs(a) do
            local ret = compare(a[k], b[k])
            if(ret ~= 0) then
                return ret
            end
        end
    elseif(type(a) == 'number' and type(b) == 'number') then
        if(a == b) then
            return 0
        elseif(a > b) then
            return -1
        else
            return 1
        end
    else 
        return nil
    end
end

return state
