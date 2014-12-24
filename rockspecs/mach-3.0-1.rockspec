package = 'mach'
version = '3.0-1'
source = {
  url = 'https://github.com/ryanplusplus/mach.lua/archive/v3.0-1.tar.gz',
  dir = 'mach.lua-3.0-1/src'
}
description = {
  summary = 'Simple mocking framework for Lua inspired by CppUMock and designed for readability.',
  homepage = 'https://github.com/ryanplusplus/mach.lua/',
  license = 'MIT <http://opensource.org/licenses/MIT>'
}
dependencies = {
  'lua >= 5.1'
}
build = {
  type = 'builtin',
  modules = {
    ['mach'] = 'mach.lua',
    ['mach.Expectation'] = 'mach/Expectation.lua',
    ['mach.ExpectedCall'] = 'mach/ExpectedCall.lua',
    ['mach.unexpected_call_error'] = 'mach/unexpected_call_error.lua',
    ['mach.unexpected_args_error'] = 'mach/unexpected_args_error.lua',
  }
}
