local camera = require 'camera'
local window = require 'window'

local AchievementTracker = {}
AchievementTracker.__index = AchievementTracker

trophies = {
    ["the floor is lava"]={
        ["headline"]="The floor is lava",
        ["description"]="Get from one end of the town to the other without touching the ground.",
        ["icon"]=nil
    }
}

counters = {}
queue = {}
const_times = {}

const_times.total = 10
const_times.fadein = const_times.total * 1/5
const_times.fadeout = const_times.total * 4/5

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
    count = self:getCount(label)
    if label == 'start game' then
        if count == 1 then
            return self:achieve('adorable')
        end
    elseif label == 'die' then
        if count == 1 then
            return self:achieve("oh cool I'm alive")
        end
    elseif label == 'cross town ->' then
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
    end
end

return AchievementTracker
