local Mock = {}

local subscriber

local function mockHandle(callback, thunk)
  subscriber = callback
  thunk()
  subscriber = nil
end

local function mockCalled(m, name, args)
  return subscriber(m, name, args)
end

ExpectedCall = {}

function ExpectedCall:new(f, args)
  local o = {
    _f = f,
    _args = args,
    _return = {}
  }

  self.__index = self
  setmetatable(o, self)

  return o
end

function ExpectedCall:functionMatches(f)
  return f == self._f
end

function ExpectedCall:argsMatch(args)
  if #self._args ~= #args then return false end

  for k in ipairs(self._args) do
    if self._args[k] ~= args[k] then return false end
  end

  return true
end

function ExpectedCall:setReturnValues(...)
  self._return = table.pack(...)
end

function ExpectedCall:getReturnValues(...)
  return table.unpack(self._return)
end

MockExpectation = {}

function MockExpectation:new(m)
  local o = {
    _m = m,
    _callSpecified = false,
    _calls = {}
  }

  self.__index = self
  setmetatable(o, self)

  return o
end

function MockExpectation:andWillReturn(...)
  if not self._callSpecified then
    error('cannot set return value for an unspecified call', 2)
  end

  self._calls[#self._calls]:setReturnValues(...)

  return self
end

function MockExpectation:when(thunk)
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
          return table.remove(self._calls, i):getReturnValues()
        end
      end
    end

    if not validFunctionFound then
      error('unexpected function "' .. name .. '" called', 2)
    else
      error('unexpected arguments provided to function "' .. name .. '"', 2)
    end
  end

  mockHandle(called, thunk)

  assert(#self._calls == 0, 'not all calls occurred')
end

function MockExpectation:after(thunk)
  if not self._callSpecified then
    error('incomplete expectation', 2)
  end

  self:when(thunk)
end

function MockExpectation:andThen(other)
  -- Need to handle ordering
  for _, call in ipairs(other._calls) do
    table.insert(self._calls, call)
  end

  return self
end

function MockExpectation:andAlso(other)
  -- Need to handle ordering
  for _, call in ipairs(other._calls) do
    table.insert(self._calls, call)
  end

  return self
end

function MockExpectation:shouldBeCalledWith(...)
  if self._callSpecified == true then
    error('call already specified', 2)
  end

  self._callSpecified = true
  table.insert(self._calls, ExpectedCall:new(self._m, table.pack(...)))
  return self
end

function MockExpectation:shouldBeCalled()
  if self._callSpecified == true then
    error('call already specified', 2)
  end

  return self:shouldBeCalledWith()
end

function MockExpectation:multipleTimes(times)
  for i = 1, times - 1 do
    table.insert(self._calls, self._calls[#self._calls])
  end

  return self
end

function Mock:mockFunction(name)
  name = name or '<anonymous>'
  local f

  function f(...)
    return mockCalled(f, name, table.pack(...))
  end

  return f
end

function Mock:mockMethod(name)
  name = name or '<anonymous>'
  local m

  function m(...)
    local args = table.pack(...)
    table.remove(args, 1)
    return mockCalled(m, name, args)
  end

  return m
end

function Mock:mockTable(t, name)
  name = name or '<anonymous>'
  local mocked = {}

  for k, v in pairs(t) do
    if type(v) == 'function' then
      mocked[k] = self:mockFunction(name .. '.' .. tostring(k))
    end
  end

  return mocked
end

function Mock:mockObject(o, name)
  name = name or '<anonymous>'
  local mocked = {}

  for k, v in pairs(o) do
    if type(v) == 'function' then
      mocked[k] = self:mockMethod(name .. ':' .. tostring(k))
    end
  end

  return mocked
end

setmetatable(Mock, { __call = function(_, ...) return MockExpectation:new(...) end })

return Mock
