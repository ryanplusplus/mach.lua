local expected_call = {}
expected_call.__index = expected_call

local function create(f, required, args)
  local o = {
    _f = f,
    _ordered = false,
    _required = required,
    _args = args,
    _return = {}
  }

  setmetatable(o, expected_call)

  return o
end

function expected_call:function_matches(f)
  return f == self._f
end

function expected_call:args_match(args)
  if #self._args ~= #args then return false end

  for k in ipairs(self._args) do
    if self._args[k] ~= args[k] then return false end
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
