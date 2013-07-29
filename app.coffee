express = require 'express'
app = express()
server = require('http').createServer(app)

app.use app.router
app.use express.compress()
app.use express.static "#{__dirname}/public"
app.use '/lib/chosen', express.static "#{__dirname}/chosen/public"

#this is for debug coffee script in chrome
app.use "/backbone", express.static "#{__dirname}/backbone"
app.use "/lib/parse", express.static "#{__dirname}/node_modules/parse/build"

port = process.env.PORT or 3000
server.listen port, ->
  console.log "Listening on #{port}"
