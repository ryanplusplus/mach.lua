local format_arguments = require 'mach.format_arguments'

local completed_call = {}
completed_call.__index = completed_call

completed_call.__tostring = function(self)
  return self._name .. format_arguments(self._args)
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
