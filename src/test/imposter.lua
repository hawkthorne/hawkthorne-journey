local Imposter = {}

Imposter.__index = function(table, key)
  if rawget(table, key) == nil then
    rawset(table, key, Imposter.new())
  end
  return rawget(table, key)
end

Imposter.__call = function(table)
  if rawget(table, 'returns') == nil then
    rawset(table, 'returns', Imposter.new())
  end
  return rawget(table, 'returns')
end

function Imposter.new()
  local imp = {}
  setmetatable(imp, Imposter)
  return imp
end

return Imposter
