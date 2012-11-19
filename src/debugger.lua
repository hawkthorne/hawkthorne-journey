local List = require 'list'
local window = require 'window'
local fonts = require 'fonts'
local gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'

local Debugger = { on=false, bbox=false }
Debugger.__index = Debugger

Debugger.sampleRate = 0.05
Debugger.lastSample = 0

Debugger.graphData = {
  { name = 'gc', color = { 255, 0, 0, 150 }, list = List.new() }
}

function Debugger:reset()
  for k,_ in pairs(Debugger.graphData) do
      Debugger.graphData[k].list = List.new()
  end
end

function Debugger:toggle()
  if Debugger.on and not Debugger.bbox then
    Debugger.bbox = true
  elseif Debugger.on and Debugger.bbox then
    Debugger.on = false
    Debugger.bbox = false
  else
    Debugger.on = true
  end
  Debugger:reset()
end

function Debugger:getData(name)
  for k,v in pairs(Debugger.graphData) do
    if v.name == name then
      return Debugger.graphData[k]
    end
  end
  return false
end

function Debugger:listPush( list, val )
  List.pushleft( list, val )
  if math.abs(list.first) - math.abs(list.last) > window.screen_width then
    List.popright( list )
  end
end

function Debugger:update( dt )
    if Debugger.on and Debugger.lastSample > Debugger.sampleRate then
        Debugger:listPush( Debugger:getData('gc').list, collectgarbage( 'count' ) / 100 )
        Debugger.lastSample = 0
    else
        Debugger.lastSample = Debugger.lastSample + dt
    end
end

local function scale(t,s)
  for i=1,#t do
    t[i] = t[i] * s
  end
  return t
end

function Debugger:draw()
  if Debugger.bbox and gamestate.currentState().collider then
    camera:set()
    for _,shape in pairs(gamestate.currentState().collider._active_shapes) do
      love.graphics.setColor(255,0,0,100)
      shape:draw('line')
      love.graphics.setColor(255,0,0,50)
      shape:draw('fill')
    end
    for _,shape in pairs(gamestate.currentState().collider._passive_shapes) do
      love.graphics.setColor(0,255,0,100)
      shape:draw('line')
      love.graphics.setColor(0,255,0,50)
      shape:draw('fill')
    end
    for _,shape in pairs(gamestate.currentState().collider._ghost_shapes) do
      love.graphics.setColor(0,0,255,100)
      shape:draw('line')
      love.graphics.setColor(0,0,255,50)
      shape:draw('fill')
    end
    love.graphics.setColor(255,255,255,255)
    camera:unset()
  end
  for k,v in pairs( Debugger.graphData ) do
    love.graphics.setColor( v.color )
    for i=v.list.first, v.list.last do
      if v.list[i] then
        love.graphics.line(
          window.screen_width + v.list.first - i,
          window.screen_height - v.list[i],
          window.screen_width + v.list.first - i,
          window.screen_height
        )
      end
    end
  end
  love.graphics.setColor( 255, 255, 255, 255 )
  fonts.set('big')
  love.graphics.print( math.floor( collectgarbage( 'count' ) / 10 ) / 10 , window.screen_width - 30, window.screen_height - 10,0,0.5,0.5 )
  fonts.revert()
end

return Debugger