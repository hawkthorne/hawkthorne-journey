local Quicksand = {}
Quicksand.__index = Quicksand

function Quicksand.new(node, collider)
	local quicksand = {}
	setmetatable(quicksand, Quicksand)
	quicksand.collider = collider
	quicksand.width = node.width
	quicksand.height = node.height

	quicksand.position = {x=node.x, y=node.y}

	quicksand.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
	quicksand.bb.node = quicksand
	collider:setPassive(quicksand.bb)

	return quicksand
end

function Quicksand:collide(player, dt, mtv_x, mtv_y)
player.rebounding = false
player.quicksand = true
	if player.velocity.x > 20 then
		player.velocity.x = 20
	elseif player.velocity.x < -20 then
		player.velocity.x = -20
	end

	if player.velocity.y > 0 then
		player.jumping = false
	 	player.velocity.y = 20
	end
end

function Quicksand:collide_end(player, dt, mtv_x, mtv_y)
player.quicksand = false
	if player.velocity.y < 0 then
		player.velocity.y = player.velocity.y - 200
	end
end

function Quicksand:update(dt, player)
	return
end

function Quicksand:draw()
	return
end

return Quicksand