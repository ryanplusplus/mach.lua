mach.lua
========

Simple mocking framework for Lua inspired by CppUMock and designed for readability.

## Mocking a Function

```lua
mach = require 'mach'

local f = mach.mockFunction()

mach(f):shouldBeCalled():
when(function() f() end)
```

## Mocking a Method

```lua
mach = require 'mach'

local o = {}
o.m = mach.mockMethod()

mach(m):shouldBeCalled():
when(function() o:m() end)
```

## Mocking a Table

```lua
mach = require 'mach'

local someTable = {
  foo = function() end,
  bar = function() end
}

mockedTable = mach.mockTable(someTable)

mach(mockedTable.foo):shouldBeCalled():
when(function() mockedTable.foo() end)
```

## Mocking an Object

```lua
mach = require 'mach'

local someObject = {}
function someObject:foo() end
function someObject:bar() end

mockedObject = mach.mockObject(someObject)

mach(mockedObject.foo):shouldBeCalled():
when(function() mockedObject:foo() end)
```

## Multiple Expectations

```lua
mach = require 'mach'

local f1 = mach.mockFunction()
local f2 = mach.mockFunction()

mach(f1):shouldBeCalled():
andAlso(mach(f2):shouldBeCalled()):
when(function() f1(); f2() end)
```

## Optional Expectations

```lua
mach = require 'mach'

local f = mach.mockFunction()

mach(f):mayBeCalled():
when(function() end)
```

## Optional Ordering

```lua
mach = require 'mach'

local f = mach.mockFunction()

-- Use andAlso when order is important
mach(f):shouldBeCalledWith(1):
andThen(mach(f):shouldBeCalledWith(2)):
when(function()
  f(2) -- Error, out of order call
  f(1)
end)

-- Use andAlso when order is unimportant
mach(f):shouldBeCalledWith(1):
andAlso(mach(f):shouldBeCalledWith(2)):
when(function()
  f(2) -- No error, order is not fixed when 'andAlso' is used
  f(1)
end)
```

## Mixed Ordering

```lua
mach = require 'mach'

local f = mach.mockFunction()

mach(f):shouldBeCalledWith(1):
andAlso(mach(f):shouldBeCalledWith(2)):
andThen(mach(f):shouldBeCalledWith(3)):
andAlso(mach(f):shouldBeCalledWith(4)):
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

local m1 = mach.mockFunction()
local m2 = mach.mockFunction()

function somethingShouldHappen()
  return mach(m1):shouldBeCalled()
end

function anotherThingShouldHappen()
  return mach(m2):shouldBeCalledWith(1, 2, 3)
end

function theCodeUnderTestRuns()
  m1()
  m2(1, 2, 3)
end

-- Actual test:
somethingShouldHappen():
andAlso(anotherThingShouldHappen()):
when(theCodeUnderTestRuns)
```
