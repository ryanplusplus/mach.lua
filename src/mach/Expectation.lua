local ExpectedCall = require 'mach.ExpectedCall'
local unexpected_call_error = require 'mach.unexpected_call_error'
local unexpected_args_error = require 'mach.unexpected_args_error'
local out_of_order_call_error = require 'mach.out_of_order_call_error'

local expectation = {}
expectation.__index = expectation

local function create(m)
  local o = {
    _m = m,
    _call_specified = false,
    _calls = {}
  }

  setmetatable(o, expectation)

  return o
end

function expectation:and_will_return(...)
  if not self._call_specified then
    error('cannot set return value for an unspecified call', 2)
  end

  self._calls[#self._calls]:set_return_values(...)

  return self
end

function expectation:and_will_raise_error(...)
  if not self._call_specified then
    error('cannot set error for an unspecified call', 2)
  end

  self._calls[#self._calls]:set_error(...)

  return self
end

function expectation:when(thunk)
  if not self._call_specified then
    error('incomplete expectation', 2)
  end

  local current_call_index = 1

  local function called(m, name, args)
    local valid_function_found = false
    local incomplete_expectation_found = false

    for i = current_call_index, #self._calls do
      local call = self._calls[i]

      if call:function_matches(m) then
        valid_function_found = true

        if call:args_match(args) then
          if call:has_fixed_order() and incomplete_expectation_found then
            out_of_order_call_error(name, args, 2)
          end

          if call:has_fixed_order() then
            current_call_index = i
          end

          table.remove(self._calls, i)

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

    if not self._ignore_other_calls then
      if not valid_function_found then
        unexpected_call_error(name, args, 2)
      else
        unexpected_args_error(name, args, 2)
      end
    end
  end

  handle_mock_calls(called, thunk)

  for _, call in pairs(self._calls) do
    if call:is_required() then
      error('not all calls occurred', 2)
    end
  end
end

function expectation:after(thunk)
  if not self._call_specified then
    error('incomplete expectation', 2)
  end

  self:when(thunk)
end

function expectation:and_then(other)
  for _, call in ipairs(other._calls) do
    call:fix_order()
    table.insert(self._calls, call)
  end

  return self
end

function expectation:and_also(other)
  for _, call in ipairs(other._calls) do
    table.insert(self._calls, call)
  end

  return self
end

function expectation:should_be_called_with_any_arguments()
  if self._call_specified then
    error('call already specified', 2)
  end

  self._call_specified = true
  table.insert(self._calls, ExpectedCall(self._m, { required = true, ignore_args = true }))
  return self
end

function expectation:should_be_called_with(...)
  if self._call_specified then
    error('call already specified', 2)
  end

  self._call_specified = true
  table.insert(self._calls, ExpectedCall(self._m, { required = true, args = table.pack(...) }))
  return self
end

function expectation:should_be_called()
  if self._call_specified then
    error('call already specified', 2)
  end

  return self:should_be_called_with()
end

function expectation:may_be_called_with_any_arguments()
  if self._call_specified then
    error('call already specified', 2)
  end

  self._call_specified = true
  table.insert(self._calls, ExpectedCall(self._m, { required = false, ignore_args = true }))
  return self
end

function expectation:may_be_called_with(...)
  if self._call_specified then
    error('call already specified', 2)
  end

  self._call_specified = true
  table.insert(self._calls, ExpectedCall(self._m, { required = false, args = table.pack(...) }))
  return self
end

function expectation:may_be_called()
  if self._call_specified then
    error('call already specified', 2)
  end

  return self:may_be_called_with()
end

function expectation:multiple_times(times)
  for i = 1, times - 1 do
    table.insert(self._calls, self._calls[#self._calls])
  end

  return self
end

function expectation:and_other_calls_should_be_ignored()
  self._ignore_other_calls = true
  return self
end

return create
