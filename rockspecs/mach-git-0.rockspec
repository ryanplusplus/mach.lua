package = 'mach'
version = 'git-0'
source = {
  url = 'https://github.com/ryanplusplus/mach.lua/archive/master.zip',
  dir = 'mach.lua-master/src'
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
    ['mach.CompletedCall'] = 'mach/CompletedCall.lua',
    ['mach.unexpected_call_error'] = 'mach/unexpected_call_error.lua',
    ['mach.unexpected_args_error'] = 'mach/unexpected_args_error.lua',
    ['mach.out_of_order_call_error'] = 'mach/out_of_order_call_error.lua',
    ['mach.not_all_calls_occurred_error'] ='mach/not_all_calls_occurred_error.lua',
    ['mach.format_call_status'] = 'mach/format_call_status.lua',
    ['mach.format_arguments'] = 'mach/format_arguments.lua',
    ['mach.deep_compare_matcher'] = 'mach/deep_compare_matcher.lua',
    ['mach.match'] = 'mach/match.lua',
    ['mach.any'] = 'mach/any.lua',
  }
}
