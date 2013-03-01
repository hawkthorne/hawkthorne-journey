local i18n = {}
i18n.__index = i18n

function i18n.new( lang )
    local I18n = {}
    setmetatable(I18n, i18n)
    
    I18n.langs = {}
    I18n:setLang( lang )
    
    return I18n
end

function i18n:getLangs()
    local langs = {}
    -- will return a list of available language files
    for i,p in pairs( love.filesystem.enumerate( 'languages' ) ) do
        local name = p:gsub('.lua', '')
        table.insert( langs, name )
    end
    return langs
end

function i18n:setLang( lang )
    self.current = lang
    -- bring in the data from the character file
    if not self.langs[self.current] then
        self.langs[self.current] = require( 'languages/' .. self.current )
    end
end

function i18n:get( v )
    return self.langs[self.current][v] or self.langs['english'][v]
end

return i18n.new('english')