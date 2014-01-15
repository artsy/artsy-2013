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
app.get '/', (req, res) -> res.render 'index'
app.use express.static resolve __dirname, "../out"

app.listen 3000, -> console.log 'Listenning on 3000'