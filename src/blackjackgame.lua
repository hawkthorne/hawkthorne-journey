local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'
local window = require 'window'
local fonts = require 'fonts'
local timer = require 'vendor/timer'
local Prompt = require 'prompt'
local Dialog = require 'dialog'
local camera = require 'camera'
local state = Gamestate.new()
local utils = require 'utils'
local sound = require 'vendor/TEsound'
local cardutils = require 'cardutils'

-- CONSTANTS
local DECKRESHUFFLE = 2*52 -- create new deck if number of cards in shoe less than this number
local NUMDECKS = 6

function state:init()
  -- Graphical Initiation    
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
  
  --self.card_complete = true
  self.cards_moving = false
  
  self.options_arrow = love.graphics.newImage( 'images/menu/tiny_arrow.png' )
  self.options = {
      { name = 'HIT'},
      { name = 'STAND'},
      { name = 'DOUBLE'},
      { name = 'SPLIT'},
      { name = 'DEAL'},
      { name = 'BET +'},
      { name = 'BET -'},
      { name = 'QUIT', active = true},
  }
  self.selection = 4
  
  -- Animation speed
  self.card_speed = 0.5

  -- Initiate hands
  self.numOfHands = 1
  self.activeHand = 1
  
  self.deck = cardutils.newDeck( NUMDECKS )
  
  -- holds all player and dealer hand information
  self.playerHand={}
  self.dealerHand={}
  self.is_blackjack = false
  self.currentBet = 2    
end

function state:enter(previous, player, screenshot)
  sound.playMusic( "tavern" )
  --lazy because i want to reset all position data

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

  -- Don't allow the player to bet more money than they have
  if self.player.money > 1 then
      self.currentBet = 2
  else
      self.currentBet = 1
  end
end

function state:keypressed(button, player)
  if button == 'JUMP' and self.selected == 'QUIT' then
    Prompt.new("Are you sure you want to exit?",
      function(result)
        if result == 'Yes' then
            Gamestate.switch(self.previous)
        else
            Prompt.currentDialog = nil
        end
      end
    )
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
      local betDelta = 0
      if (self.currentBet < self.player.money and self.currentBet < 15) then 
        betDelta = 1
      elseif (self.currentBet < self.player.money - 5 and self.currentBet < 50) then
        betDelta = 5
      elseif (self.currentBet < self.player.money - 10 and self.currentBet < 100) then
        betDelta = 10
      elseif (self.currentBet < self.player.money - 25 and self.currentBet < 250) then
        betDelta = 25
      elseif (self.currentBet < self.player.money - 100) then
        betDelta = 100
      else
        betDelta = 0
      end
      self.currentBet = self.currentBet + betDelta     
    elseif self.selected == 'BET -' then
      local betDelta = 0
      if (self.currentBet > 250 and (self.currentBet -250)%100 ~= 0) then
        betDelta = -(self.currentBet - 250)%100
      elseif self.currentBet > 250 then
        betDelta = -100
      elseif self.currentBet > 125 then
        betDelta = -25
      elseif self.currentBet > 50 then
        betDelta = -10
      elseif self.currentBet > 20 then
        betDelta = -5
      elseif self.currentBet > 1 then
        betDelta = -1 
      end
      self.currentBet = self.currentBet + betDelta
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

function state:gameMenu() -- set the game menu after card additions/changes
  -- fix the menu
  self.selection = 0                          -- hit
  self.options[ 1 ].active = true             -- hit
  self.options[ 2 ].active = true             -- stand
  
  -- get actual bet value
  local actualBets = 0
  if self.numOfHands > 1 then
    for i=1,self.numOfHands,1 do
      actualBets = actualBets + self.playerHand[i].bet
    end
  else
    actualBets = self.currentBet
  end
  
  -- the bet is doubled so need to account for that when checking availablity
  if actualBets < self.player.money/2 then
    self.options[ 3 ].active = true           -- double
  else
    self.options[ 3 ].active = false          -- double
  end
  
  -- same situation as above
  if actualBets < self.player.money/2 and 
                  self.playerHand[self.activeHand].cards[1].card==self.playerHand[self.activeHand].cards[2].card then
    self.options[ 4 ].active = true           -- split
  else
    self.options[ 4 ].active = false          -- split
  end
  
  self.options[ 5 ].active = false            -- deal
  self.options[ 6 ].active = false            -- bet
  self.options[ 7 ].active = false            -- bet
