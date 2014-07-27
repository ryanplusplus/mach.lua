describe('The mock library', function()
  mock = require 'mock'

  local function shouldFail(test)
    if pcall(test) then
      error('expected failure did not occur')
    end
  end

  it('should allow you to verify that a function is called', function()
    local m = mock:mockFunction()

    mock(m):shouldBeCalled():
    when(function() m() end)
  end)

  it('should alert you when a function is not called', function()
    local m = mock:mockFunction()

    shouldFail(function()
      mock(m):shouldBeCalled():
      when(function() end)
    end)
  end)

  it('should alert you when the wrong function is called', function()
    local m1 = mock:mockFunction()
    local m2 = mock:mockFunction()

    shouldFail(function()
      mock(m1):shouldBeCalled():
      when(function() m2() end)
    end)
  end)

  it('should alert you when a function is called unexpectedly', function()
    local m = mock:mockFunction()

    shouldFail(function()
      m()
    end)
  end)

  it('should allow you to verify that a function has been called with the correct arguments', function()
    local m = mock:mockFunction()

    mock(m):shouldBeCalledWith(1, '2'):
    when(function() m(1, '2') end)
  end)

  it('should alert you when a function has been called with incorrect arguments', function()
    local m = mock:mockFunction()

    shouldFail(function()
      mock(m):shouldBeCalledWith(1, '2'):
      when(function() m(1, '3') end)
    end)
  end)

  it('should allow you to specify the return value of a mocked function', function()
    local m = mock:mockFunction()

    mock(m):shouldBeCalled():andWillReturn(4):
    when(function()
      assert.is.equal(m(), 4)
    end)
  end)

  it('should allow you to specify multiple return values for a mocked function', function()
    local m = mock:mockFunction()

    mock(m):shouldBeCalled():andWillReturn(1, 2):
    when(function()
      r1, r2 = m()
      assert.is.equal(r1, 1)
      assert.is.equal(r2, 2)
    end)
  end)

  it('should allow you to check that a function has been called multiple times', function()
    local m = mock:mockFunction()

    mock(m):shouldBeCalled():
    andAlso(mock(m):shouldBeCalledWith(1, 2, 3)):
    when(function()
      m()
      m(1, 2, 3)
    end)
  end)

  it('should allow you to check that multiple functions are called', function()
    local m1 = mock:mockFunction()
    local m2 = mock:mockFunction()

    mock(m1):shouldBeCalled():
    andAlso(mock(m2):shouldBeCalledWith(1, 2, 3)):
    when(function()
      m1()
      m2(1, 2, 3)
    end)
  end)

  it('should allow you to mix and match call types', function()
    local m1 = mock:mockFunction()
    local m2 = mock:mockFunction()

    mock(m1):shouldBeCalled():
    andAlso(mock(m2):shouldBeCalledWith(1, 2, 3)):
    andThen(mock(m2):shouldBeCalledWith(1):andWillReturn(4)):
    when(function()
      m1()
      m2(1, 2, 3)
      assert.is.equal(m2(1), 4)
    end)
  end)

  it('should allow functions to be used to improve readability', function()
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
  end)

  it('should allow a table of functions to be mocked', function()
    local someTable = {
      foo = function() end,
      bar = function() end
    }

    mockedTable = mock:mockTable(someTable)

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
    local f = mock:mockFunction()

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
      local f = mock:mockFunction()

      mock(f):shouldBeCalledWith(2):andWillReturn(1):multipleTimes(2):
      when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  -- ordering

  -- multiple times

  -- allowed vs. not allowed functions on the expectation (ie: state machine for expectation)
end)
