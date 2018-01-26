local function pairs_sorted_by_key(t)
  return coroutine.wrap(function()
    local _pairs = {}
    for k, v in pairs(t) do
      table.insert(_pairs, { k, v })
    end
    table.sort(_pairs, function(x, y) return tostring(x[1]) < tostring(y[1]) end)
    for _, pair in ipairs(_pairs) do
      coroutine.yield(table.unpack(pair))
    end
  end)
end

local function format_value(v)
  if getmetatable(v) and getmetatable(v).__tostring then
    return tostring(v)
  elseif type(v) == 'string' then
    return "'" .. v .. "'"
  elseif type(v) == 'table' then
    local elements = {}
    for k, v in pairs_sorted_by_key(v) do
      table.insert(elements, '[' .. format_value(k) .. '] = ' .. format_value(v))
    end
    if #elements > 0 then
      return '{ ' .. table.concat(elements, ', ') .. ' }'
    else
      return '{}'
    end
  else
    return tostring(v)
  end
end

return format_value
