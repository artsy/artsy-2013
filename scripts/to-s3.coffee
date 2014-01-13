#
# Uploads the generated static assets to the production s3 bucket.
#

knox = require 'knox'
glob = require 'glob'
{ resolve } = require 'path'

headers =
  'x-amz-acl': 'public-read'

client = knox.createClient
  key: process.env.S3_KEY
  secret: process.env.S3_SECRET
  bucket: '2013.artsy.net'

uploadFile = (file) ->
  client.putFile resolve(__dirname, '../', file), file.replace(/^out/, ''), headers, (err, res) ->
    return console.warn(err) if err
    console.log "Uploaded #{file}"
    res.resume()

uploadFile(file) for file in glob.sync 'out/**/*'