describe('mach.deep_compare_matcher', function()
  local match = require 'mach.deep_compare_matcher'

  it('should indicate that identical numbers match', function()
    assert.is_true(match(13, 13))
  end)

  it('should indicate that different numbers do not match', function()
    assert.is_false(match(13, 12))
  end)

  it('should indicate that identical strings match', function()
    assert.is_true(match('hello', 'hello'))
  end)

  it('should indicate that different strings do not match', function()
    assert.is_false(match('mach', 'mock'))
  end)

  it('should indicate that identical booleans match', function()
    assert.is_true(match(true, true))
    assert.is_true(match(false, false))
  end)

  it('should indicate that true and false do not match', function()
    assert.is_false(match(true, false))
    assert.is_false(match(false, true))
  end)

  it('should indicate that nothing matches nil except nil', function()
    assert.is_false(match(nil, 13))
    assert.is_false(match(13, nil))
    assert.is_true(match(nil, nil))
  end)

  it('should indicate that a table matches itself', function()
    local t = {}
    assert.is_true(match(t, t))
  end)

  it('should indicate that tables with the same contents are the same', function()
    assert.is_true(match({ a = 1, b = 2 }, { a = 1, b = 2 }))
  end)

  it('should indicate that tables with different keys are not the same', function()
    assert.is_true(match({ a = 1, b = 2 }, { a = 1, b = 2 }))
  end)

  it('should indicate that two tables, one with an extra key, are not the same', function()
    assert.is_false(match({ a = 1, b = 2 }, { a = 1 }))
    assert.is_false(match({ a = 1 }, { a = 1, b = 2 }))
  end)

  it('should indicate that tables with the same keys but different values are not the same', function()
    assert.is_false(match({ a = 1, b = 2 }, { a = 11, b = 22 }))
  end)

  it('should indicate that deep tables match when their contents are the same', function()
    local t1 = {
      a = { b = 2 },
      c = { 1, 2, 3 }
    }

    local t2 = {
      a = { b = 2 },
      c = { 1, 2, 3 }
    }

    assert.is_true(match(t1, t2))
  end)

  it('should indicate that deep tables match when their contents are different', function()
    local t1 = {
      a = { b = 2 },
      c = { 1, 2, 3 }
    }

    local t2 = {
      a = { b = '2' },
      c = { 1, 2, 3 }
    }

    assert.is_false(match(t1, t2))
  end)
end)
