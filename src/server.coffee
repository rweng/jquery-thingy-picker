nStatic = require 'node-static'

example = new(nStatic.Server)('build/example')
docs = new(nStatic.Server)('doc')

require('http').createServer (request, response) ->
	request.addListener 'end', ->
		if newUrl = request.url.replace /^\/docs/, ''
			console.log "serving docs"
			request.url = newUrl
			docs.serve request, response
		else
			example.serve request, response
	.resume()
.listen(process.env.PORT || 5000)
console.log "Listening ..."