local expectation

local function mock(m)
  expectation.fn = m
  return expectation
end

expectation = {
  expected_calls = {},

  call_count = 0,

  ordered = false,

  should_be_called_with = function(...)
    expectation.expected_calls[#expectation.expected_calls + 1] = {
      fn = expectation.fn,
      args = table.pack(...),
      ordered = expectation.ordered
    }
    expectation.fn = nil
    expectation.ordered = false
    return expectation
  end,

  should_be_called = function()
    return expectation.should_be_called_with()
  end,

  and_then = function(expectation)
    -- do some jazz where the expectations are combined? with order!
    expectation.ordered = true
    return expectation
  end,

  mock = mock,

  check = function()
    assert(#expectation.expected_calls == expectation.call_count)
  end,

  when = function(f)
    f()
    expectation.check()
  end,

  after = function(...)
    return expectation.when(...)
  end,

  args_same = function(t1, t2)
    if #t1 ~= #t2 then return false end

    for k in ipairs(t1) do
      if t2[k] ~= t1[k] then return false end
    end

    return true
  end,

  mock_was_called = function(m, args)
    assert(#expectation.expected_calls > 0)

    expectation.call_count = expectation.call_count + 1

    assert(expectation.expected_calls[expectation.call_count].fn == m)
    assert(expectation.args_same(expectation.expected_calls[expectation.call_count].args, args))
  end
}

local function m1(...)
  expectation.mock_was_called(m1, table.pack(...))
end

local function m2(...)
  expectation.mock_was_called(m2, table.pack(...))
end

local function m1_should_be_called()
  return mock(m1).should_be_called()
end

local function m2_should_you_know()
  return mock(m2).should_be_called_with(1, 2, 3)
end

-- m1_should_be_called().
-- and_then(m2_should_you_know()).
-- after(function() m1(); m2(1, 2, 3) end)

mock(m1).should_be_called().
and_then(mock(m2).should_be_called_with(1, 2, 3)).
when(function() m1(); m2(1, 2, 3) end)
