local expectedCall = {}
expectedCall.__index = expectedCall

local function create(f, required, args)
  local o = {
    _f = f,
    _ordered = false,
    _required = required,
    _args = args,
    _return = {}
  }

  setmetatable(o, expectedCall)

  return o
end

function expectedCall:functionMatches(f)
  return f == self._f
end

function expectedCall:argsMatch(args)
  if #self._args ~= #args then return false end

  for k in ipairs(self._args) do
    if self._args[k] ~= args[k] then return false end
  end

  return true
end

function expectedCall:setReturnValues(...)
  self._return = table.pack(...)
end

function expectedCall:getReturnValues(...)
  return table.unpack(self._return)
end

function expectedCall:fixOrder()
  self._ordered = true
end

function expectedCall:hasFixedOrder()
  return self._ordered
end

function expectedCall:isRequired()
  return self._required
end

return {
  create = create
}
