(function() {
  var docs, example, nStatic, port;

  nStatic = require('node-static');

  example = new nStatic.Server('build/example');

  docs = new nStatic.Server('build/docs');

  port = process.env.PORT || 5000;

  require('http').createServer(function(request, response) {
    return request.addListener('end', function() {
      if (request.url.match(/^\/docs/)) {
        request.url = request.url.replace(/^\/docs\/?/, '/');
        return docs.serve(request, response);
      } else {
        return example.serve(request, response);
      }
    }).resume();
  }).listen(port);

  console.log("Listening ... on port " + port);

}).call(this);
