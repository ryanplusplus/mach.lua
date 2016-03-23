return function(args)
  local arg_strings = {}
  for i = 1, args.n do
    table.insert(arg_strings, tostring(args[i]))
  end

  return '(' .. table.concat(arg_strings, ', ') .. ')'
end
