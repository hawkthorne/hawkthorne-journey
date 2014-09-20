local sound = require 'vendor/TEsound'
local Dialog = require 'dialog'
local Timer = require 'vendor/timer'
local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local fonts = require 'fonts'
local Dealer = {}

Dealer.__index = Dealer
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Dealer.isInteractive = true

function Dealer.new(node, collider)
    local dealer = {}
    setmetatable(dealer, Dealer)
    dealer.x = node.x
    dealer.y = node.y
    dealer.height = node.height
    dealer.width = node.width
    dealer.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    dealer.bb.node = dealer
    collider:setPassive(dealer.bb)
	
    return dealer
	
end

function Dealer:enter(dt)
	
	fonts.reset()

	--Dealer says "Let's play poker" after a few seconds when player enters the tavern.
	self.dialog = Timer.add(3, function()
		poker = Dialog.new("Let's play {{yellow}}poker{{white}}", 
							--He repeats it every few seconds, sound only
							function() self.loop = Timer.addPeriodic(15,function()
									sfx = sound.playSfx("letsPlayPoker")
									end, 
								math.huge) 
							end
						)
		sound.playSfx("letsPlayPoker")
		
	end
	)

	

function Dealer:leave()
	--The timers are canceled upon leaving so the dialog and sound don't occur outside the tavern.
    Timer.cancel(self.dialog)
	if self.loop ~= nil then
		Timer.cancel(self.loop)
		end
		
		end
		
		
end
	
    


function Dealer:update(dt)
end

function Dealer:draw()
end

function Dealer:keypressed( button, player )

    if button == 'INTERACT' then
        player.freeze = true
		
		--Timers for "Let's play poker" cancel upon interaction with the dealer.
		Timer.cancel(self.dialog)

		if self.loop ~= nil then
		Timer.cancel(self.loop)
		end

        local message = {'Choose a card game to play'}
        local options = {'Poker', 'Blackjack', 'Exit'}

        if player.money == 0 then
          message = {'You dont have enough money!','Come back again...'}
          options = {'Exit'}
        end

        local callback = function(result) 
            self.prompt = nil
            player.freeze = false
            if result == 'Poker' or result == 'Blackjack' then
              local screenshot = love.graphics.newImage( love.graphics.newScreenshot() )
              Gamestate.stack(result:lower() .. 'game', player, screenshot)
            end
        end

        self.prompt = Prompt.new(message, callback, options)
        -- Key has been handled, halt further processing
        return true
    end
end

return Dealer


