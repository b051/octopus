http = require "http"
express = require "express"
hbs = require "express-hbs"

app = express()

app.engine 'hbs', hbs.express3
  defaultLayout: "#{__dirname}/views/layouts/main.hbs"
  partialsDir: "#{__dirname}/views/partials"

app.set "view engine", 'hbs'

app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
app.use express.session()
app.use app.router
app.use require("stylus").middleware("#{__dirname}/public")
app.use express.static "#{__dirname}/public"

# development only
app.use express.errorHandler()  if "development" is app.get("env")

app.get "/", (req, res) ->
  res.render 'index', title: 'Nodejs'

port = process.env.PORT or 3000
http.createServer(app).listen port, ->
  console.log "Express server listening on port #{port}"
