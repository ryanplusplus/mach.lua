local mach_match = require 'mach.match'

local expected_call = {}
expected_call.__index = expected_call

expected_call.__tostring = function(self)
  local arg_strings = {}
  for _, arg in ipairs(self._args) do
    table.insert(arg_strings, tostring(arg))
  end

  local s = self._f._name .. '(' .. table.concat(arg_strings, ', ') .. ')'

  if not self._required then
    s = s .. ' (optional)'
  end

  return s
end

local function create(f, config)
  local o = {
    _f = f,
    _ordered = false,
    _required = config.required,
    _args = config.args,
    _ignore_args = config.ignore_args,
    _return = {}
  }

  setmetatable(o, expected_call)

  return o
end

function expected_call:function_matches(f)
  return f == self._f
end

function expected_call:args_match(args)
  if self._ignore_args then return true end
  if #self._args ~= #args then return false end

  for k in ipairs(self._args) do
    if getmetatable(self._args[k]) == mach_match then
      if not self._args[k].matcher(self._args[k].value, args[k]) then return false end
    elseif self._args[k] ~= args[k] then
      return false
    end
  end

  return true
end

function expected_call:set_return_values(...)
  self._return = table.pack(...)
end

function expected_call:get_return_values(...)
  return table.unpack(self._return)
end

function expected_call:set_error(...)
  self._error = table.pack(...)
end

function expected_call:get_error(...)
  return table.unpack(self._error)
end

function expected_call:has_error()
  return self._error ~= nil
end

function expected_call:fix_order()
  self._ordered = true
end

function expected_call:has_fixed_order()
  return self._ordered
end

function expected_call:is_required()
  return self._required
end

return create
