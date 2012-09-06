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

    self.cardSprite = love.graphics.newImage('images/cards_2.png' )
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
    self.chip_x = 138
    self.chip_y = 208
    
    self.center_x = ( window.width / 2 )
    self.center_y = ( window.height / 2 )
    self.dealer_stack_x = 356
    self.dealer_stack_y = 37
    
    self.max_card_room = 227
    self.width_per_card = 45
    
	-- to avoid crazy poker hands
    self.decks_to_use = 1
    
    self.card_speed = 0.2
    
    self.options_arrow = love.graphics.newImage( 'images/tiny_arrow.png' )
    self.options_x = 360
    self.options_y = 135
    self.options = {
        { name = 'DRAW', action = 'poker_draw' },
        { name = 'DEAL', action = 'deal_hand' },
        { name = 'BET +', action = function() if self.bet < self.money then self.bet = self.bet + 1 end end },
        { name = 'BET -', action = function() if self.bet > 1 then self.bet = self.bet - 1 end end },
        { name = 'QUIT', action = 'quit', active = true },
    }
    self.selection = 2

    self.money = 25

    self.bet = 2

	self.horizontal_selection = 0
end

function state:enter(previous, screenshot)
    sound.playMusic( "tavern" )

    self.previous = previous
    self.screenshot = screenshot
    
    self.camera_x = camera.x
    camera.max.x = 0
    camera:setPosition( 0, 0 )
    
    self.prompt = nil
    
    self:init_table()
    self:deal_menu()
    
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
    
        if key == 'escape' or ( key == 'return' and self.options[self.selection + 1].name == 'QUIT' ) then
            self.prompt = Prompt.new( 120, 55, "Are you sure you want to exit?", function(result)
                if result then
                    Gamestate.switch(self.previous)
                else
                    self.prompt = nil
                end
            end )
			return
        end

        if key == 'return' or key == ' ' then
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
			if key == 'left' or key == 'a' then
				self.horizontal_selection = (self.horizontal_selection + 1) % 6
			elseif key == 'right' or key == 'd' then
				self.horizontal_selection = (self.horizontal_selection - 1) % 6
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

function state:game_menu()
        -- fix the menu
        self.selection = 0                  
        self.options[ 1 ].active = true     
        self.options[ 2 ].active = false    
        self.options[ 3 ].active = false    
        self.options[ 4 ].active = false
    	self.horizontal_selection = 0
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
    timer.update(dt)
    if self.prompt then self.prompt:update(dt) end
    self.cards_moving = self:update_cards( self.player_cards, self.dealer_cards, dt )
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

function state:init_table()
    -- clear everyones cards
    self.dealer_cards = {}
    self.player_cards = {}
    
    -- make a new deck
    self.deck = new_deck( self.decks_to_use )
    
    self.outcome = nil
end

function state:deal_hand()
    self:init_table()
    
	self:no_menu()
	
	self.card_complete_callback = function()
		self.card_complete_callback = nil
		self:game_menu()
	end

    -- deal first 4 cards
    self:deal_card( 'player' )
    self:deal_card( 'dealer' )
    self:deal_card( 'player' )
    self:deal_card( 'dealer' )
    self:deal_card( 'player' )
    self:deal_card( 'dealer' )
    self:deal_card( 'player' )
    self:deal_card( 'dealer' )
	self:deal_card( 'player' )
    self:deal_card( 'dealer' )

end

function state:poker_draw()
	self:no_menu()
	self.card_complete_callback = function()
		self.card_complete_callback = nil
		self:deal_menu()
		for _, card in pairs(self.dealer_cards) do
			card.face_up = true
		end
	end
	for i = 1, 5 do
		if self.player_cards[i].raised then
			self.player_cards[i] = nil
			self:deal_card('player')
		end
		if self.dealer_cards[i].raised then
			self.dealer_cards[i] = nil
			self:deal_card('dealer')
		end
	end
	
end

function state:deal_card( to )
    deal_card = table.remove( self.deck, 1 )
    x = 266
    face_up = true
    tbl = self.player_cards
    y = 140
    if to == 'dealer' then
        -- second card is not shown
       face_up = false
        tbl = self.dealer_cards
        y = 37
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
end

function state:game_over()
    self.prompt = Dialog.new( 120, 55, "Game Over.", function(result)
        Gamestate.switch(self.previous)
    end )
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
            self:draw_card(
                n.card, n.suit,                                                    -- card / suit
                map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y ),   -- y
				n.raised and 10 or 0
            )
        end
    end

    if self.player_cards then
        for i,n in pairs( self.player_cards ) do
            self:draw_card(
                n.card, n.suit,                                                    -- card / suit
                map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
                map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y ),    -- y
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
    for color,count in pairs( getChipCounts( self.money ) ) do
        cy = 0 -- chip offset y ( start at top )
        -- draw full stacks first
        for s = 1, math.floor( count / 5 ), 1 do
            --print( color, s, s % 2 == 0 )
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

function state:draw_card( card, suit, flip, x, y, offset, overlay )
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
	if(overlay) then
		darkness = 150
	end
    love.graphics.setColor( darkness, darkness, darkness )
    love.graphics.drawq(
        self.cardSprite, _card,                             -- image, quad
        x + map( flip, 50, limit, w / 2, 0 ),               -- offset for flip
        map( flip, 50, limit, y - ( ( sh - h ) / 2 ), y ) + offset,  -- height offset
        0,                                                  -- no rotation
        map( flip, 50, limit, 0, 1 ),                       -- scale width for flip
        map( flip, 50, limit , 1 + st, 1 )                  -- scale height for flip
    )

    love.graphics.setColor( 255, 255, 255, 255 )
end

function map( x, in_min, in_max, out_min, out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end

function new_deck(_decks)
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

function get_chip_counts( amount )
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
    _c[1] = math.min( _c[1] + math.floor( amount / 100 ), 6 * 5 )
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

function get_first_nil(t)
	for i = 1, #t do
		if(t[i] == nil) then
			return i
		end
	end
	return #t + 1
end

return state