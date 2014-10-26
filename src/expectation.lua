ExpectedCall = require 'expected-call'

local expectation = {}
expectation.__index = expectation

local function create(m)
  local o = {
    _m = m,
    _callSpecified = false,
    _calls = {}
  }

  setmetatable(o, expectation)

  return o
end

function expectation:andWillReturn(...)
  if not self._callSpecified then
    error('cannot set return value for an unspecified call', 2)
  end

  self._calls[#self._calls]:setReturnValues(...)

  return self
end

function expectation:when(thunk)
  if not self._callSpecified then
    error('incomplete expectation', 2)
  end

  local function called(m, name, args)
    assert(#self._calls > 0, 'unexpected call')

    local validFunctionFound = false

    for i, call in ipairs(self._calls) do
      if call:functionMatches(m) then
        validFunctionFound = true

        if call:argsMatch(args) then
          if call:hasFixedOrder() and i > 1 then
            self._calls[i - 1]:fixOrder()
          end

          return table.remove(self._calls, i):getReturnValues()
        end
      end

      if call:hasFixedOrder() then break end
    end

    if not validFunctionFound then
      error('unexpected function call ' .. name .. '(' .. table.concat(args, ', ') .. ')', 2)
    else
      error('unexpected arguments (' .. table.concat(args, ', ') .. ') provided to function ' .. name, 2)
    end
  end

  handleMockCalls(called, thunk)

  for _, call in pairs(self._calls) do
    if call:isRequired() then
      error('not all calls occurred', 2)
    end
  end
end

function expectation:after(thunk)
  if not self._callSpecified then
    error('incomplete expectation', 2)
  end

  self:when(thunk)
end

function expectation:andThen(other)
  self._calls[#self._calls]:fixOrder()

  for _, call in ipairs(other._calls) do
    table.insert(self._calls, call)
  end

  return self
end

function expectation:andAlso(other)
  for _, call in ipairs(other._calls) do
    table.insert(self._calls, call)
  end

  return self
end

function expectation:shouldBeCalledWith(...)
  if self._callSpecified == true then
    error('call already specified', 2)
  end

  self._callSpecified = true
  table.insert(self._calls, ExpectedCall(self._m, true, table.pack(...)))
  return self
end

function expectation:shouldBeCalled()
  if self._callSpecified == true then
    error('call already specified', 2)
  end

  return self:shouldBeCalledWith()
end

function expectation:mayBeCalledWith(...)
  if self._callSpecified == true then
    error('call already specified', 2)
  end

  self._callSpecified = true
  table.insert(self._calls, ExpectedCall(self._m, false, table.pack(...)))
  return self
end

function expectation:mayBeCalled()
  if self._callSpecified == true then
    error('call already specified', 2)
  end

  return self:mayBeCalledWith()
end

function expectation:multipleTimes(times)
  for i = 1, times - 1 do
    table.insert(self._calls, self._calls[#self._calls])
  end

  return self
end

return create
