#
# Uploads the generated static assets to the production s3 bucket.
#

knox = require 'knox'
glob = require 'glob'
fs = require 'fs'
{ resolve } = require 'path'

headers =
  'x-amz-acl': 'public-read'

client = knox.createClient
  key: process.env.S3_KEY
  secret: process.env.S3_SECRET
  bucket: if process.argv[2] is 'production' then '2013.artsy.net' else 'staging.2013.artsy.net'

uploadFile = (file) ->
  console.log "Uploading #{file}...."
  client.putFile resolve(__dirname, '../', file), file.replace(/^out/, ''), headers, (err, res) ->
    return console.warn(err) if err
    console.log "Uploaded #{file}!"
    res.resume()

for ext in ['html', 'css', 'js', 'jpg', 'png', 'svg']
  for file in glob.sync('out/**/*.' + ext)
    uploadFile(file) unless file.match('_content')