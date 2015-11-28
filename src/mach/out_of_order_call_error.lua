return function(name, args, level)
  local arg_strings = {}
  for _, arg in ipairs(args) do
    table.insert(arg_strings, tostring(arg))
  end

  error('out of order function call ' .. name .. '(' .. table.concat(arg_strings, ', ') .. ')', level + 1)
end
