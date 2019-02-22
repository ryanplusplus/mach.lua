mach.lua
========

Simple mocking framework for Lua inspired by CppUMock and designed for readability.

## Mocking a Function

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called().when(function() f() end)
```

## Mocking a Method

```lua
local mach = require 'mach'

local o = {}
o.m = mach.mock_method('m')

o.m.should_be_called().when(function() o:m() end)
```

## Mocking a Table

```lua
local mach = require 'mach'

local some_table = {
  foo = function() end,
  bar = function() end
}

mocked_table = mach.mock_table(some_table, 'some_table')

mocked_table.foo.should_be_called().when(function()
  mocked_table.foo()
end)
```

## Mocking an Object

```lua
local mach = require 'mach'

local some_object = {}
function some_object:foo() end
function some_object:bar() end

mocked_object = mach.mock_object(some_object, 'some_object')

mocked_object.foo.should_be_called().when(function()
  mocked_object:foo()
end)
```

## Ignoring Arguments

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called_with_any_arguments().when(function() f('any', 'args', 'are', 'fine') end)
```

## Returning Values

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called().and_will_return(1, 4).when(function()
  local x, y = f()
end)

f.should_be_called().with_result(1, 4).when(function()
  local x, y = f()
end)
```

## Raising Errors

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called().and_will_raise_error('some error').when(function()
  f()
end)
```

## Multiple Calls to the Same Function

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called().multiple_times(2).when(function()
  f()
  f()
end)
```

## Multiple Expectations

```lua
local mach = require 'mach'

local f1 = mach.mock_function('f1')
local f2 = mach.mock_function('f2')

f1.should_be_called()
  .and_also(f2.should_be_called())
  .when(function()
    f1()
    f2()
  end)
```

## Optional Expectations

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.may_be_called().when(function() end)
```

## Optional Ordering

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

-- Use and_then when order is important
f.should_be_called_with(1)
  .and_then(f.should_be_called_with(2))
  .when(function()
    f(2) -- Error, out of order call
    f(1)
  end)

-- Use and_also when order is unimportant
f.should_be_called_with(1)
  .and_also(f.should_be_called_with(2))
  .when(function()
    f(2) -- No error, order is not fixed when 'and_also' is used
    f(1)
  end)
```

## Mixed Ordering

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called_with(1)
  .and_also(f.should_be_called_with(2))
  .and_then(f.should_be_called_with(3))
  .and_also(f.should_be_called_with(4))
  .when(function()
    f(2)
    f(1)
    f(4)
    f(3)
  end)
```

## Matching Arguments Using Deep Compare

```lua
local mach = require 'mach'

local f = mach.mockFunction();

f.should_be_called_with(mach.match({ 1, 2, 3 }))
  .when(function()
    f({ 1, 2, 3 })
  end)
```

## Matching Arguments Using a Custom Matcher

```lua
local mach = require 'mach'

local custom_matcher = function(a, b)
  return a[1] == b[1]
end

local f = mach.mockFunction();

f.should_be_called_with(mach.match({ 1, 2, 3 }, custom_matcher))
  .when(function()
    f({ 1, 4, 9 })
  end)
```

## Matching Any Single Argument

```lua
local mach = require 'mach'

local f = mach.mockFunction();

f.should_be_called_with(mach.any, 42)
  .when(function()
    f({ 'whatever' }, 42)
  end)
```

## Ignoring Other Calls

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called().and_other_calls_should_be_ignored().when(function()
  f()
  f(1)
end)
```

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

f.should_be_called().with_other_calls_ignored().when(function()
  f()
  f(1)
end)
```

## Ignoring All Calls

```lua
local mach = require 'mach'

local f = mach.mock_function('f')

mach.ignore_mocked_calls_when(function()
  f()
  f(1, 2, 3)
end)
```

## Flexible Syntax

```lua
local mach = require 'mach'

local m1 = mach.mock_function('m1')
local m2 = mach.mock_function('m2')

function something_should_happen()
  return m1.should_be_called()
end

function another_thing_should_happen()
  return m2.should_be_called_with(1, 2, 3)
end

function the_code_under_test_runs()
  m1()
  m2(1, 2, 3)
end

-- Actual test:
something_should_happen()
  .and_also(another_thing_should_happen())
  .when(the_code_under_test_runs)
```

## Handy Error messages

```lua
local mach = require 'mach'

local f1 = mach.mock_function('f1')
local f2 = mach.mock_function('f2')
local f2 = mach.mock_function('f3')

f1.should_be_called_with(1)
  .and_also(f2.should_be_called_with(2))
  .when(function()
    f1(1)
    f3(3)
  end)
```

```
Unexpected function call f3(3)
Completed calls:
  f1(1)
Incomplete calls:
  f2(2)
```
