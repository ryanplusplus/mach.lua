mock.lua
========

Simple mocking framework for Lua based on CppUMock

## Mocking a Function

    mock = require 'Mock'
    
    local f = mock:mockFunction()

    mock(f):shouldBeCalled():
    when(function() f() end)
    
## Mocking a Method

    mock = require 'Mock'
    
    o = {}
    o.m = mock:mockMethod()

    mock(m):shouldBeCalled():
    when(function() o:m() end)

## Mocking a Table

    mock = require 'Mock'
    
    someTable = {
      foo = function() end,
      bar = function() end
    }
    
    mockedTable = mock:mockTable(someTable)

    mock(mockedTable.foo):shouldBeCalled():
    when(function() mockedTable.foo() end)
    
## Mocking an Object

    mock = require 'Mock'
    
    someObject = {}
    function someObject:foo() end
    function someObject:bar() end
    
    mockedObject = mock:mockObject(someObject)
    
    mock(mockedObject.foo):shouldBeCalled():
    when(function() mockedObject:foo() end)
    
## Multiple Expectations

    mock = require 'Mock'
    
    local f1 = mock:mockFunction()
    local f2 = mock:mockFunction()

    mock(f1):shouldBeCalled():
    andAlso(mock(f2):shouldBeCalled()):
    when(function() f1(); f2() end)

## Extra Credit For Readability

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

    somethingShouldHappen():
    andAlso(anotherThingShouldHappen()):
    when(theCodeUnderTestRuns)
