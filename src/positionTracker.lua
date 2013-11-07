local store = require 'hawk/store'
local utils = require 'utils'
local Timer = require 'vendor/timer'
local app = require 'app'

local db = store('positionTracker')

local PT = {
  interval = 0.1,
  enabled = false,

  data = {},
  level = nil,
  timedFunc = nil, 
  started = false
}

function PT.start( lvl, func )
  if PT.enabled then
    if not PT.started then
      PT.started = true
      PT.level = lvl
      PT.timedFunc = Timer.addPeriodic( PT.interval ,function()
        PT.add( func( ) )
      end)
    else
      PT.stop( )
      PT.start( lvl, func )
    end
  end
end

function PT.add( d )
  if  PT.enabled and PT.started then
    table.insert( PT.data, d )
  end
end

function PT.stop()
  if PT.enabled and PT.started then
    PT.started = false
    Timer.cancel( PT.timedFunc )
    db:set( PT.level .. '-' .. app.config.iteration, PT.data )
    db:flush( )
    PT.data = {}
    PT.level = nil
  end
end

return PT