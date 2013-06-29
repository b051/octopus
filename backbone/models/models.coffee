if require?
  {Parse} = require 'parse'
else
  Parse = window.Parse

Parse.initialize 'FPijVqDF5EAKrkGuFv1oj43Au7kOFguvoQgwt6Bp', 'l3EnH19I64YJC6q59v4A7fjZJ3bWJryyk5x8IWrm'

Toolset = Parse.Object.extend
  className: 'Toolset'

ToolInfo = Parse.Object.extend
  className: 'ToolInfo'

Tool = Parse.Object.extend
  className: 'Tool'


if not exports?
  exports = window
exports.User = Parse.User
exports.Toolset = Toolset
exports.Tool = Tool
