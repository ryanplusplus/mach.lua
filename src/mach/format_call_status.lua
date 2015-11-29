return function(completed_calls, incomplete_calls)
  local incomplete_call_strings = {}
  for _, incomplete_call in ipairs(incomplete_calls) do
    table.insert(incomplete_call_strings, tostring(incomplete_call))
  end

  local completed_call_strings = {}
  for _, completed_call in ipairs(completed_calls) do
    table.insert(completed_call_strings, tostring(completed_call))
  end

  local message = ''

  if #completed_calls > 0 then
    message = message ..
      '\nCompleted calls:' ..
      '\n\t' .. table.concat(completed_call_strings, '\n\t')
  end

  if #incomplete_calls > 0 then
    message = message ..
      '\nIncomplete calls:' ..
      '\n\t' .. table.concat(incomplete_call_strings, '\n\t')
  end

  return message
end
