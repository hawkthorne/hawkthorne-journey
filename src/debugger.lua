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

Debugger.infoToShow = {}
Debugger.infowidth = 100
Debugger.infoheight = 125

Debugger.graphData = {
  { name = 'gc', color = { 255, 0, 0, 150 } }
}

function Debugger:reset()
  love.mouse.setVisible( not ( Debugger.on and Debugger.bbox ) )
  for k,_ in pairs(Debugger.graphData) do
      Debugger.graphData[k].list = List.new()
  end
end

function Debugger.set( d, bb )
  Debugger.on = d
  Debugger.bbox = bb
  Debugger:reset()
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
    local x, y = love.mouse.getPosition()
    x, y = x + camera.x, y + camera.y 
    Debugger.infoToShow = {}
    camera:set()
    -- draw the boxes
    for _,shape in pairs(gamestate.currentState().collider._active_shapes) do
      Debugger.drawShape( shape, x, y, 255, 0, 0 )
    end
    for _,shape in pairs(gamestate.currentState().collider._passive_shapes) do
        if shape.node.isActive then
            Debugger.drawShape( shape, x, y, 255, 255, 0 )
        else
            Debugger.drawShape( shape, x, y, 0, 255, 0 )
        end
    end
    for _,shape in pairs(gamestate.currentState().collider._ghost_shapes) do
      Debugger.drawShape( shape, x, y, 0, 0, 255 )
    end
    Debugger.drawInfoBox( x, y )
    camera:unset()
    love.graphics.setColor(255,255,255,255)
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
  love.graphics.print(math.floor(collectgarbage('count')), window.screen_width - 30, window.screen_height - 10,0,0.5,0.5 )
  fonts.revert()
end

function Debugger.drawShape( s, x, y, r, g, b )
  love.graphics.setColor(r,g,b,100)
  s:draw('fill')
  love.graphics.setColor(r,g,b,50)
  s:draw('line')
  if s:contains( x, y ) and s.node and s.node.node then
    table.insert( Debugger.infoToShow, s.node.node )
  end
end

function Debugger.drawInfoBox( x, y )
  love.graphics.setColor(0,0,0,255)
  love.graphics.line( x - 2, y, x + 2, y )
  love.graphics.line( x, y - 2, x, y + 2 )
  if #Debugger.infoToShow > 0 then
    if x + Debugger.infowidth * #Debugger.infoToShow >= camera.x + window.width then x = x - Debugger.infowidth * #Debugger.infoToShow end
    if y + Debugger.infoheight >= camera.y + window.height then y = y - Debugger.infoheight end
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle( 'fill', x, y, Debugger.infowidth * #Debugger.infoToShow, Debugger.infoheight )
    love.graphics.setColor(0,0,0,50)
    love.graphics.rectangle( 'line', x, y, Debugger.infowidth * #Debugger.infoToShow, Debugger.infoheight )
    love.graphics.setColor(255,255,255,255)
    x, y = x + 5, y + 5
    local origy = y
    for _,info in pairs(Debugger.infoToShow) do
      for key,value in pairs(info) do
        if type( value ) ~= 'table' then
          love.graphics.print( key .. ' = ' .. value, x, y, 0, 0.5 )
        else
          love.graphics.print( key .. ' = {', x, y, 0, 0.5 )
          y = y + 6
          for tablekey,tablevalue in pairs(value) do
            if type(tablevalue) == 'table' then
                local newtable = ''
                for i,n in pairs(tablevalue) do
                    newtable = newtable .. i .. '=' .. n .. ' '
                end
                tablevalue = newtable
            end
            love.graphics.print( '    ' .. tablekey .. ' = ' .. tablevalue, x, y, 0, 0.5 )
            y = y + 6
          end
          love.graphics.print( '}', x, y, 0, 0.5 )
        end
        y = y + 6
      end
      x = x + Debugger.infowidth
      y = origy
    end
  end
end

return Debugger
