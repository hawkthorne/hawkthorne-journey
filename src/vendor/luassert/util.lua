local util = {}
function util.deepcompare(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  local mt1 = debug.getmetatable(t1)
  local mt2 = debug.getmetatable(t2)
  -- would equality be determined by metatable __eq?
  if mt1 and mt1 == mt2 and mt1.__eq then
    -- then use that unless asked not to
    if not ignore_mt then return t1 == t2 end
  else -- we can skip the deep comparison below if t1 and t2 share identity
    if t1 == t2 then return true end
  end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not util.deepcompare(v1,v2) then return false end
  end
  for k2,_ in pairs(t2) do
    -- only check wether each element has a t1 counterpart, actual comparison
    -- has been done in first loop above
    if t1[k2] == nil then return false end
  end
  return true
end

-----------------------------------------------
-- table.insert() replacement that respects nil values.
-- The function will use table field 'n' as indicator of the
-- table length, if not set, it will be added.
-- @param t table into which to insert
-- @param pos (optional) position in table where to insert. NOTE: not optional if you want to insert a nil-value!
-- @param val value to insert
-- @return No return values
function util.tinsert(...)
  -- check optional POS value
  local args = {...}
  local c = select('#',...)
  local t = args[1]
  local pos = args[2]
  local val = args[3]
  if c < 3 then
    val = pos
    pos = nil
  end
  -- set length indicator n if not present (+1)
  t.n = (t.n or #t) + 1
  if not pos then
    pos = t.n
  elseif pos > t.n then
    -- out of our range
    t[pos] = val
    t.n = pos
  end
  -- shift everything up 1 pos
  for i = t.n, pos + 1, -1 do
    t[i]=t[i-1]
  end
  -- add element to be inserted
  t[pos] = val
end
-----------------------------------------------
-- table.remove() replacement that respects nil values.
-- The function will use table field 'n' as indicator of the
-- table length, if not set, it will be added.
-- @param t table from which to remove
-- @param pos (optional) position in table to remove
-- @return No return values
function util.tremove(t, pos)
  -- set length indicator n if not present (+1)
  t.n = t.n or #t
  if not pos then
    pos = t.n
  elseif pos > t.n then
    -- out of our range
    t[pos] = nil
    return
  end
  -- shift everything up 1 pos
  for i = pos, t.n do
    t[i]=t[i+1]
  end
  -- set size, clean last
  t[t.n] = nil
  t.n = t.n - 1
end

-----------------------------------------------
-- Checks an element to be callable.
-- The type must either be a function or have a metatable
-- containing an '__call' function.
-- @param object element to inspect on being callable or not
-- @return boolean, true if the object is callable
function util.callable(object)
  return type(object) == "function" or type((debug.getmetatable(object) or {}).__call) == "function"
end

return util
