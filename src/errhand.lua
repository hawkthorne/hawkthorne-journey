function love.errhand(msg)
  msg = tostring(msg)

  error_printer(msg, 2)

  if not love.graphics or not love.event or not love.graphics.isCreated() then
    return
  end

  -- Load.
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(89, 157, 220)
  local font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  love.graphics.setColor(255, 255, 255, 255)

  local trace = debug.traceback()

  love.graphics.clear()

  local err = {}

  table.insert(err, "Error\n")
  table.insert(err, msg.."\n\n")

  for l in string.gmatch(trace, "(.-)\n") do
    if not string.match(l, "boot.lua") then
      l = string.gsub(l, "stack traceback:", "Traceback\n")
      table.insert(err, l)
    end
  end

  local p = table.concat(err, "\n")

  p = string.gsub(p, "\t", "")
  p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

  local function draw()
    love.graphics.clear()
    love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
    love.graphics.present()
  end

  draw()

  local e, a, b, c
  while true do
    e, a, b, c = love.event.wait()

    if e == "quit" then
      return
    end
    if e == "keypressed" and a == "escape" then
      return
    end

    draw()

  end

end

function love.releaseerrhand(msg)
  print("An error has occured, the game has been stopped.")

  if not love.graphics or not love.event or not love.graphics.isCreated() then
    return
  end

  love.graphics.setCanvas()
  love.graphics.setPixelEffect()

  -- Load.
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(89, 157, 220)
  local font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.clear()

  local err = {}

  p = string.format("Error has occured that caused %s to stop.\nYou can notify %s about this%s.", love._release.title or "this game", love._release.author or "the author", love._release.url and " at " .. love._release.url or "")

  local function draw()
    love.graphics.clear()
    love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
    love.graphics.present()
  end

  draw()

  local e, a, b, c
  while true do
    e, a, b, c = love.event.wait()

    if e == "quit" then
      return
    end
    if e == "keypressed" and a == "escape" then
      return
    end

    draw()

  end
end

