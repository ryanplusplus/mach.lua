describe('mach.format_value', function()
  local format_value = require 'mach.format_value'

  it('should format basic types', function()
    assert.are.same('3', format_value(3))
    assert.are.same("'hello'", format_value('hello'))
    assert.are.same('true', format_value(true))
  end)

  it('should format functions', function()
    local f = function() end
    assert.are.same(tostring(f), format_value(f))
  end)

  it('should format tables', function()
    assert.are.same('{ [1] = true, [2] = false }', format_value({ true, false }))
    assert.are.same("{ ['a'] = 1, ['b'] = 2 }", format_value({ b = 2, a = 1 }))
    assert.are.same(
      "{ [1] = true, ['b'] = { [4] = 'lua', ['a'] = 1 } }",
      format_value({ b = { [4] = 'lua', a = 1 }, true })
    )
  end)

  it('should respect __tostring when it is defined', function()
    local value = setmetatable({}, {
      __tostring = function() return 'foo' end
    })

    assert.are.same('foo', format_value(value))
  end)
end)
