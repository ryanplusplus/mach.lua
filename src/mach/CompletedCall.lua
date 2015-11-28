local completed_call = {}
completed_call.__index = completed_call

completed_call.__tostring = function(self)
  local arg_strings = {}
  for _, arg in ipairs(self._args) do
    table.insert(arg_strings, tostring(arg))
  end

  return self._name .. '(' .. table.concat(arg_strings, ', ') .. ')'
end

local function create(name, args)
  local o = {
    _name = name,
    _args = args
  }

  setmetatable(o, completed_call)

  return o
end

return create
