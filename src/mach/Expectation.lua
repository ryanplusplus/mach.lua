local ExpectedCall = require 'mach.ExpectedCall'
local CompletedCall = require 'mach.CompletedCall'
local unexpected_call_error = require 'mach.unexpected_call_error'
local unexpected_args_error = require 'mach.unexpected_args_error'
local out_of_order_call_error = require 'mach.out_of_order_call_error'
local not_all_calls_occurred_error = require 'mach.not_all_calls_occurred_error'

return function(handle_mock_calls, m)
  local o = {}
  local call_specified = false
  local calls = {}
  local completed_calls = {}
  local ignore_other_calls

  local function wrap(f)
    return function(self, ...)
      if not self or self == o then
        return f(...)
      else
        return f(self, ...)
      end
    end
  end

  o.and_will_return = wrap(function(...)
    if not call_specified then
      error('cannot set return value for an unspecified call', 2)
    end

    calls[#calls]:set_return_values(...)

    return o
  end)

  o.and_will_raise_error = wrap(function(...)
    if not call_specified then
      error('cannot set error for an unspecified call', 2)
    end

    calls[#calls]:set_error(...)

    return o
  end)

  o.when = wrap(function(thunk)
    if not call_specified then
      error('incomplete expectation', 2)
    end

    local current_call_index = 1

    local function called(m, name, args)
      local valid_function_found = false
      local incomplete_expectation_found = false

      for i = current_call_index, #calls do
        local call = calls[i]

        if call:function_matches(m) then
          valid_function_found = true

          if call:args_match(args) then
            if call:has_fixed_order() and incomplete_expectation_found then
              out_of_order_call_error(name, args, completed_calls, calls, 2)
            end

            if call:has_fixed_order() then
              current_call_index = i
            end

            table.remove(calls, i)

            table.insert(completed_calls, CompletedCall(name, args))

            if call:has_error() then
              error(call:get_error())
            end

            return call:get_return_values()
          end
        end

        if call:is_required() then
          incomplete_expectation_found = true;
        end
      end

      if not ignore_other_calls then
        if not valid_function_found then
          unexpected_call_error(name, args, completed_calls, calls, 2)
        else
          unexpected_args_error(name, args, completed_calls, calls, 2)
        end
      end
    end

    handle_mock_calls(called, thunk)

    for _, call in pairs(calls) do
      if call:is_required() then
        not_all_calls_occurred_error(completed_calls, calls, 2)
      end
    end
  end)

  o.after = wrap(function(thunk)
    if not call_specified then
      error('incomplete expectation', 2)
    end

    o.when(thunk)
  end)

  o.and_then = wrap(function(other)
    for i, call in ipairs(other._calls()) do
      if i == 1 then call:fix_order() end
      table.insert(calls, call)
    end

    return o
  end)

  o.and_also = wrap(function(other)
    for _, call in ipairs(other._calls()) do
      table.insert(calls, call)
    end

    return o
  end)

  o.should_be_called_with_any_arguments = wrap(function()
    if call_specified then
      error('call already specified', 2)
    end

    call_specified = true
    table.insert(calls, ExpectedCall(m, { required = true, args = table.pack(), ignore_args = true }))
    return o
  end)

  o.should_be_called_with = wrap(function(...)
    if call_specified then
      error('call already specified', 2)
    end

    call_specified = true
    table.insert(calls, ExpectedCall(m, { required = true, args = table.pack(...) }))
    return o
  end)

  o.should_be_called = wrap(function()
    if call_specified then
      error('call already specified', 2)
    end

    return o.should_be_called_with()
  end)

  o.may_be_called_with_any_arguments = wrap(function()
    if call_specified then
      error('call already specified', 2)
    end

    call_specified = true
    table.insert(calls, ExpectedCall(m, { required = false, ignore_args = true }))
    return o
  end)

  o.may_be_called_with = wrap(function(...)
    if call_specified then
      error('call already specified', 2)
    end

    call_specified = true
    table.insert(calls, ExpectedCall(m, { required = false, args = table.pack(...) }))
    return o
  end)

  o.may_be_called = wrap(function()
    if call_specified then
      error('call already specified', 2)
    end

    return o.may_be_called_with()
  end)

  o.multiple_times = wrap(function(times)
    for i = 1, times - 1 do
      table.insert(calls, calls[#calls])
    end

    return o
  end)

  o.and_other_calls_should_be_ignored = wrap(function()
    ignore_other_calls = true
    return o
  end)

  o._calls = function()
    return calls
  end

  o.with_other_calls_ignored = o.and_other_calls_should_be_ignored

  return o
end
