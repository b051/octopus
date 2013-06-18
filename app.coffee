express = require "express"
http = require "http"
io = require "socket.io"
wines = require "./routes/wines"
app = express()

app.set "port", process.env.PORT or 3000
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.static(path.join(__dirname, "public"))

server = http.createServer(app)
io = io.listen(server)
io.configure ->
  io.set "authorization", (handshakeData, callback) ->
    if handshakeData.xdomain
      callback "Cross-domain connections are not allowed"
    else
      callback null, yes

server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

app.get "/wines", wines.findAll
app.get "/wines/:id", wines.findById
app.post "/wines", wines.addWine
app.put "/wines/:id", wines.updateWine
app.delete "/wines/:id", wines.deleteWine

io.sockets.on "connection", (socket) ->
  socket.on "message", (message) ->
    console.log "Got message: " + message
    ip = socket.handshake.address.address
    url = message
    io.sockets.emit "pageview",
      connections: Object.keys(io.connected).length
      ip: "***.***.***." + ip.substring(ip.lastIndexOf(".") + 1)
      url: url
      xdomain: socket.handshake.xdomain
      timestamp: new Date()


  socket.on "disconnect", ->
    console.log "Socket disconnected"
    io.sockets.emit "pageview",
      connections: Object.keys(io.connected).length