end

function state:dealMenu() -- set game menu after hand finished
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
  -- check if any cards are moving (separated in case of early break on an or)
  local is_moving = self:update_cards(self.playerHand[self.activeHand], dt)
  local is_dealermoving = self:update_cards(self.dealerHand[1],dt)
  is_moving = is_moving or is_dealermoving

  -- run functions that are holding until animation complete
  if (not is_moving) and self.card_complete_callback then
    self.card_complete_callback()
  end

  self.cards_moving = is_moving -- set moving flag, affects ability to selection options on keypress
  self.selected = self.options[ self.selection + 1 ].name
end

function state:update_cards(hand, dt)
  local cards = {}
  if hand then
    cards = hand.cards
  end

  local is_stillmoving = false
  if cards and #cards>0 then
    for i = 1,#cards,1 do
      if cards[i].is_moving then
        cards[i].is_moving = self:move_card(cards[i],dt)
        if cards[i].is_moving then
          is_stillmoving = true
        end
      end
    end
  end
  
  return is_stillmoving
end

function state:move_card(card, dt)
  local is_moving = false
  
  if (card.move_idx + dt) < self.card_speed then
    card.move_idx = card.move_idx + dt
    is_moving = true
  else
    card.move_idx = self.card_speed -- this means card is at its x destination
  end

  if card.face_up then
    if (card.flip_idx + dt) < self.card_speed then
      card.flip_idx = card.flip_idx + dt
      is_moving = true
    else
      card.flip_idx = self.card_speed -- this means card is flipped
    end
  end
  
  return is_moving
end

function state:initHands(hand) -- initialize a player or dealer hand
  hand.cards = {}
  hand.score = 0
  hand.is_bust = false
  hand.has_ace = false
  hand.bet = self.currentBet
end

function state:initTable()  -- Initialize a new betting round
  -- clear everyones cards
  self.dealerHand[1] = {}
  self:initHands(self.dealerHand[1])
  
  self.playerHand = {}
  self.playerHand[1] = {}
  self:initHands(self.playerHand[1])

  self.activeHand = 1
  self.numOfHands = 1
  self.is_blackjack = false
  
  -- check remaining cards, if less than reshuffle size, make a new deck
  if #self.deck < DECKRESHUFFLE then
    self.deck = cardutils.newDeck(NUMDECKS)
  end

  self.player_done = false
  self.dealer_done = false

  self.outcome = nil
end

function state:dealHand()   -- Deal a new betting round
  self:initTable()
  
  -- deal first 4 cards
  self:dealCard('player')
  self:dealCard('dealer')
  -- wait to deal other cards
  self.card_complete_callback = function()
    self.card_complete_callback = nil
    self:dealCard('player')
    self:dealCard('dealer')

    -- set game menu
    self:gameMenu()
    
    -- check for player blackjack
    if self.playerHand[1].score == 21 then
      self.is_blackjack = true
      self:stand()
    end

    -- check for dealer blackjack
    if (self.dealerHand[1].cards[1].card == 1 and self.dealerHand[1].cards[2].card >= 10) or
        (self.dealerHand[1].cards[1].card >= 10 and self.dealerHand[1].cards[2].card == 1) then
      self:stand()
    end
  end
end

