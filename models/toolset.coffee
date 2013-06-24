mongoose = require 'mongoose'

schema = mongoose.Schema
  _administrator: type: mongoose.Schema.Types.ObjectId, ref: 'User'
  title: String
  tools = [type:mongoose.Schema.Types.ObjectId, ref:'Tool']

module.exports = mongoose.Model 'Toolset', schema