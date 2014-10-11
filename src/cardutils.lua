-- General functions for card games
local utils = require 'utils'

local cardutils = {}

function cardutils.newDeck(_decks)
  if _decks == nil then _decks = 1 end
  deck = {}
  for _deck = 1,_decks,1 do
    for _suit = 1,4,1 do
      for _card = 1,13,1 do
        table.insert( deck, { card = _card, suit = _suit } )
      end
    end
  end
  deck = utils.shuffle( deck, math.random( 5 ) + 5 ) -- shuffle the deck between 5 and 10 times
  return deck
end

function cardutils.getChipCounts( amount )
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

return cardutils