function state:dealCard(to) -- Deal out an individual card, will update score as well, no bust logic
  --Initiate location of card
  x = 293 + camera.x
  
  -- cards dealt face up except for second dealer card
  local face_up = true
  
  -- pull a card
  local deal_card = table.remove(self.deck, 1)
  local hand = {}
  
  if to == 'dealer' then
    hand = self.dealerHand[1]
    y = 66 + camera.y
    -- second card is not shown
    if #self.dealerHand[1].cards == 1 then
      face_up = false
    end
  elseif to == 'player' then
    hand = self.playerHand[self.activeHand]
    y = 169 + ( self.activeHand - 1 ) * 9 + camera.y
  end

  self.card_moving = true

  if hand.cards then
    hand.cards[#hand.cards + 1] = {
      card = deal_card.card,
      suit = deal_card.suit,
      x = x - ( self.width_per_card * #hand.cards ),
      y = y,
      move_idx = 0,
      flip_idx = 0,
      face_up = face_up,
      is_moving = true
    }
  else
    hand.cards[1] = {
      card = deal_card.card,
      suit = deal_card.suit,
      x = x - ( self.width_per_card * #hand.cards ),
      y = y,
      move_idx = 0,
      flip_idx = 0,
      face_up = face_up,
      is_moving = true
    }
  end

  -- set ace flag if ace has been added  
  if deal_card.card == 1 then
    hand.has_ace = true
  end
  self:updateScore(hand)
  
  -- adjust widths when we've run out of room
  if #hand.cards * self.width_per_card >= self.max_card_room then
    new_width = self.max_card_room / #hand.cards
    for i,n in pairs( hand.cards ) do
      -- no idea why I need this hocus pocus, but it seems to work
      n.x = x - math.floor( ( new_width - 2 ) * ( i - 1 ) )
    end
  end
end

function state:hit()
  self.options[3].active = false     -- disable double-down after hit
  self.options[4].active = false     -- disable splitting

  -- deal a card
  self:dealCard('player')
  
  -- wait for animation to complete
  self.card_complete_callback =function()
    self.card_complete_callback = nil
    -- bust or still alive?
    if self.playerHand[self.activeHand].score <= 21 then
      self.playerHand[self.activeHand].is_bust = false
      if self.playerHand[self.activeHand].score == 21 then
        self:stand()
      end
    else
      self.playerHand[self.activeHand].is_bust = true
      self:stand()
    end
  end
end

function state:double()
  -- double bet
  self.playerHand[self.activeHand].bet = self.playerHand[self.activeHand].bet * 2

  -- deal a card
  self:dealCard('player')
  
  -- Check is_bust status
  if self.playerHand[self.activeHand].score <= 21 then
    self.playerHand[self.activeHand].is_bust = false
  else
    self.playerHand[self.activeHand].is_bust = true
  end
  
  -- force stand after double-down
  self.card_complete_callback =function()
    self.card_complete_callback = nil
    self:stand()
  end
end

function state:split()
  self.selection = 0 -- hit

  --split stub
  self.numOfHands = self.numOfHands + 1;

  --add a new hand
  local newHandNum = self.numOfHands;
  self.playerHand[newHandNum] = {}
  self:initHands(self.playerHand[newHandNum])

  --move 2nd card to new hand and move to new row
  self.playerHand[newHandNum].cards[1] = table.remove(self.playerHand[self.activeHand].cards) --move second card to new hand
  self.playerHand[newHandNum].cards[1].y = 169 + camera.y + ( newHandNum - 1 ) * 9 -- place hand in new row
  self.playerHand[newHandNum].cards[1].x = self.playerHand[self.activeHand].cards[1].x

  if self.playerHand[self.activeHand].cards[1].card == 1 then
    self.playerHand[newHandNum].has_ace = true
    -- no hits on splitting aces
    self:dealCard('player')
    self.activeHand = self.activeHand + 1
    self:dealCard('player')
    self.card_complete_callback = function()
      self.card_complete_callback = nil
      self:stand()
    end
    return
  end
  
  --deal cards for original hand, reset menu to allow for splitting and double-down
  self:dealCard('player')
  self:gameMenu()
end

function state:stand()
  --check if more than one hand available, switch to next hand, if one exists. Allow for re-split and double by running gameMenu
  if self.activeHand < self.numOfHands then
    self.activeHand = self.activeHand + 1
    self:dealCard('player')
    self:gameMenu()
    return
  end

  self.player_done = true
  
  -- flip hidden dealer card
  self.dealerHand[1].cards[2].face_up = true
  self.dealerHand[1].cards[2].is_moving = true
  self:updateScore(self.dealerHand[1])

  -- if not a bust or blackjack, play out the dealers hand
  local doPlayDealer = false;
  if self.is_blackjack == false then --if player has blackjack then skip check
    for i = 1, self.numOfHands, 1 do
      if self.playerHand[i].is_bust == false then
        doPlayDealer = true
        break
       end
    end
  
    -- play out dealer hand if no blackjack or not all hands have busted
    if doPlayDealer then
      while self.dealerHand[1].score < 17 do
        self:dealCard('dealer')
      end
    end
  end

  -- wait for animations to complete
  self.card_complete_callback = function()
    self.card_complete_callback = nil
    self.dealer_done = true
    
    -- Blackjack!
    if self.is_blackjack == true and (self.dealerHand[1].score ~= 21) then
      self.player.money = self.player.money + ( self.currentBet * 2 )
      self.outcome = 'You have Blackjack!\nYou Win!'
    -- Dealer blackjack :(
    elseif #self.dealerHand[1].cards == 2 and self.dealerHand[1].score == 21 then
      self.player.money = self.player.money - self.currentBet
      self.outcome = 'Dealer has Blackjack.\nYou Lose.'
    -- else, run through other scenarios, which may have multiple hands and/or double downs
    else
      for curHandNum=1,self.numOfHands do
        -- check player bust first, due to multiple hands
        if self.playerHand[curHandNum].score > 21 then
          self.player.money = self.player.money - self.playerHand[curHandNum].bet
          self.outcome = 'Busted. You Lose.'
        elseif self.dealerHand[1].score > 21 then
          -- dealer bust, player wins
          self.player.money = self.player.money + self.playerHand[curHandNum].bet
          self.outcome = 'Dealer busted.\nYou Win!'
        elseif self.dealerHand[1].score == self.playerHand[curHandNum].score then
          -- push, no winner
          self.outcome = 'It\'s a push.'
        elseif self.dealerHand[1].score < self.playerHand[curHandNum].score then
          -- player beat dealer, player wins
          self.player.money = self.player.money + self.playerHand[curHandNum].bet
          self.outcome = 'You Win!'
        else
          -- player lost to dealer, player loses
          self.player.money = self.player.money - self.playerHand[curHandNum].bet
          self.outcome = 'You Lost.'
        end
      end
    end
    -- player must have at least 1 coin to continue playing
    if self.player.money < 1 then
      self.player.money = 0
      self:gameOver()
    end
    -- decrease current bet if player has less money than previous bet
    if self.player.money < self.currentBet then
      self.currentBet = self.player.money
    end
  end

  self:dealMenu()
end

function state:gameOver()
  Dialog.new("Game Over.",
    function(result)
      Gamestate.switch(self.previous)
    end
  )
end

function state:updateScore(hand) -- Accepts dealerHand[1] or playerHand[activeHand] table
  local score = 0
  for i,n in pairs(hand.cards)  do
    if n.face_up then
      if n.card > 10 then
        score = score + 10
       else
         score = score + n.card
       end
    end
  end

  if hand.has_ace == true and (score + 10)<=21 then
    score = score + 10
  end

  hand.score = score
end

function state:draw()
  if self.screenshot then
    love.graphics.draw(
      self.screenshot,
      camera.x,
      camera.y,
      0,
      window.width / love.graphics:getWidth(),
      window.height / love.graphics:getHeight()
     )
  else
    love.graphics.setColor(
      0,
      0,
      0,
      255
    )
    love.graphics.rectangle(
      'fill',
      0,
      0,
      love.graphics:getWidth(),
      love.graphics:getHeight()
    )
    love.graphics.setColor(
      255,
      255,
      255,
      255
    )
  end
  love.graphics.draw(
    self.table,
    self.center_x - ( self.table:getWidth() / 2 ),
    self.center_y - ( self.table:getHeight() / 2 )
  )

  --dealer stack
  love.graphics.draw( self.cardSprite, self.cardback, self.dealer_stack_x, self.dealer_stack_y )

  if self.dealerHand[1] then
    for i,n in pairs( self.dealerHand[1].cards ) do
      self:drawCard(
        n.card, n.suit,                                                    -- card / suit
        utils.map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
        utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
        utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y )    -- y
      )
    end
  end

  if self.playerHand then
    for idx = 1, self.numOfHands do
      if self.playerHand[idx] then
        for i,n in pairs( self.playerHand[idx].cards ) do
            self:drawCard(
              n.card, n.suit,                                                    -- card / suit
              utils.map( n.flip_idx, 0, self.card_speed, 0, 100 ),                     -- flip
              utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_x, n.x ),   -- x
              utils.map( n.move_idx, 0, self.card_speed, self.dealer_stack_y, n.y ),   -- y
              idx ~= self.activeHand and not self.player_done
            )
        end
      end
    end
  end

  -- Ensure proper font is set
  fonts.set('big')

  for i,n in pairs( self.options ) do
    local x = self.options_x
    local y = self.options_y + ( i * 15 )
    local co = 0 -- color offset
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

  -- update dealer score, when done
  if self.dealer_done then
    if self.dealerHand[1].score > 21 then
      love.graphics.print(
        "BUST",
        self.dealer_result_pos_x,
        self.dealer_result_pos_y,
        0,
        0.5
      )
    else
      love.graphics.print(
        self.dealerHand[1].score,
        self.dealer_result_pos_x + 7,
        self.dealer_result_pos_y,
        0,
        0.5
      )
    end
  end

  -- update player score, as cards appear
  if self.playerHand[1] then
    if self.playerHand[1].score then
      for i=1,self.numOfHands do
        if self.playerHand[i].score > 21 then
          love.graphics.print(
            "BUST",
            self.dealer_result_pos_x,
            self.dealer_result_pos_y +101+(i-1)*14,
            0,
            0.5
          )
        else
          love.graphics.print(
            self.playerHand[i].score,
            self.dealer_result_pos_x + 7, 
            self.dealer_result_pos_y +101+(i-1)*14,
            0, 
            0.5
          )
        end
      end
    end
  end

  if self.outcome then -- print results if hand complete
    love.graphics.print(
      self.outcome, 
      self.outcome_pos_x, 
      self.outcome_pos_y,
      0,
      0.5
    )
  end

  love.graphics.print( -- print current money
    'On Hand\n $ ' .. self.player.money,
    110+camera.x,
    244+camera.y,
    0,
    0.5
  )
  
  love.graphics.print(  -- print current bet
    'Bet $ ' .. self.currentBet,
    361+camera.x,
    141+camera.y,
    0,
    0.5
  )

  love.graphics.setColor( 255, 255, 255, 255 )

  -- Ensure font is reverted
  fonts.revert()
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
    _card = love.graphics.newQuad(
        ( card - 1 ) * w,
        ( suit - 1 ) * h,
        w,
        h,
        self.cardSprite:getWidth(),
        self.cardSprite:getHeight()
      )
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
    utils.map( flip, 50, limit, y - ( ( sh - h ) / 2 ), y ),  -- height offset
    0,                                                  -- no rotation
    utils.map( flip, 50, limit, 0, 1 ),                       -- scale width for flip
    utils.map( flip, 50, limit , 1 + st, 1 )                  -- scale height for flip
  )

  love.graphics.setColor( 255, 255, 255, 255 )
end

return state
