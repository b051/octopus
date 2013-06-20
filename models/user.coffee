mongoose = require 'mongoose'

schema = mongoose.Schema
  username: String
  password: String
  email: String
  salt: String

User = mongoose.model 'User', schema

module.exports = User