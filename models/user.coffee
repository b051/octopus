mongoose = require 'mongoose'
{Strategy} = require 'passport-local'
pwd = require 'pwd'

schema = mongoose.Schema
  username: type: String, required: yes, unique: yes
  hash: String
  email: type: String, unique: yes
  salt: String

schema.set 'autoIndex', no

schema.statics.authenticateStrategy = ->
  self = @
  new Strategy (username, password, done) ->
    process.nextTick ->
      self.findOne username: username, (err, user) ->
        return done(err) if err
        if user
          pwd.hash password, user.salt, (error, hash) ->
            return done(error) if error
            if user.hash is hash
              done null, user
            else
              done null, no, message: '<strong>Oh Snap!</strong> Your password does not match.'
        else
          done null, no, message:"<strong>Oh Snap!</strong> We do not recognize your username '#{username}'"

schema.statics.register = (username, password, done) ->
  @findOne username: username, (err, user) ->
    if user
      return done null, no, message: "<strong>Oh Snap!</strong> User with username '#{username}', probably you, already registered"
    pwd.hash password, (err, salt, hash) ->
      user = new User salt: salt, hash: hash, username: username
      user.save (err) ->
        return done err if err
        done null, user

User = mongoose.model 'User', schema

module.exports = User