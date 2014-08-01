describe('The mock library', function()
  mock = require 'mock'

  local function shouldFail(test)
    if pcall(test) then
      error('expected failure did not occur')
    end
  end

  local function shouldFailWith(expectedMessage, test)
    local result, actualMessage = pcall(test)
    _, _, actualMessage = actualMessage:find(":%w+: (.+)")

    if(result) then
      error('expected failure did not occur')
    elseif(actualMessage ~= expectedMessage) then
      error('expected failure message: "' .. expectedMessage .. '" did not match actual failure message: "' .. actualMessage .. '"')
    end
  end

  it('should allow you to verify that a function is called', function()
    local f = mock:mockFunction('f')

    mock(f):shouldBeCalled():
    when(function() f() end)
  end)

  it('should alert you when a function is not called', function()
    local f = mock:mockFunction('f')

    shouldFailWith('not all calls occurred', function()
      mock(f):shouldBeCalled():
      when(function() end)
    end)
  end)

  it('should alert you when the wrong function is called', function()
    local f1 = mock:mockFunction('f1')
    local f2 = mock:mockFunction('f2')

    shouldFailWith('unexpected function call f2() occurred', function()
      mock(f1):shouldBeCalled():
      when(function() f2() end)
    end)
  end)

  it('should alert you when a function is called unexpectedly', function()
    local f = mock:mockFunction('f')

    shouldFailWith('unexpected function call f() occurred', function()
      f()
    end)
  end)

  it('should allow you to verify that a function has been called with the correct arguments', function()
    local f = mock:mockFunction('f')

    mock(f):shouldBeCalledWith(1, '2'):
    when(function() f(1, '2') end)
  end)

  it('should alert you when a function has been called with incorrect arguments', function()
    local f = mock:mockFunction('f')

    shouldFail(function()
      mock(f):shouldBeCalledWith(1, '2'):
      when(function() f(1, '3') end)
    end)
  end)

  it('should allow you to specify the return value of a mocked function', function()
    local f = mock:mockFunction('f')

    mock(f):shouldBeCalled():andWillReturn(4):
    when(function()
      assert.is.equal(f(), 4)
    end)
  end)

  it('should allow you to specify multiple return values for a mocked function', function()
    local f = mock:mockFunction('f')

    mock(f):shouldBeCalled():andWillReturn(1, 2):
    when(function()
      r1, r2 = f()
      assert.is.equal(r1, 1)
      assert.is.equal(r2, 2)
    end)
  end)

  it('should allow you to check that a function has been called multiple times', function()
    local f = mock:mockFunction('f')

    mock(f):shouldBeCalled():
    andAlso(mock(f):shouldBeCalledWith(1, 2, 3)):
    when(function()
      f()
      f(1, 2, 3)
    end)
  end)

  it('should allow you to check that multiple functions are called', function()
    local f1 = mock:mockFunction('f1')
    local f2 = mock:mockFunction('f2')

    mock(f1):shouldBeCalled():
    andAlso(mock(f2):shouldBeCalledWith(1, 2, 3)):
    when(function()
      f1()
      f2(1, 2, 3)
    end)
  end)

  it('should allow you to mix and match call types', function()
    local f1 = mock:mockFunction('f1')
    local f2 = mock:mockFunction('f2')

    mock(f1):shouldBeCalled():
    andAlso(mock(f2):shouldBeCalledWith(1, 2, 3)):
    andThen(mock(f2):shouldBeCalledWith(1):andWillReturn(4)):
    when(function()
      f1()
      f2(1, 2, 3)
      assert.is.equal(f2(1), 4)
    end)
  end)

  it('should allow functions to be used to improve readability', function()
    local f1 = mock:mockFunction('f1')
    local f2 = mock:mockFunction('f1')

    function somethingShouldHappen()
      return mock(f1):shouldBeCalled()
    end

    function anotherThingShouldHappen()
      return mock(f2):shouldBeCalledWith(1, 2, 3)
    end

    function theCodeUnderTestRuns()
      f1()
      f2(1, 2, 3)
    end

    somethingShouldHappen():
    andAlso(anotherThingShouldHappen()):
    when(theCodeUnderTestRuns)
  end)

  it('should allow a table of functions to be mocked', function()
    local someTable = {
      foo = function() end,
      bar = function() end
    }

    mockedTable = mock:mockTable(someTable, 'someTable')

    mock(mockedTable.foo):shouldBeCalledWith(1):andWillReturn(2):
    andAlso(mock(mockedTable.bar):shouldBeCalled()):
    when(function()
      mockedTable.foo(1)
      mockedTable.bar()
    end)
  end)

  it('should fail when a function is incorrectly used as a method', function()
    shouldFail(function()
      local someTable = {
        foo = function() end
      }

      mockedTable = mock:mockTable(someTable)

      mock(mockedTable.foo):shouldBeCalledWith(1):andWillReturn(2):
      when(function()
        mockedTable:foo(1)
      end)
    end)
  end)

  it('should allow an object with methods to be mocked', function()
    local someObject = {}

    function someObject:foo() end
    function someObject:bar() end

    local mockedObject = mock:mockObject(someObject)

    mock(mockedObject.foo):shouldBeCalledWith(1):andWillReturn(2):
    andAlso(mock(mockedObject.bar):shouldBeCalled()):
    when(function()
      mockedObject:foo(1)
      mockedObject:bar()
    end)
  end)

  it('should allow mocking of any callable in an object, not just functions', function()
    local someTable = {
      foo = {}
    }

    setmetatable(someTable.foo, {__call = function() end})

    local mockedTable = mock:mockTable(someTable)

    mock(mockedTable.foo):shouldBeCalled():
    when(function() mockedTable.foo() end)
  end)

  it('should allow mocking of any callable in a table, not just functions', function()
    local someObject = {
      foo = {}
    }

    setmetatable(someObject.foo, {__call = function() end})

    local mockedObject = mock:mockObject(someObject)

    mock(mockedObject.foo):shouldBeCalled():
    when(function() mockedObject:foo() end)
  end)

  it('should fail when a method is incorrectly used as a function', function()
    shouldFail(function()
      local someObject = {}

      function someObject:foo() end

      local mockedObject = mock:mockObject(someObject)

      mock(mockedObject.foo):shouldBeCalledWith(1):andWillReturn(2):
      when(function()
        mockedObject.foo(1)
      end)
    end)
  end)

  it('should let you expect a function to be called multiple times', function()
    local f = mock:mockFunction('f')

    mock(f):shouldBeCalledWith(2):andWillReturn(1):multipleTimes(3):
    when(function()
      assert(f(2) == 1)
      assert(f(2) == 1)
      assert(f(2) == 1)
    end)
  end)

  it('should fail if a function is not called enough times', function()
    shouldFail(function()
      local f = mock:mockFunction()

      mock(f):shouldBeCalledWith(2):andWillReturn(1):multipleTimes(3):
      when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  it('should fail if a function is called too many times', function()
    shouldFail(function()
      local f = mock:mockFunction('f')

      mock(f):shouldBeCalledWith(2):andWillReturn(1):multipleTimes(2):
      when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  -- ordering

  -- allowed vs. not allowed functions on the expectation (ie: state machine for expectation)
end)
