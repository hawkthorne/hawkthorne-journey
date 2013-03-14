local json = require 'hawk/json'

local function getLocale(lang, locale)
  local path = 'locales/' .. lang .. '-' .. locale .. '.json'
  assert(love.filesystem.exists(path), string.format("The locale %q-%q is unknown", lang, locale))
  local contents, _  = love.filesystem.read(path)
  return json.decode(contents)
end

local i18n = {}
local currentLocale = "en-US"
local strings = getLocale("en", "US")

local function translate(id)
  local result = strings[id]
  assert(result, string.format("The id %q was not found in the current locale (%q)", id, currentLocale))
  return result
end

function i18n.getLocales()
  local langs = {}
  -- will return a list of available language files
  for i,p in pairs(love.filesystem.enumerate('languages')) do
    local name = p:gsub('.json', '')
    table.insert(langs, name)
  end
  return langs
end

function i18n.getCurrentLocale()
  return currentLocale
end

function i18n.setLocale(lang, locale)
  currentLocale = lang .. '-' .. locale
  strings = getLocale(lang, locale) 
end

i18n.translate = translate

setmetatable(i18n, {__call = function(_, id) return translate(id) end})

return i18n
