express = require 'express'
mongoose = require 'mongoose'
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
passport = require 'passport'
Wine = require './models/wine'
hour = 3600000
day = hour * 24
month = day * 30

RedisStore = require('connect-redis') express
mongoose.connect 'mongodb://localhost/octopus'

db = mongoose.connection
db.once 'open', ->
  console.log "Connected to '#{db.name}' database"
  Wine.collection.count (err, count) ->
    if count is 0
      console.log "The 'wine' collection is empty. Creating it with sample data..."
      Wine.populateDB()

# parse request bodies (req.body)
app.use express.bodyParser uploadDir:'./public/pics/'
# support _method (PUT in forms etc)
# app.use express.methodOverride()
# cookieParser is required by session() middleware
# pass the secret for signed cookies These two *must*
# be placed in the order shown.
app.use express.cookieParser 'dM3nMWcxF85n'

# session() populates req.session
app.use express.session
  store: new RedisStore
    db: 'octopus_session'
  secret: 's31gsad983'
  maxAge: month

app.use passport.initialize()
app.use passport.session()

app.use app.router
app.use express.compress()
app.use express.static "#{__dirname}/public"

#this is for debug coffee script in chrome
app.use "/backbone", express.static "#{__dirname}/backbone"

require("./routes")(app)

io.set 'log level', 1

io.sockets.on 'connection', (socket) ->
  socket.on 'message', (message) ->
    console.log "Got message: #{message}"
    ip = socket.handshake.address.address
    url = message
    io.sockets.emit 'pageview',
      connections: Object.keys(io.connected).length
      ip: "***.***.***.#{ip.substring(ip.lastIndexOf('.') + 1)}"
      url: url
      xdomain: socket.handshake.xdomain
      timestamp: new Date()
    
  socket.on 'disconnect', ->
    console.log "Socket disconnected"
    io.sockets.emit 'pageview',
      connections: Object.keys(io.connected).length

port = process.env.PORT or 3000
server.listen port, ->
  console.log "Listening on #{port}"
