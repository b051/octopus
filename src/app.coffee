http = require "http"
express = require "express"
conn = require "./connections"

app = express()

server = http.createServer app
conn.start server

conn.asocket /rebuildDB/, (ws) ->
  ws.send "rebuilding DB..."
  console.log "rebuilding DB..."
  gamescripts.buildDB (err, gameId) ->
    ws.send "added game #{gameId}"
    console.log "added game #{gameId}"

app.get '/version', (req, resp) ->
  readJson 'package.json', (err, {version}) ->
    resp.writeHead 200, "Content-Type": "application/json"
    resp.write JSON.stringify version: version
    resp.end()

port = process.env.PORT or 3000
server.listen port, ->
  console.log "Listening on " + port
