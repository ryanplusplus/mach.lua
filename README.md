mock.lua
========

Simple mocking framework for Lua based on CppUTest

## Mocking a Function

    mock = require 'Mock'
    
    local f = mock:function()

    mock(f):shouldBeCalled():
    when(function() f() end)
    
## Mocking a Method

    mock = require 'Mock'
    
    o = {}
    o.m = mock:method()

    mock(m):shouldBeCalled():
    when(function() o:m() end)

## Mocking a Table

    mock = require 'Mock'
    
    someTable = {
      foo = function() end,
      bar = function() end
    }
    
    mockedTable = mock:table(someTable)

    mock(mockedTable.foo):shouldBeCalled():
    when(function() mockedTable.foo() end)
    
## Mocking an Object

    mock = require 'Mock'
    
    someObject = {}
    function someObject:foo() end
    function someObject:bar() end
    
    mockedObject = mock:object(someObject)
    
    mock(mockedObject.foo):shouldBeCalled():
    when(function() mockedObject:foo() end)
    
## Multiple Expectations

    mock = require 'Mock'
    
    local f1 = mock:function()
    local f2 = mock:function()

    mock(f1):shouldBeCalled():
    andAlso(mock(f2):shouldBeCalled()):
    when(function() f1(); f2() end)
