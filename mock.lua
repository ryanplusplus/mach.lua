local subscriber

local function unexpectedCall()
  error('unexpected mock function called')
end

local function mockHandle(callback, thunk)
  subscriber = callback
  thunk()
  subscriber = nil
end

local function mockCalled(m, args)
  return subscriber(m, args)
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
    _calls = {}
  }

  self.__index = self
  setmetatable(o, self)

  return o
end

function MockExpectation:andWillReturn(...)
  self._calls[#self._calls]:setReturnValues(...)
  return self
end

function MockExpectation:when(thunk)
  local function called(m, args)
    assert(#self._calls > 0, 'unexpected call')

    assert(self._calls[1]:functionMatches(m), 'unexpected function called')
    assert(self._calls[1]:argsMatch(args), 'unexpected arguments provided')

    return table.remove(self._calls, 1):getReturnValues()
  end

  mockHandle(called, thunk)

  assert(#self._calls == 0, 'not all calls occurred')
end

function MockExpectation:after(thunk)
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
  table.insert(self._calls, ExpectedCall:new(self._m, table.pack(...)))
  return self
end

function MockExpectation:shouldBeCalled()
  return self:shouldBeCalledWith()
end



local function createMockFunction()
  local f

  function f(...)
    return mockCalled(f, table.pack(...))
  end

  return f
end

local function createMockMethod()
  local m

  function m(...)
    local args = table.pack(...)
    table.remove(args, 1)
    return mockCalled(m, args)
  end

  return m
end

local function createMockTable(t)
  local mocked = {}

  for k, v in pairs(t) do
    if type(v) == 'function' then
      mocked[k] = createMockFunction()
    end
  end

  return mocked
end

local function createMockObject(o)
  local mocked = {}

  for k, v in pairs(o) do
    if type(v) == 'function' then
      mocked[k] = createMockMethod()
    end
  end

  return mocked
end

mock = {
  createMockFunction = createMockFunction,
  createMockTable = createMockTable,
  createMockMethod = createMockMethod,
  createMockObject = createMockObject
}

setmetatable(mock, {__call = function(_, ...) return MockExpectation:new(...) end})

return mock
