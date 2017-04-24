return function(v)
  if type(v) == 'string' then
    return "'" .. v .. "'"
  else
    return tostring(v)
  end
end
