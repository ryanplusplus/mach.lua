local format_call_status = require 'mach.format_call_status'
local format_arguments = require 'mach.format_arguments'

return function(name, args, completed_calls, incomplete_calls, level)
  local error_message =
    'Unexpected arguments ' .. format_arguments(args) .. ' provided to function ' .. name ..
    format_call_status(completed_calls, incomplete_calls)

  error(error_message, level + 1)
end
