local ExpectedCall = require 'mach.ExpectedCall'
local unexpected_call_error = require 'mach.unexpected_call_error'
local unexpected_args_error = require 'mach.unexpected_args_error'

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
  -- if not self._call_specified then
  --   error('cannot set return value for an unspecified call', 2)
  -- end

  self._calls[#self._calls]:set_error(...)

  return self
end

function expectation:when(thunk)
  if not self._call_specified then
    error('incomplete expectation', 2)
  end

  local function called(m, name, args)
    local valid_function_found = false

    for i, call in ipairs(self._calls) do
      if call:function_matches(m) then
        valid_function_found = true

        if call:args_match(args) then
          if call:has_fixed_order() and i > 1 then
            self._calls[i - 1]:fix_order()
          end

          table.remove(self._calls, i)

          if call:has_error() then
            error(call:get_error())
          end

          return call:get_return_values()
        end
      end

      if call:has_fixed_order() then break end
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
  self._calls[#self._calls]:fix_order()

  for _, call in ipairs(other._calls) do
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

function expectation:should_be_called_with(...)
  if self._call_specified == true then
    error('call already specified', 2)
  end

  self._call_specified = true
  table.insert(self._calls, ExpectedCall(self._m, true, table.pack(...)))
  return self
end

function expectation:should_be_called()
  if self._call_specified == true then
    error('call already specified', 2)
  end

  return self:should_be_called_with()
end

function expectation:may_be_called_with(...)
  if self._call_specified == true then
    error('call already specified', 2)
  end

  self._call_specified = true
  table.insert(self._calls, ExpectedCall(self._m, false, table.pack(...)))
  return self
end

function expectation:may_be_called()
  if self._call_specified == true then
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
