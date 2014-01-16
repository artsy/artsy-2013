#
# A simple static server to test things like HTML5 history
#

express = require 'express'
{ resolve } =  require 'path'
{ exec } = require 'child_process'

app = express()
app.locals.pretty = true
app.set 'views', resolve __dirname, '../src/templates'
app.set 'view engine', 'jade'
app.use require("stylus").middleware
  src: resolve(__dirname, '../src/stylesheets')
  dest: resolve(__dirname, "../out")
app.use require('browserify-dev-middleware')
  src: resolve(__dirname, '../src/scripts')
  transforms: [require('coffeeify')]
app.get '/', (req, res) -> res.render 'index'
app.use express.static resolve __dirname, "../out"

app.listen 3000, -> console.log 'Listenning on 3000'