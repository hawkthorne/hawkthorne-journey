local List = require 'list'
local window = require 'window'
local fonts = require 'fonts'

local Debugger = { on=false }
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
  Debugger.on = not Debugger.on
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

function Debugger:draw()
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