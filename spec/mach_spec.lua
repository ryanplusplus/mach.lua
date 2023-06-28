describe('The mach library', function()
  local mach = require 'mach'

  local f = mach.mock_function('f')
  local f1 = mach.mock_function('f1')
  local f2 = mach.mock_function('f2')
  local f3 = mach.mock_function('f3')

  local function should_fail(test)
    if pcall(test) then
      error('expected failure did not occur')
    end
  end

  local function should_fail_with(expectedMessage, test)
    local result, actualMessage = pcall(test)
    _, _, actualMessage = actualMessage:find(":%w+: (.+)")

    if result then
      error('expected failure did not occur')
    elseif not actualMessage:find(expectedMessage, 1, true) then
      error('expected failure message: "' .. expectedMessage .. '" did not match actual failure message: "' .. actualMessage .. '"')
    end
  end

  local function should_fail_with_exactly(expectedMessage, test)
    local result, actualMessage = pcall(test)
    _, _, actualMessage = actualMessage:find(":%w+: (.+)")

    if result then
      error('expected failure did not occur')
    elseif actualMessage ~= expectedMessage then
      error('expected failure message: "' .. expectedMessage .. '" did not match actual failure message: "' .. actualMessage .. '"')
    end
  end

  it('should allow method call syntax', function()
    f:should_be_called():when(function() f() end)
  end)

  it('should allow you to verify that a function is called', function()
    f.should_be_called().when(function() f() end)
  end)

  it('should alert you when a function is not called', function()
    should_fail_with('Not all calls occurred', function()
      f.should_be_called().when(function() end)
    end)
  end)

  it('should alert you when the wrong function is called', function()
    should_fail_with('Unexpected function call f2()', function()
      f1.should_be_called().when(function() f2() end)
    end)
  end)

  it('should alert you when a function is called unexpectedly', function()
    should_fail_with('Unexpected function call f()', function()
      f()
    end)
  end)

  it('should allow you to verify that a function has been called with the correct arguments', function()
    f.should_be_called_with(1, '2').when(function() f(1, '2') end)
  end)

  it('should alert you when a function has been called with incorrect arguments', function()
    should_fail(function()
      f.should_be_called_with(1, '2').when(function() f(1, '3') end)
    end)
  end)

  it('should allow you to expect a function to be called with any arguments', function()
    f.should_be_called_with_any_arguments().when(function() f(1, '3') end)
  end)

  it('should allow you to specify the return value of a mocked function', function()
    f.should_be_called().and_will_return(4).when(function()
      assert.is.equal(f(), 4)
    end)

    f.should_be_called().with_result(4).when(function()
      assert.is.equal(f(), 4)
    end)
  end)

  it('should allow you to specify multiple return values for a mocked function', function()
    f.should_be_called().and_will_return(1, 2).when(function()
      r1, r2 = f()
      assert.is.equal(r1, 1)
      assert.is.equal(r2, 2)
    end)
  end)

  it('should allow you to specify errors to be raised when a mocked function is called', function()
    f.should_be_called().
      and_will_raise_error('some error message').
      when(function()
        should_fail_with('some error message', function()
          f()
        end)
      end)
  end)

  it('should allow calls to be completed after a call that raises an error', function()
    f.should_be_called().
      and_will_raise_error('some error message').
      and_then(f.should_be_called().and_will_return(4)).
      when(function()
        pcall(function() f() end)
        assert.is.equal(f(), 4)
      end)
  end)

  it('should allow you to check that a function has been called multiple times', function()
    f.should_be_called().
      and_also(f.should_be_called_with(1, 2, 3)).
      when(function()
        f()
        f(1, 2, 3)
      end)
  end)

  it('should allow you to check that multiple functions are called', function()
    f1.should_be_called().
      and_also(f2.should_be_called_with(1, 2, 3)).
      when(function()
        f1()
        f2(1, 2, 3)
      end)
  end)

  it('should allow you to mix and match call types', function()
    f1.should_be_called().
      and_also(f2.should_be_called_with(1, 2, 3)).
      and_then(f2.should_be_called_with(1).and_will_return(4)).
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
      return f1.should_be_called()
    end

    function another_thing_should_happen()
      return f2.should_be_called_with(1, 2, 3)
    end

    function the_code_under_test_runs()
      f1()
      f2(1, 2, 3)
    end

    something_should_happen().
      and_also(another_thing_should_happen()).
      when(the_code_under_test_runs)
  end)

  it('should allow a table of functions to be mocked', function()
    local some_table = {
      foo = function() end,
      bar = function() end
    }

    mocked_table = mach.mock_table(some_table)

    mocked_table.foo.should_be_called_with(1).and_will_return(2).
      and_also(mocked_table.bar.should_be_called()).
      when(function()
        mocked_table.foo(1)
        mocked_table.bar()
      end)
  end)

  it('should allow a mocked table to be named', function()
    mocked_table = mach.mock_table({ foo = function() end }, 'some_table')

    should_fail_with('Unexpected function call some_table.foo()', function()
      mocked_table.foo()
    end)
  end)

  it('should give mocked tables a default name when none is provided', function()
    mocked_table = mach.mock_table({ foo = function() end })

    should_fail_with('Unexpected function call <anonymous>.foo()', function()
      mocked_table.foo()
    end)
  end)

  it('should fail when a function is incorrectly used as a method', function()
    local some_table = {
      foo = function() end
    }

    mocked_table = mach.mock_table(some_table)

    should_fail(function()
      mocked_table.foo.should_be_called_with(1).and_will_return(2).when(function()
        mocked_table:foo(1)
      end)
    end)
  end)

  it('should allow an object with methods to be mocked', function()
    local some_object = {}

    function some_object:foo() end
    function some_object:bar() end

    local mocked_object = mach.mock_object(some_object)

    mocked_object.foo.should_be_called_with(1).and_will_return(2).
      and_also(mocked_object.bar.should_be_called()).
      when(function()
        mocked_object:foo(1)
        mocked_object:bar()
      end)
  end)

  it('should allow a mocked object to be named', function()
    mocked_object = mach.mock_object({ foo = function() end }, 'some_object')

    should_fail_with('Unexpected function call some_object:foo()', function()
      mocked_object.foo()
    end)
  end)

  it('should give mocked objects a default name when none is provided', function()
    mocked_object = mach.mock_object({ foo = function() end })

    should_fail_with('Unexpected function call <anonymous>:foo()', function()
      mocked_object:foo()
    end)
  end)

  it('should allow mocking of any callable in an object, not just functions', function()
    local some_table = {
      foo = {}
    }

    setmetatable(some_table.foo, {__call = function() end})

    local mocked_table = mach.mock_table(some_table)

    mocked_table.foo.should_be_called().when(function() mocked_table.foo() end)
  end)

  it('should allow mocking of any callable in a table, not just functions', function()
    local some_object = {
      foo = {}
    }

    setmetatable(some_object.foo, {__call = function() end})

    local mocked_object = mach.mock_object(some_object)

    mocked_object.foo.should_be_called().when(function() mocked_object:foo() end)
  end)

  it('should fail when a method is incorrectly used as a function', function()
    should_fail(function()
      local some_object = {}

      function some_object:foo() end

      local mocked_object = mach.mock_object(some_object)

      mocked_object.foo.should_be_called_with(1).and_will_return(2).when(function()
        mocked_object.foo(1)
      end)
    end)
  end)

  it('should let you expect a function to be called multiple times', function()
    f.should_be_called_with(2).and_will_return(1).multiple_times(3).when(function()
      assert(f(2) == 1)
      assert(f(2) == 1)
      assert(f(2) == 1)
    end)
  end)

  it('should fail if a function is not called enough times', function()
    should_fail(function()
      f.should_be_called_with(2).and_will_return(1).multiple_times(3).when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  it('should allow after to be used as an alias for when', function()
    f.should_be_called().after(function() f() end)
  end)

  it('should fail if a function is called too many times', function()
    should_fail(function()
      f.should_be_called_with(2).and_will_return(1).multiple_times(2).when(function()
        assert(f(2) == 1)
        assert(f(2) == 1)
        assert(f(2) == 1)
      end)
    end)
  end)

  it('should fail if and_will_return is not preceeded by an expected call', function()
    should_fail_with('cannot set return value for an unspecified call', function()
      local f = mach.mock_function('f')
      f.and_will_return(1)
    end)
  end)

  it('should fail if and_will_raise_error is not preceeded by an expected call', function()
    should_fail_with('cannot set error for an unspecified call', function()
      local f = mach.mock_function('f')
      f.and_will_raise_error(1)
    end)
  end)

  it('should fail if when is not preceeded by an expected call', function()
    should_fail_with('incomplete expectation', function()
      f.when(function() end)
    end)
  end)

  it('should fail if after is not preceeded by an expected call', function()
    should_fail_with('incomplete expectation', function()
      f.after(function() end)
    end)
  end)

  it('should fail if should_be_called is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      f.should_be_called().should_be_called()
    end)
  end)

  it('should fail if should_be_called_with is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      f.should_be_called().should_be_called_with(4)
    end)
  end)

  it('should fail if should_be_called_with_any_arguments is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      f.should_be_called().should_be_called_with_any_arguments()
    end)
  end)

  it('should allow calls to happen out of order when and_also is used', function()
    f1.should_be_called().
      and_also(f2.should_be_called()).
      when(function()
        f2()
        f1()
      end)

    f1.should_be_called_with(1).
      and_also(f1.should_be_called_with(2)).
      when(function()
        f1(2)
        f1(1)
      end)
  end)

  it('should not allow calls to happen out of order when and_then is used', function()
    should_fail_with('Out of order function call f2()', function()
      f1.should_be_called().
        and_then(f2.should_be_called()).
        when(function()
          f2()
          f1()
        end)
    end)

    should_fail_with('Unexpected arguments (2) provided to function f1', function()
      f1.should_be_called_with(1).
        and_then(f2.should_be_called(2)).
        when(function()
          f1(2)
          f1(1)
        end)
    end)
  end)

  it('should catch out of order calls when mixed with unordered calls', function()
    should_fail_with('Out of order function call f3()', function()
      f1.should_be_called().
        and_also(f2.should_be_called()).
        and_then(f3.should_be_called()).
        when(function()
          f2()
          f3()
          f1()
        end)
    end)
  end)

  it('should allow ordered and unordered calls to be mixed', function()
    f.should_be_called_with(1).
      and_also(f.should_be_called_with(2)).
      and_then(f.should_be_called_with(3)).
      and_also(f.should_be_called_with(4)).
      when(function()
        f(2)
        f(1)
        f(4)
        f(3)
      end)
  end)

  it('should correctly handle ordering when expected calls are deeply nested', function()
    f.should_be_called_with(1).
      and_also(f.should_be_called_with(2).
        and_then(f.should_be_called_with(3).
          and_also(f.should_be_called_with(4)))).
      when(function()
        f(2)
        f(1)
        f(4)
        f(3)
      end)
  end)

  it('should allow a strictly ordered call to occur after a missing optional call', function()
    f1.may_be_called().and_then(f2.should_be_called()).when(function()
      f2()
    end)
  end)

  it('should not allow order to be violated for an optional call', function()
    should_fail_with('Unexpected function call f1()', function()
      f1.may_be_called().and_then(f2.should_be_called()).when(function()
        f2()
        f1()
      end)
    end)
  end)

  it('should allow soft expectations to be called', function()
    f.may_be_called().when(function() f() end)
  end)

  it('should allow soft expectations to be omitted', function()
    f.may_be_called().when(function() end)
  end)

  it('should allow soft expectations with return values', function()
    f.may_be_called().and_will_return(3).when(function()
      assert(f() == 3)
    end)
  end)

  it('should allow soft expectations with arguments to be called', function()
    f.may_be_called_with(4).when(function() f(4) end)
  end)

  it('should allow soft expectations with arguments to be omitted', function()
    f.may_be_called_with(4).when(function() end)
  end)

  it('should allow soft expectations with any arguments to be called', function()
    f.may_be_called_with_any_arguments().when(function() f(4) end)
  end)

  it('should allow soft expectations with any arguments to be omitted', function()
    f.may_be_called_with_any_arguments().when(function() end)
  end)

  it('should fail if may_be_called is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      f.should_be_called().may_be_called()
    end)
  end)

  it('should fail if may_be_called_with is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      f.should_be_called().may_be_called_with(4)
    end)
  end)

  it('should fail if may_be_called_with_any_arguments is used after a call has already been specified', function()
    should_fail_with('call already specified', function()
      f.should_be_called().may_be_called_with_any_arguments()
    end)
  end)

  it('should handle unexpected calls outside of an expectation', function()
    should_fail_with("Unexpected function call f(1, 2, '3')", function()
      mach.mock_function('f')(1, 2, '3')
    end)
  end)

  it('should handle table arguments in error messages', function()
    local a = {}

    should_fail_with('Unexpected function call f({})', function()
      mach.mock_function('f')(a)
    end)
  end)

  it('should give mocked functions a default name when none is provided', function()
    should_fail_with('Unexpected function call <anonymous>(1, 2, 3)', function()
      mach.mock_function()(1, 2, 3)
    end)
  end)

  it('should give mocked methods a default name when none is provided', function()
    should_fail_with('Unexpected function call <anonymous>(2, 3)', function()
      mach.mock_method()(1, 2, 3)
    end)
  end)

  it('should allow additional mocked calls to be ignored', function()
    f1.should_be_called().and_other_calls_should_be_ignored().when(function()
      f1()
      f2()
    end)

    f1.should_be_called().with_other_calls_ignored().when(function()
      f1()
      f2()
    end)
  end)

  it('should report completed and incomplete calls in unexpected call errors', function()
    local expected_failure =
      'Unexpected function call f3()\n' ..
      'Completed calls:\n' ..
      '\tf1()\n' ..
      'Incomplete calls:\n' ..
      '\tf2()'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().and_also(f2.should_be_called()).when(function()
        f1()
        f3()
      end)
    end)
  end)

  it('should report completed and incomplete calls in unexpected argument errors', function()
    local expected_failure =
      'Unexpected arguments (3) provided to function f2\n' ..
      'Completed calls:\n' ..
      '\tf1()\n' ..
      'Incomplete calls:\n' ..
      '\tf2()'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().and_also(f2.should_be_called()).when(function()
        f1()
        f2(3)
      end)
    end)
  end)

  it('should report completed and incomplete calls in out of order call errors', function()
    local expected_failure =
      'Out of order function call f3()\n' ..
      'Completed calls:\n' ..
      '\tf1()\n' ..
      'Incomplete calls:\n' ..
      '\tf2()\n' ..
      '\tf3()'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().
        and_then(f2.should_be_called()).
        and_then(f3.should_be_called()).
        when(function()
          f1()
          f3()
        end)
    end)
  end)

  it('should report completed and incomplete calls in not all calls occurred errors', function()
    local expected_failure =
      'Not all calls occurred\n' ..
      'Completed calls:\n' ..
      '\tf1()\n' ..
      'Incomplete calls:\n' ..
      '\tf2()\n' ..
      '\tf3()'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().
        and_then(f2.should_be_called()).
        and_then(f3.should_be_called()).
        when(function()
          f1()
        end)
    end)
  end)

  it('should omit the completed call list in an error when no calls were completed', function()
    local expected_failure =
      'Unexpected function call f3()\n' ..
      'Incomplete calls:\n' ..
      '\tf1()'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().when(function()
        f3()
      end)
    end)
  end)

  it('should omit the incomplete call list in an error when all calls were completed', function()
    local expected_failure =
      'Unexpected function call f3()\n' ..
      'Completed calls:\n' ..
      '\tf1()'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().when(function()
        f1()
        f3()
      end)
    end)
  end)

  it('should show methods in call status messages', function()
    local o = {
      m = mach.mock_method('m')
    }

    local expected_failure =
      'Unexpected function call f()\n' ..
      'Incomplete calls:\n' ..
      '\tm()'

    should_fail_with_exactly(expected_failure, function()
      o.m.should_be_called().when(function()
        f()
      end)
    end)
  end)

  it('should show optional function calls as optional in call status messages', function()
    local expected_failure =
      'Unexpected function call f3()\n' ..
      'Completed calls:\n' ..
      '\tf1()\n' ..
      'Incomplete calls:\n' ..
      '\tf2() (optional)'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called().and_also(f2.may_be_called()).when(function()
        f1()
        f3()
      end)
    end)
  end)

  it('should show actual arguments in call status messages', function()
    local expected_failure =
      'Unexpected function call f3()\n' ..
      'Completed calls:\n' ..
      '\tf1(1, 2, 3)'

    should_fail_with_exactly(expected_failure, function()
      f1.should_be_called_with_any_arguments().when(function()
        f1(1, 2, 3)
        f3()
      end)
    end)
  end)

  it('should allow the contents of tables arguments to be matched with the default matcher', function()
    f.should_be_called_with(mach.match({ a = 1, b = 2 })).when(function()
      f({ a = 1, b = 2 })
    end)
  end)

  it('should not allow table contents to be different when using the default matcher', function()
    should_fail(function()
      f.should_be_called_with(mach.match({ a = 1, b = 2 })).when(function()
        f({ a = 11, b = 22 })
      end)
    end)
  end)

  it('should print mach.match arguments in a friendly way', function()
    local expected_failure =
      'Unexpected arguments (4) provided to function f\n' ..
      'Incomplete calls:\n' ..
      "\tf(<mach.match({ ['3'] = 1 })>)"

    should_fail_with_exactly(expected_failure, function()
      f.should_be_called_with(mach.match({ ['3'] = 1 })).when(function()
        f(4)
      end)
    end)
  end)

  it('should allow custom matchers to be used', function()
    local function always_matches() return true end
    local function never_matches() return false end

    f.should_be_called_with(mach.match({ a = 1, b = 2 }, always_matches)).when(function()
      f({ a = 11, b = 22 })
    end)

    should_fail(function()
      f.should_be_called_with(mach.match({ a = 1, b = 2 }, never_matches)).when(function()
        f({ a = 1, b = 2 })
      end)
    end)
  end)

  it('should allow custom matchers to have a nil input', function()
    local function matches_by_type(a,b) return type(a) == type(b) end

    f.should_be_called_with(mach.match({ a = 1, b = 2 }, matches_by_type)).when(function()
      f({ a = 11, b = 22 })
    end)

    f.should_be_called_with(mach.match(nil, matches_by_type)).when(function()
      f(nil)
    end)

    f.should_be_called_with(mach.match(function() end, matches_by_type)).when(function()
      f(function() end)
    end)
  end)

  it('should conflict with the test above', function()
    local function has_optional_inputs(a, args) f(a, args) end

    f.should_be_called_with(mach.match({ a = 1, b = 2 }), 'some_input').when(function()
      has_optional_inputs({ a = 1, b = 2 }, 'some_input')
    end)

    f.should_be_called_with(mach.match({ a = 1, b = 2 })).when(function()
      has_optional_inputs({ a = 1, b = 2 })
    end)
  end)

  it('should match any argument with mach.any', function()
    f.should_be_called_with(mach.any, 2, 3).when(function()
      f({ a = 11, b = 22 }, 2, 3)
    end)
  end)

  it('should match other arguments when mach.any is used for an argument', function()
    local expected_failure =
      'Unexpected arguments (false, 2, 4) provided to function f\n' ..
      'Incomplete calls:\n' ..
      '\tf(<mach.any>, 2, 3)'

    should_fail_with_exactly(expected_failure, function()
      f.should_be_called_with(mach.any, 2, 3).when(function()
        f(false, 2, 4)
      end)
    end)
  end)

  it('should allow mocked calls to be ignored', function()
    mach.ignore_mocked_calls_when(function()
      f()
    end)
  end)

  it('should correctly print arguments for incomplete expectations that accept any arguments', function()
    local expected_failure =
      'Not all calls occurred\n' ..
      'Completed calls:\n' ..
      '\tf(1)\n' ..
      'Incomplete calls:\n' ..
      '\tf()'

    should_fail_with_exactly(expected_failure, function()
      f.should_be_called_with_any_arguments().
        and_then(f.should_be_called_with_any_arguments()).
        when(function()
          f(1)
        end)
    end)
  end)

  it('should give a helpful error message if a non-existent expectation is used', function()
    should_fail_with("attempt to call a nil value (field 'should_be_call')", function()
      f.should_be_call()
    end)
  end)
end)
