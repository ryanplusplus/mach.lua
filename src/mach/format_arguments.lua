return function(args)
  local arg_strings = {}
  for _, arg in ipairs(args) do
    table.insert(arg_strings, tostring(arg))
  end

  return '(' .. table.concat(arg_strings, ', ') .. ')'
end
