local call_status_message = require 'mach.call_status_message'
local format_arguments = require 'mach.format_arguments'

return function(name, args, completed_calls, incomplete_calls, level)
  local message =
    'unexpected function call ' .. name .. format_arguments(args) ..
    call_status_message(completed_calls, incomplete_calls)

  error(message, level + 1)
end
