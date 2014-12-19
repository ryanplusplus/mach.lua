return function(name, args, level)
  local arg_strings = {}
  for _, arg in ipairs(args) do
    table.insert(arg_strings, tostring(arg))
  end

  error('unexpected arguments (' .. table.concat(arg_strings) .. ') provided to function ' .. name, level + 1)
end
