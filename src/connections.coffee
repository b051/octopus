ws = require 'ws'
apn = require 'apn'
apnConnection = new apn.Connection gateway: "gateway.sandbox.push.apple.com"
awssrouters = []
wssrouters = []

exports.socket = socket = (re, f) ->
  wssrouters.push [re, f]

exports.asocket = asocket = (re, f) ->
  awssrouters.push [re, f]

apnSendPlayPush = (event, device) ->
  note = new apn.Notification()
  note.expiry = Math.floor(Date.now() / 1000) + 3600
  note.badge = 1
  gameId = event.game.gameId
  note.alert = "#{gameId} new play"
  note.payload = event
  apnConnection.pushNotification note, device

ws::sendJSON = (id) ->
  @send JSON.stringify id, null, 4

exports.start = (server) ->
  wss = new ws.Server server:server
  
  wss.on 'connection', (ws) ->
    console.log "socket opened"
    
    ws.on 'error', (error) ->
      console.log "error #{error}"
    
    ws.on 'message', (message) ->
      for router in awssrouters
        match = message.match router[0]
        return router[1](ws, match) if match
      if not ws.player
        return ws.sendJSON error: "please sign in with GameCenter first"
      for router in wssrouters
        match = message.match router[0]
        return router[1](ws, match) if match
      return ws.sendJSON error: "Bad Request: #{message}"
    
    ws.on 'close', ->
      console.log "socket closed"