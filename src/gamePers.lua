--------------------------------------
---------gamePers.lua--------------
-----Created by HazardousPeach--------
--Handles all game persistence--------
--------------------------------------

require 'vendor/json'
version = "100" -- This is the version without the decimal point, to two decimal places. For example, if we are on version 1.23, this is 123. 
path = 'saveFile.sv' .. version

Persistence = {}

---
-- Saves a list of objects to the savefile.
-- @param listOfObjects the list of objects to save.
-- @returns nil
function Persistence.Save(listOfObjects)
    local jsonString = json.encode(listOfObjects)
    love.filesystem.write(path, jsonString)
end

---
-- Loads a list of objects from the save file
-- @returns the list of objects loaded.
function Persistence.Load()
    if love.filesystem.exists(path) then 
        jsonString = love.filesystem.read(path)
        return json.decode(jsonString)
    end
    return nil
end

return Persistence