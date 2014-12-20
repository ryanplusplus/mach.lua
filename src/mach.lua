local ExpectedCall = require 'mach.ExpectedCall'
local Expectation = require 'mach.Expectation'
local unexpected_call_error = require 'mach.unexpected_call_error'

local mach = {}

function unexpected_call(m, name, args)
  unexpected_call_error(name, args, 2)
end

local subscriber = unexpected_call

function handle_mock_calls(callback, thunk)
  subscriber = callback
  thunk()
  subscriber = unexpected_call
end

function mock_called(m, name, args)
  return subscriber(m, name, args)
end

function mach.mock_function(name)
  name = name or '<anonymous>'
  local f = {}

  function f_call(_, ...)
    return mock_called(f, name, table.pack(...))
  end

  setmetatable(f, {__call = f_call})

  return f
end

function mach.mock_method(name)
  name = name or '<anonymous>'
  local m = {}

  function mCall(_, _, ...)
    local args = table.pack(...)
    return mock_called(m, name, args)
  end

  setmetatable(m, {__call = mCall})

  return m
end

function is_callable(x)
  local is_function = type(x) == 'function'
  local has_call_metamethod = type((debug.getmetatable(x) or {}).__call) == 'function'
  return is_function or has_call_metamethod
end

function mach.mock_table(t, name)
  name = name or '<anonymous>'
  local mocked = {}

  for k, v in pairs(t) do
    if is_callable(v) then
      mocked[k] = mach.mock_function(name .. '.' .. tostring(k))
    end
  end

  return mocked
end

function mach.mock_object(o, name)
  name = name or '<anonymous>'
  local mocked = {}

  for k, v in pairs(o) do
    if is_callable(v) then
      mocked[k] = mach.mock_method(name .. ':' .. tostring(k))
    end
  end

  return mocked
end

setmetatable(mach, { __call = function(_, ...) return Expectation(...) end })

return mach
