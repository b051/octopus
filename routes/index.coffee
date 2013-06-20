flash = require 'connect-flash'
passport = require 'passport'
{Strategy} = require 'passport-local'
{hash} = require 'pwd'
mongoose = require 'mongoose'
User = require '../models/user'
Wine = require '../models/wine'

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/login'

passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (id, done) ->
  User.findById id, done

passport.use new Strategy (username, password, done) ->
  process.nextTick ->
    User.findOne username: username, (err, user) ->
      return done(err) if err
      if user
        pass.hash password, user.sale, (error, hash) ->
          return done(error) if error
          if user.hash is hash
            done null, user
          else
            done null, no, message: '<strong>Oh Snap!</strong> Your password does not match.'
      else
        done null, no, message:"<strong>Oh Snap!</strong> We do not recognize your username '#{username}'"


module.exports = (app) ->
  
  app.get "/wines", (req, res) ->
    Wine.find {}, null, (err, items) ->
      res.send items
  
  app.get "/wines/:id", (req, res) ->
    id = req.params.id
    Wine.findById id, (err, wine) ->
      console.log wine
      res.send wine
  
  app.post "/wines", (req, res) ->
    wine = new Wine req.body
    console.log "Adding wine: #{wine}"
    wine.save (err) ->
      if err
        console.error err
        res.send error: "An error has occurred"
      else
        console.log "Success: #{JSON.stringify(wine)}"
        res.send wine
  
  app.put "/wines/:id", (req, res) ->
    id = req.params.id
    wine = req.body
    Wine.findByIdAndUpdate id, $set: wine, (err, wine) ->
      if err
        console.error "Error updating wine: #{err}"
        res.send error: "An error has occurred"
      else
        res.send wine
  
  app.delete "/wines/:id", (req, res) ->
    id = req.params.id
    Wine.findByIdAndRemove id, (err, wine) ->
      console.log "deleting #{wine}"
      if err
        console.error "Error deleting wine: #{err}"
        res.send error: "An error has occurred"
      else
        res.send wine