local camera = require 'camera'
local window = require 'window'
local cheats = require 'cheat'
local gamestate = require 'vendor/gamestate'

local AchievementTracker = {}
AchievementTracker.__index = AchievementTracker

trophies = {
    ["cheat indicator"]={
        ["headline"]="Achievements temporarily disabled",
        ["description"]="You can't earn achievements while cheats are on.",
        ["icon"]=nil
    },
    ["cheat indicator okay"]={
        ["headline"]="Achievements reenabled",
        ["description"]="You can earn achievements now that cheats are off.",
        ["icon"]=nil
    },
    ["the floor is lava"]={
        ["headline"]="The Floor is Lava",
        ["description"]="Get from one end of the town to the other without touching the ground.",
        ["icon"]=nil
    },
    ["punch your butt"]={
        ["headline"]="Punch Your Butt",
        ["description"]="Kill 5 hippies consecutively without touching the floor.",
        ["icon"]=nil
    },
    ["safety first"]={
        ["headline"]="Safety First",
        ["description"]="Get through the first hallway without being hurt.",
        ["icon"]=nil
    },
    ["best athlete on campus"]={
        ["headline"]="Best Athlete on Campus",
        ["description"]="Get through the first hallway without being hurt, killing no hippies, in less than 25 seconds.",
        ["icon"]=nil
    }
}

counters = {}
queue = {}
timer = 0
const_times = {}

const_times.total = 10
const_times.fadein = const_times.total * 1/5
const_times.fadeout = const_times.total * 4/5

---
-- Return the currently active level
-- @return level
function CurrentLevel()
    return gamestate.currentState()
end

---
-- Return whether any cheats are enabled
function cheatsEnabled()
    for i, v in pairs(cheats) do
        if v == true then return true end
    end
    return false
end

---
-- Create a new tracker for achievements.
-- @return tracker
function AchievementTracker.new()
    local tracker = {}
    setmetatable(tracker, AchievementTracker)

    return tracker
end

---
-- Return current count for a tracked label.
-- @param label
-- @return count
function AchievementTracker:getCount(label)
    if counters[label] == nil then
        self:setCount(label, 0)
        return 0
    end
    return counters[label]
end

---
-- Set current count for a tracked label.
-- @param label
-- @param count
-- @return nil
function AchievementTracker:setCount(label, count)
    counters[label] = count
end

---
-- Return a list of tracked labels.
-- @return labels
function AchievementTracker:getTrackedLabels()
    local labels = {}
    for l, _ in ipairs(tracker.counters) do table.insert(labels, l) end
    return labels
end

---
-- Accomplish some tracked task, with optional delta
-- @param label
-- @param delta (optional)
-- @return nil
function AchievementTracker:achieve(label, delta)
    delta = delta or 1
    self:setCount(label, self:getCount(label) + delta)
    self:display(label)
    self:onAchieve(label)
end

---
-- Code to display achievements as they happen.
-- @param label
-- @return nil
function AchievementTracker:display(label)
    local info = trophies[label]
    if info == nil then return end
    -- print(info.headline .. '\n\n\t' .. info.description)
    headline = info.headline
    count = self:getCount(label)
    if count > 1 then
        headline = headline .. " (X" .. tostring(count) .. ")"
    end
    table.insert(queue, {
        headline = headline,
        description = info.description,
        icon = info.icon,
        timeleft = const_times.total,
    })
end

---
-- Move through display queue
-- @param dt
-- @return nil
function AchievementTracker:update(dt)

    timer = timer + dt
    if timer > 1 then
        self:achieve('room timer', math.floor(timer))
        timer = timer - math.floor(timer)
    end

    current = queue[1]
    if current == nil then return end

    current.timeleft = math.max(current.timeleft - dt, 0)
    if current.timeleft == 0 then
        table.remove(queue, 1)
        return
    end
end

---
-- Draw to screen
-- @return nil
function AchievementTracker:draw()
    current = queue[1]
    if current == nil then return end

    local fade
    if current.timeleft <= const_times.fadein then
        fade = current.timeleft / const_times.fadein
    elseif current.timeleft >= const_times.fadeout then
        fade = (const_times.total - current.timeleft) / (const_times.total - const_times.fadeout)
    else
        fade = 1
    end

    local width = 200
    local height = 50
    local margin = 20

    local x = window.width  - (margin + width) + camera.x
    local y = window.height - (margin + height) + camera.y

    -- Draw rectangle
    love.graphics.setColor( 0, 0, 0, 180*fade )
    love.graphics.rectangle('fill', x, y, width, height)

    -- Draw text
    love.graphics.setColor( 255, 255, 255, 255*fade )
    love.graphics.print(current.headline, x + 10, y + 10)
    love.graphics.push()
    love.graphics.scale( 0.5, 0.5 )
    love.graphics.printf(current.description, (x + 10) * 2, (y + 21) * 2, (width - 20) * 2, "left")
    love.graphics.pop()


    love.graphics.setColor( 255, 255, 255, 255 )
end

---
-- Messy logic for individual achievements
-- @param label
-- @return nil
function AchievementTracker:onAchieve(label)
    local count = self:getCount(label)
    local current_level = CurrentLevel()
    local level_name = current_level.name

    -- Room entering and anticheat code
    if label:find('enter ') == 1 then
        level_name = label:sub(7)
        self:setCount("damage in " .. level_name, 0)
        self:setCount("room timer", 0)

        -- Achievements are totally disabled for cheaters.
        local cheater = cheatsEnabled()
        if cheater and self:getCount('cheat indicator') == 0 then
            self:achieve('cheat indicator')
            self:setCount('cheat indicator okay', 0)
        elseif not cheater and self:getCount('cheat indicator') == 1 then
            self:achieve('cheat indicator okay')
            self:setCount('cheat indicator', 0)
        end
        timer = 0
    end
    if self:getCount('cheat indicator') == 1 then
        return
    end
    -- The Floor Is Lava
    if label == 'cross town ->' then
        local floor_contacts = self:getCount('town floor-contacts ->')
        if floor_contacts == 0 then
            self:achieve("the floor is lava")
        end
        self:achieve('town floor-contacts')
    elseif label == 'cross town <-' then
        local floor_contacts = self:getCount('town floor-contacts <-')
        if floor_contacts == 0 then
            self:achieve("the floor is lava")
        end
        self:achieve('town floor-contacts')
    elseif label == 'town floor-contacts' then
        self:achieve('town floor-contacts ->')
        self:achieve('town floor-contacts <-')
    -- Punch Your Butt
    elseif label == 'hallway floor-contacts' then
        self:setCount('hippy kill rebounds', 0)
    elseif label == 'hippy killed by player' then
        self:achieve('hippy kill rebounds')
        self:achieve('recent hippy kills')
    elseif label == 'hippy kill rebounds' then
        if count == 5 then
            self:achieve('punch your butt')
        end
    -- Safety First
    elseif label == "damage" then
        self:achieve("damage in " .. level_name)
        self:achieve("damage in " .. level_name .. " (all time)")
    elseif label == "hallway right end" then
        if self:getCount("damage in hallway") == 0 then
            -- Best Athlete on Campus (display before Safety First)
            if self:getCount('room timer') < 25 and self:getCount('recent hippy kills') == 0 then
                self:achieve('best athlete on campus')
            end
            self:achieve("safety first")
            -- Prevent immediate re-achieving. Shouldn't f*** up long-term stats
            self:setCount("damage in hallway", 1)
        end
    elseif label == "leave hallway" then
        self:setCount('recent hippy kills', 0)
    end
end

return AchievementTracker
