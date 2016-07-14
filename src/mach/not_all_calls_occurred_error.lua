local format_call_status = require 'mach.format_call_status'

return function(completed_calls, incomplete_calls, level)
  local message =
    'Not all calls occurred' ..
    format_call_status(completed_calls, incomplete_calls)

  error(message, level + 1)
end
