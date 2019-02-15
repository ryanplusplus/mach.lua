local ExpectedCall = require 'mach.ExpectedCall'
local Expectation = require 'mach.Expectation'
local unexpected_call_error = require 'mach.unexpected_call_error'
local default_matcher = require 'mach.deep_compare_matcher'
local mach_match = require 'mach.match'

local mach = {}

mach.any = require 'mach.any'

table.pack = table.pack or function(...)
  return { n = select('#',...); ... }
end

table.unpack = table.unpack or unpack

local function unexpected_call(m, name, args)
  unexpected_call_error(name, args, {}, {}, 2)
end

local subscriber = unexpected_call

local function handle_mock_calls(callback, thunk)
  subscriber = callback
  thunk()
  subscriber = unexpected_call
end

local function mock_called(m, name, args)
  return subscriber(m, name, args)
end

local function CreateExpectation(o)
  return function(_, method)
    local function aux(self, ...)
      local expectation = Expectation(handle_mock_calls, self)
      if not expectation[method] then
        error("attempt to call a nil value (field '" .. method .. "')", 2)
      end
      return expectation[method](expectation, ...)
    end

    return function(self, ...)
      if self == o then
        return aux(self, ...)
      else
        return aux(o, self, ...)
      end
    end
  end
end

function mach.mock_function(name)
  name = name or '<anonymous>'
  local f = { _name = name }

  setmetatable(f, {
    __call = function(_, ...)
      return mock_called(f, name, table.pack(...))
    end,

    __index = CreateExpectation(f)
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

    __index = CreateExpectation(m)
  })

  return m
end

local function is_callable(x)
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

function mach.ignore_mocked_calls_when(thunk)
  subscriber = function() end
  thunk()
  subscriber = unexpected_call
end

return mach
