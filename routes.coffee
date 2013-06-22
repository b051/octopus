passport = require 'passport'
User = require './models/user'
Wine = require './models/wine'

passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (id, done) ->
  User.findById id, done

passport.use User.authenticateStrategy()

needAuthorize = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/login'

authorize = (req, res, next) ->
  local = passport.authenticate 'local', (err, user, info) ->
    return next(err) if err
    if not user
      res.send error: info.message
    else
      req.logIn user, (err) ->
        return next err if err
        res.send user: user
  local req, res, next

module.exports = (app) ->
  
  app.post '/logout', (req, res) ->
    req.logout()
    res.send []

  app.post '/login', authorize

  app.get '/user', (req, res) ->
    if req.user
      {_id, username} = req.user
      res.send user: _id: _id, username: username
    else
      res.send error: 'no session found'

  app.post '/user', (req, res, next) ->
    {username, password} = req.body
    User.register username, password, (err, user, messages) ->
      return next err if err
      if not user
        res.send error: info.message
      else
        req.logIn user, (err) ->
          return next err if err
          res.send user: user

  app.get "/wines", (req, res) ->
    Wine.find {}, null, (err, items) ->
      res.send items

  app.get "/wines/:id", (req, res) ->
    id = req.params.id
    Wine.findById id, (err, wine) ->
      console.log wine
      res.send wine
  
  app.post "/wines", needAuthorize, (req, res) ->
    wine = new Wine req.body
    console.log "Adding wine: #{wine}"
    wine.save (err) ->
      if err
        console.error err
        res.send error: "An error has occurred"
      else
        console.log "Success: #{JSON.stringify(wine)}"
        res.send wine
  
  app.put "/wines/:id", needAuthorize, (req, res) ->
    id = req.params.id
    wine = req.body
    Wine.findByIdAndUpdate id, $set: wine, (err, wine) ->
      if err
        console.error "Error updating wine: #{err}"
        res.send error: "An error has occurred"
      else
        res.send wine
  
  app.delete "/wines/:id", needAuthorize, (req, res) ->
    id = req.params.id
    Wine.findByIdAndRemove id, (err, wine) ->
      console.log "deleting #{wine}"
      if err
        console.error "Error deleting wine: #{err}"
        res.send error: "An error has occurred"
      else
        res.send wine