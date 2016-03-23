local ExpectedCall = require 'mach.ExpectedCall'
local Expectation = require 'mach.Expectation'
local unexpected_call_error = require 'mach.unexpected_call_error'
local default_matcher = require 'mach.deep_compare_matcher'
local mach_match = require 'mach.match'

local mach = {}

mach.any = require 'mach.any'

function unexpected_call(m, name, args)
  unexpected_call_error(name, args, {}, {}, 2)
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

function create_expectation(_, method)
  return function(self, ...)
    local expectation = Expectation(self)
    return expectation[method](expectation, ...)
  end
end

function mach.mock_function(name)
  name = name or '<anonymous>'
  local f = { _name = name }

  setmetatable(f, {
    __call = function(_, ...)
      return mock_called(f, name, table.pack(...))
    end,

    __index = create_expectation
  })

  return f
end

function mach.mock_method(name)
  name = name or '<anonymous>'
  local m = { _name = name }

  setmetatable(m, {
    __call = function(_, _, ...)
      local args = table.pack(...)
      return mock_called(m, name, args)
    end,

    __index = create_expectation
  })

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

function mach.match(value, matcher)
  return setmetatable({ value = value, matcher = matcher or default_matcher }, mach_match)
end

return setmetatable(mach, { __call = function(_, ...) return Expectation(...) end })
