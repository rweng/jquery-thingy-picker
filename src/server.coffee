nStatic = require 'node-static'

example = new(nStatic.Server)('build/example')
docs = new(nStatic.Server)('build/docs')

require('http').createServer (request, response) ->
	request.addListener 'end', ->
		if request.url.match /^\/docs/
			request.url = request.url.replace /^\/docs\/?/, '/'
			docs.serve request, response
		else
			example.serve request, response
	.resume()
.listen(process.env.PORT || 5000)
console.log "Listening ..."