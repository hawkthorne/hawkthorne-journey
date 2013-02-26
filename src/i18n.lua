local i18n = {}
i18n.__index = i18n

function i18n.new( default )
    local I18n = {}
    setmetatable(I18n, i18n)
    
    I18n.default = default
    I18n.langs = {}
    for i,p in pairs( love.filesystem.enumerate( 'languages' ) ) do
        -- bring in the data from the character file
        local lang = p:gsub('.lua', '')
        I18n.langs[lang] = require( 'languages/' .. lang )
    end

    return I18n
end

function i18n:getLangs()
    -- will return a list of available languages
end

function i18n:setLang( lang )
    assert( self.langs[lang], 'Unknown language: ' .. lang )
    self.default = lang
end

function i18n:get( v )
    return self.langs[self.default][v] or self.langs['english'][v]
end

return i18n.new('english')