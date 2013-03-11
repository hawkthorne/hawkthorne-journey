require 'vendor/json'

local i18n = {}
i18n.__index = i18n

function i18n.new(lang, locale)
  local I18n = {}
  setmetatable(I18n, i18n)

  I18n.locale = nil
  I18n:setLocale(lang, locale)

  return I18n
end

function i18n:getLocales()
  local langs = {}
  -- will return a list of available language files
  for i,p in pairs(love.filesystem.enumerate('languages')) do
    local name = p:gsub('.json', '')
    table.insert(langs, name)
  end
  return langs
end

function i18n:setLocale(lang, locale)
  local contents, _  = love.filesystem.read('languages/' .. lang .. '-' .. locale .. '.json')
  self.locale = json.decode(contents)
end

function i18n:get(v)
  return self.locale[v]
end

return i18n.new('en', 'US')
