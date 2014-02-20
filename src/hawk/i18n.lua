local json = require 'hawk/json'
local middle = require 'hawk/middleclass'

local i18n = middle.class("i18n")

function i18n:initialize(path, locale)
  self.path = path
  self:setLocale("en-US")
end

function i18n:getLocale(locale)
  local path = self.path .. "/" .. locale .. '.json'
  assert(love.filesystem.exists(path), string.format("The locale %q is unknown", locale))
  local contents, _  = love.filesystem.read(path)
  return json.decode(contents)
end

function i18n:translate(id)
  local result = self.strings[id]
  assert(result, string.format("The id %q was not found in the current locale (%q)", id, self.currentLocale))
  return result
end

function i18n:__call(id)
  return self:translate(id)
end

function i18n:getLocales()
  local langs = {}
  -- will return a list of available language files
  for i,p in pairs(love.filesystem.getDirectoryItems(self.path)) do
    local name = p:gsub('.json', '')
    table.insert(langs, name)
  end
  return langs
end

function i18n:getCurrentLocale()
  return self.currentLocale
end

function i18n:setLocale(locale)
  self.currentLocale = locale
  self.strings = self:getLocale(locale) 
end

return i18n
