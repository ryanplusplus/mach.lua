return {
  __tostring = function(o)
    return '<mach.match(' .. tostring(o.value) .. ')>'
  end
}
