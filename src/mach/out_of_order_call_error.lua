local format_call_status = require 'mach.format_call_status'
local format_arguments = require 'mach.format_arguments'

return function(name, args, completed_calls, incomplete_calls, level)
  local error_message =
    'out of order function call ' .. name .. format_arguments(args) ..
    format_call_status(completed_calls, incomplete_calls)

  error(error_message, level + 1)
end
