mock.lua
========

Simple mocking framework for Lua inspired by CppUMock and designed for readability.

## Mocking a Function

```lua
mock = require 'Mock'

local f = mock:mockFunction()

mock(f):shouldBeCalled():
when(function() f() end)
```

## Mocking a Method

```lua
mock = require 'Mock'

local o = {}
o.m = mock:mockMethod()

mock(m):shouldBeCalled():
when(function() o:m() end)
```

## Mocking a Table

```lua
mock = require 'Mock'

local someTable = {
  foo = function() end,
  bar = function() end
}

mockedTable = mock:mockTable(someTable)

mock(mockedTable.foo):shouldBeCalled():
when(function() mockedTable.foo() end)
```

## Mocking an Object

```lua
mock = require 'Mock'

local someObject = {}
function someObject:foo() end
function someObject:bar() end

mockedObject = mock:mockObject(someObject)

mock(mockedObject.foo):shouldBeCalled():
when(function() mockedObject:foo() end)
```

## Multiple Expectations

```lua
mock = require 'Mock'

local f1 = mock:mockFunction()
local f2 = mock:mockFunction()

mock(f1):shouldBeCalled():
andAlso(mock(f2):shouldBeCalled()):
when(function() f1(); f2() end)
```

## Optional Expectations

```lua
mock = require 'Mock'

local f = mock:mockFunction()

mock(f):mayBeCalled():
when(function() end)
```

## Optional Ordering

```lua
mock = require 'Mock'

local f = mock:mockFunction()

-- Use andAlso when order is important
mock(f):shouldBeCalledWith(1):
andThen(mock(f):shouldBeCalledWith(2)):
when(function()
  f(2) -- Error, out of order call
  f(1)
end)

-- Use andAlso when order is unimportant
mock(f):shouldBeCalledWith(1):
andAlso(mock(f):shouldBeCalledWith(2)):
when(function()
  f(2) -- No error, order is not fixed when 'andAlso' is used
  f(1)
end)
```

## Mixed Ordering

```lua
mock = require 'Mock'

local f = mock:mockFunction()

mock(f):shouldBeCalledWith(1):
andAlso(mock(f):shouldBeCalledWith(2)):
andThen(mock(f):shouldBeCalledWith(3)):
andAlso(mock(f):shouldBeCalledWith(4)):
when(function()
  f(2)
  f(1)
  f(4)
  f(3)
end)
```

## Extra Credit For Readability

```lua
mock = require 'Mock'

local m1 = mock:mockFunction()
local m2 = mock:mockFunction()

function somethingShouldHappen()
  return mock(m1):shouldBeCalled()
end

function anotherThingShouldHappen()
  return mock(m2):shouldBeCalledWith(1, 2, 3)
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
