nStatic = require 'node-static'

file = new(nStatic.Server)('build/example')

require('http').createServer (request, response) ->
	console.log "Listening ..."
	request.addListener 'end', ->
		file.serve request, response
	.resume()
.listen(process.env.PORT || 5000)