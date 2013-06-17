return{
    name = 'tacomeat',
    type = 'consumable',
    MAX_ITEMS = 10,
    use = function( consumable, player )
        local Timer = require('vendor/timer')
        local sound = require('vendor/TEsound')
        local punchDamage = player.punchDamage
        local jumpDamage = player.jumpDamage
        local slideDamage = player.slideDamage
        local costume = player.character.costume
        Timer.add(66, function () --Resets damage boost and costume after one minute being active
            player.punchDamage = punchDamage
            player.jumpDamage = jumpDamage
            player.slideDamage = slideDamage
            player.character:setCostume(costume)
        end)
        for i=1,2 do
            Timer.add(2*i-1, function () -- Damage over time
                if player.health > 1 then player:hurt(3) end
            end)
        end
        Timer.add(6, function () -- Set costume to zombie and double unarmed player damage.
            if player.character:hasCostume('zombie') then
                player.character:setCostume('zombie')
            end
            player.jumpDamage = player.jumpDamage * 2
            player.punchDamage = player.punchDamage * 2
            player.slideDamage = player.slideDamage * 2
        end)
	end
}
