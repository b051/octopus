express = require 'express'
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

wines = require "./routes/wines"

app.use app.router
app.use express.static "#{__dirname}/public"
app.use "/backbone", express.static "#{__dirname}/backbone"

app.get "/wines", wines.findAll
app.get "/wines/:id", wines.findById
app.post "/wines", wines.addWine
app.put "/wines/:id", wines.updateWine
app.delete "/wines/:id", wines.deleteWine

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
