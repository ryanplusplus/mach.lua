local format_value = require 'mach.format_value'

return {
  __tostring = function(o)
    return '<mach.match(' .. format_value(o.value) .. ')>'
  end
}
