local AchievementTracker = {}
AchievementTracker.__index = AchievementTracker

trophies = {
    ["adorable"]={
        ["headline"]="Aww, we're adorable",
        ["description"]="Start a new game",
        ["icon"]=nil
    },
    ["oh cool I'm alive"]={
        ["headline"]="Oh cool, I'm alive!",
        ["description"]="Die once",
        ["icon"]=nil
    }
}

counters = {}

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
    print(info.headline .. '\n\n\t' .. info.description)
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
    end
end

return AchievementTracker
