describe('The mock library', function()
  moq = require 'moq'

  it('should work', function()
    local m1 = moq.createMockFunction()
    local m2 = moq.createMockFunction()

    moq.mock(m1):shouldBeCalled():
    andAlso(moq.mock(m2):shouldBeCalledWith(1, 2, 3)):
    andThen(moq.mock(m2):shouldBeCalledWith(1):andWillReturn(4)):
    when(function()
      m1()
      m2(1, 2, 3)
      assert.is.equal(m2(1), 4)
    end)
  end)

  it('should allow functions to be used to improve readability', function()
    local m1 = moq.createMockFunction()
    local m2 = moq.createMockFunction()

    function somethingShouldHappen()
      return moq.mock(m1):shouldBeCalled()
    end

    function anotherThingShouldHappen()
      return moq.mock(m2):shouldBeCalledWith(1, 2, 3)
    end

    function yetAnotherThingShouldHappen()
      return moq.mock(m2):shouldBeCalledWith(1):andWillReturn(4)
    end

    function codeUnderTestRuns()
      m1()
      m2(1, 2, 3)
      assert.is.equal(m2(1), 4)
    end

    somethingShouldHappen():
    andAlso(anotherThingShouldHappen()):
    andThen(yetAnotherThingShouldHappen()):
    when(codeUnderTestRuns)
  end)

  it('should allow a table of functions to be mocked', function()
    local someTable = {
      foo = function() end,
      bar = function() end
    }

    mockedTable = moq.createMockTable(someTable)

    moq.mock(mockedTable.foo):shouldBeCalledWith(1):andWillReturn(2):
    when(function() mockedTable.foo(1) end)
  end)

  it('should allow an object with methods to be mocked', function()
    local someObject = {}

    function someObject:foo()
    end

    function someObject:bar()
    end

    mockedObject = moq.createMockObject(someObject)

    moq.mock(mockedObject.foo):shouldBeCalledWith(1):andWillReturn(2):
    when(function() mockedObject:foo(1) end)
  end)

  -- multiple return values
end)
