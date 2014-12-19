local ExpectedCall = require 'mach.expected-call'
local Expectation = require 'mach.expectation'
local UnexpectedCallError = require 'mach.unexpected-call-error'

local Mock = {}

function unexpectedCall(m, name, args)
  UnexpectedCallError(name, args, 2)
end

local subscriber = unexpectedCall

function handleMockCalls(callback, thunk)
  subscriber = callback
  thunk()
  subscriber = unexpectedCall
end

function mockCalled(m, name, args)
  return subscriber(m, name, args)
end

function Mock.mockFunction(name)
  name = name or '<anonymous>'
  local f = {}

  function fCall(_, ...)
    return mockCalled(f, name, table.pack(...))
  end

  setmetatable(f, {__call = fCall})

  return f
end

function Mock.mockMethod(name)
  name = name or '<anonymous>'
  local m = {}

  function mCall(_, _, ...)
    local args = table.pack(...)
    return mockCalled(m, name, args)
  end

  setmetatable(m, {__call = mCall})

  return m
end

function isCallable(x)
  local isFunction = type(x) == 'function'
  local hasCallMetamethod = type((debug.getmetatable(x) or {}).__call) == 'function'
  return isFunction or hasCallMetamethod
end

function Mock.mockTable(t, name)
  name = name or '<anonymous>'
  local mocked = {}

  for k, v in pairs(t) do
    if isCallable(v) then
      mocked[k] = Mock.mockFunction(name .. '.' .. tostring(k))
    end
  end

  return mocked
end

function Mock.mockObject(o, name)
  name = name or '<anonymous>'
  local mocked = {}

  for k, v in pairs(o) do
    if isCallable(v) then
      mocked[k] = Mock.mockMethod(name .. ':' .. tostring(k))
    end
  end

  return mocked
end

setmetatable(Mock, { __call = function(_, ...) return Expectation(...) end })

return Mock
