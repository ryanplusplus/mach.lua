mach.lua
========

Simple mocking framework for Lua inspired by CppUMock and designed for readability.

## Mocking a Function

```lua
mach = require 'mach'

local f = mach.mock_function()

mach(f):should_be_called():
when(function() f() end)
```

## Mocking a Method

```lua
mach = require 'mach'

local o = {}
o.m = mach.mach_method()

mach(m):should_be_called():
when(function() o:m() end)
```

## Mocking a Table

```lua
mach = require 'mach'

local some_table = {
  foo = function() end,
  bar = function() end
}

mocked_table = mach.mockTable(some_table)

mach(mocked_table.foo):should_be_called():
when(function() mocked_table.foo() end)
```

## Mocking an Object

```lua
mach = require 'mach'

local some_object = {}
function some_object:foo() end
function some_object:bar() end

mocked_object = mach.mock_object(some_object)

mach(mocked_object.foo):should_be_called():
when(function() mocked_object:foo() end)
```

## Multiple Expectations

```lua
mach = require 'mach'

local f1 = mach.mock_function()
local f2 = mach.mock_function()

mach(f1):should_be_called():
and_also(mach(f2):should_be_called()):
when(function() f1(); f2() end)
```

## Optional Expectations

```lua
mach = require 'mach'

local f = mach.mock_function()

mach(f):mayBeCalled():
when(function() end)
```

## Optional Ordering

```lua
mach = require 'mach'

local f = mach.mock_function()

-- Use and_also when order is important
mach(f):should_be_calledWith(1):
andThen(mach(f):should_be_calledWith(2)):
when(function()
  f(2) -- Error, out of order call
  f(1)
end)

-- Use and_also when order is unimportant
mach(f):should_be_calledWith(1):
and_also(mach(f):should_be_calledWith(2)):
when(function()
  f(2) -- No error, order is not fixed when 'and_also' is used
  f(1)
end)
```

## Mixed Ordering

```lua
mach = require 'mach'

local f = mach.mock_function()

mach(f):should_be_calledWith(1):
and_also(mach(f):should_be_calledWith(2)):
andThen(mach(f):should_be_calledWith(3)):
and_also(mach(f):should_be_calledWith(4)):
when(function()
  f(2)
  f(1)
  f(4)
  f(3)
end)
```

## Flexible Syntax

```lua
mach = require 'mach'

local m1 = mach.mock_function()
local m2 = mach.mock_function()

function something_should_happen()
  return mach(m1):should_be_called()
end

function another_thing_should_happen()
  return mach(m2):should_be_calledWith(1, 2, 3)
end

function the_code_under_test_runs()
  m1()
  m2(1, 2, 3)
end

-- Actual test:
something_should_happen():
and_also(another_thing_should_happen()):
when(the_code_under_test_runs)
```
