local fonts = require 'fonts'
local json = require 'hawk/json'
local sound = require 'vendor/TEsound'

local Replay = {
  onRecord = false, -- true if recording is in progress
  onPlay = false, -- true if replay is in progress

  display_on = true, -- display record/replay indicator
  display_dt = 0, -- display indicator deltaT since last change
  DISPLAY_RATE = 0.5, -- display indicator blinking rate [s]

  startTime = nil, -- start time of record/replay
  list = nil, -- table of all recorded keystrokes, item is table: {time, type, key}, type is KEYRELEASED or KEYPRESSED
  KEYRELEASED = 0,
  KEYPRESSED = 1,
  indexPlay = nil, -- index of the next played keystroke in the list (during replay)
  listDown = nil, -- table of all currently pressed down keys (during replay)

  FILENAME = "replay.json"
}

function Replay.startRecord()
  if Replay.onRecord then
    -- continue recording already in progress
    return
  end
  if Replay.onPlay then
    Replay.stopPlay()
  end

  Replay.startTime = love.timer.getTime()
  Replay.list = {}
  Replay.onRecord = true
  Replay.display_on = true
end

function Replay.stopRecord()
  if not Replay.onRecord then
    return
  end

  love.filesystem.write(Replay.FILENAME, json.encode(Replay.list))
  Replay.startTime = nil
  Replay.list = nil
  Replay.onRecord = false
end

function Replay.toggleRecord()
  if Replay.onRecord then
    Replay.stopRecord()
  else
    Replay.startRecord()
  end
end

---
-- Adds keystroke into {@link Replay.list}
-- @param typ KEYRELEASED or KEYPRESSED
-- @param key KeyConstant
function Replay.addKey(typ, key)
  assert(type(Replay.list) == "table", "Replay.list is not a table, but a " .. type(Replay.list))
  assert(typ == Replay.KEYRELEASED or typ == Replay.KEYPRESSED, "Invalid argument typ - unexpected value " .. tostring(typ))
  local time = love.timer.getTime() - Replay.startTime
  local item = {time, typ, key}
  table.insert(Replay.list, item)
end

function Replay.startPlay()
  if Replay.onPlay then
    -- continue the replay already in progress
  end
  if Replay.onRecord then
    Replay.stopRecord()
  end

  local contents, size = love.filesystem.read(Replay.FILENAME)
  if not contents then
    -- error opening the file
    sound.playSfx("dbl_beep")
    return
  end
  local ok, list = pcall(json.decode, contents)
  if not ok then
    -- error parsing the file
    print(list)
    sound.playSfx("dbl_beep")
    return
  end

  Replay.list = list or {}
  Replay.indexPlay = 1
  Replay.listDown = {}
  Replay.startTime = love.timer.getTime()
  Replay.onPlay = true
  Replay.display_on = true
end

function Replay.stopPlay()
  Replay.startTime = nil
  Replay.list = nil
  Replay.indexPlay = nil
  Replay.listDown = nil
  Replay.onPlay = false
end

function Replay.togglePlay()
  if Replay.onPlay then
    Replay.stopPlay()
  else
    Replay.startPlay()
  end
end

local function pressKey(key)
  assert(type(Replay.listDown) == "table", "Replay.listDown is not a table, but a " .. type(Replay.listDown))
  Replay.listDown[key] = true
end

local function releaseKey(key)
  assert(type(Replay.listDown) == "table", "Replay.listDown is not a table, but a " .. type(Replay.listDown))
  Replay.listDown[key] = nil
end

function Replay.isKeyDown(key)
  assert(type(Replay.listDown) == "table", "Replay.listDown is not a table, but a " .. type(Replay.listDown))
  return Replay.listDown[key] == true
end

---
-- @param dt deltaT
-- @param keyreleased function called for recorded keyrelease events
-- @param keypressed function called for recorded keypress events
--
function Replay.update(dt, keyreleased, keypressed)
  assert(type(keyreleased) == "function", "Replay.update: Invalid keyreleased argument type " .. type(keyreleased))
  assert(type(keypressed) == "function", "Replay.update: Invalid keypressed argument type " .. type(keypressed))
  if not Replay.onRecord and not Replay.onPlay then return end

  Replay.display_dt = Replay.display_dt + dt
  if Replay.display_dt >= Replay.DISPLAY_RATE then
    Replay.display_on = not Replay.display_on
    Replay.display_dt = Replay.display_dt % Replay.DISPLAY_RATE
  end

  if Replay.onRecord then
    -- nothing more to do for recording
    return
  end

  if Replay.indexPlay > #Replay.list then
    -- the replay is finished
    sound.playSfx("beep")
    Replay.stopPlay()
    return
  end

  local item = Replay.list[Replay.indexPlay]
  assert(type(item) == "table", "Replay.update: Replay.list[" .. Replay.indexPlay.. "] has type " .. type(item) .. " (expected table)")
  assert(#item == 3, "Replay.update: Replay.list[" .. Replay.indexPlay.. "] has length " .. #item .. " (expected 3)")
  assert(type(item[1]) == "number", "Replay.update: Replay.list[" .. Replay.indexPlay.. "][1] has type " .. type(item[1]) .. " (expected number)")
  assert(item[2] == Replay.KEYRELEASED or item[2] == Replay.KEYPRESSED,
    "Replay.update: Replay.list[" .. Replay.indexPlay.. "][2] has value '" .. item[2] .. "' (expected " .. Replay.KEYRELEASED .. " or " .. Replay.KEYPRESSED .. ")")
  assert(type(item[3]) == "string", "Replay.update: Replay.list[" .. Replay.indexPlay.. "][3] has type " .. type(item[3]) .. " (expected string)")

  local time = love.timer.getTime() - Replay.startTime
  if time >= item[1] then
    -- replay keystroke
    if item[2] == Replay.KEYRELEASED then
      releaseKey(item[3])
      keyreleased(item[3])
    elseif item[2] == Replay.KEYPRESSED then
      pressKey(item[3])
      keypressed(item[3])
    else
      error("Should not get here.")
    end
    Replay.indexPlay = Replay.indexPlay + 1
  end
end

---
-- Draws blinking R in the top left corner
-- its color is red for record, black for replay
--
function Replay.draw()
  if not Replay.onPlay and not Replay.onRecord then return end
  if not Replay.display_on then return end

  if Replay.onPlay then
    love.graphics.setColor(0, 0, 0)
  else
    love.graphics.setColor(255, 0, 0)
  end
  fonts.set('big')
  love.graphics.print("R", 2, 2)
  fonts.revert()
  love.graphics.setColor(255, 255, 255, 255)
end

return Replay
