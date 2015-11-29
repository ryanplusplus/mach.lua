local function matches(o1, o2)
  if o1 == o2 then return true end

  if type(o1) == 'table' and type(o2) == 'table' then
    for k in pairs(o1) do
      if not matches(o1[k], o2[k]) then return false end
    end

    for k in pairs(o2) do
      if not matches(o1[k], o2[k]) then return false end
    end

    return true
  end

  return false
end

return matches
