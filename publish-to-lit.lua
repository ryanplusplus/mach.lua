os.execute('mkdir -p build')

local f = io.open('build/mach.lua', 'w')

f:write([==[
--[[lit-meta
  name = 'ryanplusplus/mach'
  version = '1.0.11'
  description = 'Simple mocking framework for Lua inspired by CppUMock and designed for readability.'
  tags = { 'testing' }
  license = 'MIT'
  author = { name = 'Ryan Hartlage' }
  homepage = 'https://github.com/ryanplusplus/mach.lua'
]]
]==])

f:close()

os.execute([[cd src; amalg.lua mach `find mach | grep lua | cut -d'.' -f1` >> ../build/mach.lua]])

f = io.open('build/mach.lua', 'r')
local content = f:read('*all')
f:close()

content = content:gsub("require 'mach.", "require 'mach/")

f = io.open('build/mach.lua', 'w')
f:write(content .. "\nreturn require 'mach'")
f:close()

os.execute([[lit publish build/mach.lua]])
