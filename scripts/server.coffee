#
# A simple static server to test things like HTML5 history
#

express = require 'express'
{ resolve } =  require 'path'

app = express()
app.use express.static resolve __dirname, "../out"

app.listen 3000, -> console.log 'Listenning on 3000'