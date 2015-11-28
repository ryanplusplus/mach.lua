describe('The mach library', function()
  local mach = require 'mach'

  local function should_fail(test)
    if pcall(test) then
      error('expected failure did not occur')
    end
  end

  local function should_fail_with(expectedMessage, test)
    local result, actualMessage = pcall(test)
    _, _, actualMessage = actualMessage:find(":%w+: (.+)")

    if(result) then
      error('expected failure did not occur')
    elseif(actualMessage ~= expectedMessage) then
      error('expected failure message: "' .. expectedMessage .. '" did not match actual failure message: "' .. actualMessage .. '"')
    end
  end

  it('should allow you to verify that a function is called', function()
    local f = mach.mock_function('f')

    f:should_be_called():when(function() f() end)
  end)

  it('should alert you when a function is not called', function()
    local f = mach.mock_function('f')

    should_fail_with('not all calls occurred', function()
      f:should_be_called():when(function() end)
    end)
  end)

  it('should alert you when the wrong function is called', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f2')

    should_fail_with('unexpected function call f2()', function()
      f1:should_be_called():when(function() f2() end)
    end)
  end)

  it('should alert you when a function is called unexpectedly', function()
    local f = mach.mock_function('f')

    should_fail_with('unexpected function call f()', function()
      f()
    end)
  end)

  it('should allow you to verify that a function has been called with the correct arguments', function()
    local f = mach.mock_function('f')

    f:should_be_called_with(1, '2'):when(function() f(1, '2') end)
  end)

  it('should alert you when a function has been called with incorrect arguments', function()
    local f = mach.mock_function('f')

    should_fail(function()
      f:should_be_called_with(1, '2'):when(function() f(1, '3') end)
    end)
  end)

  it('should allow you to specify the return value of a mocked function', function()
    local f = mach.mock_function('f')

    f:should_be_called():and_will_return(4):when(function()
      assert.is.equal(f(), 4)
    end)
  end)

  it('should allow you to specify multiple return values for a mocked function', function()
    local f = mach.mock_function('f')

    f:should_be_called():and_will_return(1, 2):when(function()
      r1, r2 = f()
      assert.is.equal(r1, 1)
      assert.is.equal(r2, 2)
    end)
  end)

  it('should allow you to specify errors to be raised when a mocked function is called', function()
    local f = mach.mock_function('f')

    f:should_be_called():
      and_will_raise_error('some error message'):
      when(function()
        should_fail_with('some error message', function()
          f()
        end)
      end)
  end)

  it('should allow calls to be completed after a call that raises an error', function()
    local f = mach.mock_function('f')

    f:should_be_called():
      and_will_raise_error('some error message'):
      and_then(f:should_be_called():and_will_return(4)):
      when(function()
        pcall(function() f() end)
        assert.is.equal(f(), 4)
      end)
  end)

  it('should allow you to check that a function has been called multiple times', function()
    local f = mach.mock_function('f')

    f:should_be_called():
      and_also(f:should_be_called_with(1, 2, 3)):
      when(function()
        f()
        f(1, 2, 3)
      end)
  end)

  it('should allow you to check that multiple functions are called', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f2')

    f1:should_be_called():
      and_also(f2:should_be_called_with(1, 2, 3)):
      when(function()
        f1()
        f2(1, 2, 3)
      end)
  end)

  it('should allow you to mix and match call types', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f2')

    f1:should_be_called():
      and_also(f2:should_be_called_with(1, 2, 3)):
      and_then(f2:should_be_called_with(1):and_will_return(4)):
      when(function()
        f1()
        f2(1, 2, 3)
        assert.is.equal(f2(1), 4)
      end)
  end)

  it('should allow functions to be used to improve readability', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f1')

    function something_should_happen()
      return f1:should_be_called()
    end

    function another_thing_should_happen()
      return f2:should_be_called_with(1, 2, 3)
    end

    function the_code_under_test_runs()
      f1()
      f2(1, 2, 3)
    end

    something_should_happen():
      and_also(another_thing_should_happen()):
      when(the_code_under_test_runs)
  end)

  it('should allow a table of functions to be mocked', function()
    local some_table = {
      foo = function() end,
      bar = function() end
    }

    mocked_table = mach.mock_table(some_table)

    mocked_table.foo:should_be_called_with(1):and_will_return(2):
      and_also(mocked_table.bar:should_be_called()):
      when(function()
        mocked_table.foo(1)
        mocked_table.bar()
      end)
  end)

  it('should allow a mocked table to be named', function()
    mocked_table = mach.mock_table({ foo = function() end }, 'some_table')

    should_fail_with('unexpected function call some_table.foo()', function()
      mocked_table.foo()
    end)
  end)

  it('should give mocked tables a default name when none is provided', function()
    mocked_table = mach.mock_table({ foo = function() end })

    should_fail_with('unexpected function call <anonymous>.foo()', function()
      mocked_table.foo()
    end)
  end)

  it('should fail when a function is incorrectly used as a method', function()
    local some_table = {
      foo = function() end
    }

    mocked_table = mach.mock_table(some_table)

    should_fail(function()
      mocked_table.foo:should_be_called_with(1):and_will_return(2):when(function()
        mocked_table:foo(1)
      end)
    end)
  end)

  it('should allow an object with methods to be mocked', function()
    local some_object = {}

    function some_object:foo() end
    function some_object:bar() end

    local mocked_object = mach.mock_object(some_object)

    mocked_object.foo:should_be_called_with(1):and_will_return(2):
      and_also(mocked_object.bar:should_be_called()):
      when(function()
        mocked_object:foo(1)
        mocked_object:bar()
      end)
  end)

  it('should allow a mocked object to be named', function()
    mocked_object = mach.mock_object({ foo = function() end }, 'some_object')

    should_fail_with('unexpected function call some_object:foo()', function()
      mocked_object.foo()
    end)
  end)

  it('should give mocked objects a default name when none is provided', function()
    mocked_object = mach.mock_object({ foo = function() end })

    should_fail_with('unexpected function call <anonymous>:foo()', function()
      mocked_object.foo()
    end)
  end)

  it('should allow mocking of any callable in an object, not just functions', function()
    local some_table = {
      foo = {}
    }

    setmetatable(some_table.foo, {__call = function() end})

    local mocked_table = mach.mock_table(some_table)

    mocked_table.foo:should_be_called():when(function() mocked_table.foo() end)
  end)

  it('should allow mocking of any callable in a table, not just functions', function()
    local some_object = {
      foo = {}
    }

    setmetatable(some_object.foo, {__call = function() end})

    local mocked_object = mach.mock_object(some_object)

    mocked_object.foo:should_be_called():when(function() mocked_object:foo() end)
  end)

  it('should fail when a method is incorrectly used as a function', function()
    should_fail(function()
      local some_object = {}

      function some_object:foo() end

      local mocked_object = mach.mock_object(some_object)

      mocked_object.foo:should_be_called_with(1):and_will_return(2):when(function()
        mocked_object.foo(1)
      end)
    end)
  end)

  it('should let you expect a function to be called multiple times', function()
    local f = mach.mock_function('f')

    f:should_be_called_with(2):and_will_return(1):multiple_times(3):when(function()
      assert(f(2) == 1)
      assert(f(2) == 1)
      assert(f(2) == 1)
    end)
  end)

  it('should fail if a function is not called enough times', function()
    should_fail(function()
      local f = mach.mock_function()

      f:should_be_called_with(2):and_will_return(1):multiple_times(3):when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  it('should allow after to be used as an alias for when', function()
    local f = mach.mock_function()

    f:should_be_called():after(function() f() end)
  end)

  it('should fail if a function is called too many times', function()
    should_fail(function()
      local f = mach.mock_function('f')

      f:should_be_called_with(2):and_will_return(1):multiple_times(2):when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  it('should fail if and_will_return is not preceeded by should_be_called or should_be_called_with', function()
    should_fail_with('cannot set return value for an unspecified call', function()
      local f = mach.mock_function('f')
      f:and_will_return(1)
    end)
  end)

  it('should fail if when is not preceeded by should_be_called or should_be_called_with', function()
    should_fail_with('incomplete expectation', function()
      local f = mach.mock_function('f')

      f:when(function() end)
    end)
  end)

  it('should fail if after is not preceeded by should_be_called or should_be_called_with', function()
    should_fail_with('incomplete expectation', function()
      local f = mach.mock_function('f')

      f:after(function() end)
    end)
  end)

  it('should fail if should_be_called is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      local f = mach.mock_function('f')

      f:should_be_called():should_be_called()
    end)
  end)

  it('should fail if should_be_called_with is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      local f = mach.mock_function('f')

      f:should_be_called():should_be_called_with(4)
    end)
  end)

  it('should allow calls to happen out of order when and_also is used', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f2')

    f1:should_be_called():
      and_also(f2:should_be_called()):
      when(function()
        f2()
        f1()
      end)

    f1:should_be_called_with(1):
      and_also(f1:should_be_called_with(2)):
      when(function()
        f1(2)
        f1(1)
      end)
  end)

  it('should not allow calls to happen out of order when and_then is used', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f2')

    should_fail_with('unexpected function call f2()', function()
      f1:should_be_called():
        and_then(f2:should_be_called()):
        when(function()
          f2()
          f1()
        end)
    end)

    should_fail_with('unexpected arguments (2) provided to function f1', function()
      f1:should_be_called_with(1):
        and_then(f2:should_be_called(2)):
        when(function()
          f1(2)
          f1(1)
        end)
    end)
  end)

  it('should catch out of order calls when mixed with unordered calls', function()
    local f1 = mach.mock_function('f1')
    local f2 = mach.mock_function('f2')
    local f3 = mach.mock_function('f3')

    should_fail_with('unexpected function call f3()', function()
      f1:should_be_called():
        and_also(f2:should_be_called()):
        and_then(f3:should_be_called()):
        when(function()
          f2()
          f3()
          f1()
        end)
    end)
  end)

  it('should allow ordered and unordered calls to be mixed', function()
    local f = mach.mock_function('f')

    f:should_be_called_with(1):
      and_also(f:should_be_called_with(2)):
      and_then(f:should_be_called_with(3)):
      and_also(f:should_be_called_with(4)):
      when(function()
        f(2)
        f(1)
        f(4)
        f(3)
      end)
  end)

  it('should allow soft expectations to be called', function()
    local f = mach.mock_function('f')

    f:may_be_called():when(function() f() end)
  end)

  it('should allow soft expectations to be omitted', function()
    local f = mach.mock_function('f')

    f:may_be_called():when(function() end)
  end)

  it('should allow soft expectations with return values', function()
    local f = mach.mock_function('f')

    f:may_be_called():and_will_return(3):when(function()
      assert(f() == 3)
    end)
  end)

  it('should allow soft expectations with arguments to be called', function()
    local f = mach.mock_function('f')

    f:may_be_called_with(4):when(function() f(4) end)

    f:may_be_called_with(4):when(function() f(4) end)
  end)

  it('should allow soft expectations with arguments to be omitted', function()
    local f = mach.mock_function('f')

    f:may_be_called_with(4):when(function() end)
  end)

  it('should fail if may_be_called is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      local f = mach.mock_function('f')

      f:should_be_called():may_be_called()
    end)
  end)

  it('should fail if may_be_called_with is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      local f = mach.mock_function('f')

      f:should_be_called():may_be_called_with(4)
    end)
  end)

  it('should handle unexpected calls outside of an expectation', function()
    should_fail_with('unexpected function call f(1, 2, 3)', function()
      mach.mock_function('f')(1, 2, 3)
    end)
  end)

  it('should handle table arguments in error messages', function()
    local a = {}

    should_fail_with('unexpected function call f(' .. tostring(a) ..')', function()
      mach.mock_function('f')(a)
    end)
  end)

  it('should give mocked functions a default name when none is provided', function()
    should_fail_with('unexpected function call <anonymous>(1, 2, 3)', function()
      mach.mock_function()(1, 2, 3)
    end)
  end)

  it('should give mocked functions a default name when none is provided', function()
    should_fail_with('unexpected function call <anonymous>(2, 3)', function()
      mach.mock_method()(1, 2, 3)
    end)
  end)
end)
