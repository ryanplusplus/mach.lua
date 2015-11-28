package = 'mach'
version = 'git-0'
source = {
  url = 'git://github.com/ryanplusplus/mach.lua.git'
}
description = {
  summary = 'Simple mocking framework for Lua inspired by CppUMock and designed for readability.',
  homepage = 'https://github.com/ryanplusplus/mach.lua/',
  license = 'MIT <http://opensource.org/licenses/MIT>'
}
dependencies = {
  'lua >= 5.2'
}
build = {
  type = 'builtin',
  modules = {
    ['mach'] = 'mach.lua',
    ['mach.Expectation'] = 'mach/Expectation.lua',
    ['mach.ExpectedCall'] = 'mach/ExpectedCall.lua',
    ['mach.CompletedCall'] = 'mach/CompletedCall.lua',
    ['mach.unexpected_call_error'] = 'mach/unexpected_call_error.lua',
    ['mach.unexpected_args_error'] = 'mach/unexpected_args_error.lua',
    ['mach.out_of_order_call_error'] = 'mach/out_of_order_call_error.lua',
    ['mach.call_status_message'] = 'mach/call_status_message.lua',
    ['mach.format_arguments'] = 'mach/format_arguments.lua',
  }
}
