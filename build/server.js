(function() {
  var docs, example, nStatic;

  nStatic = require('node-static');

  example = new nStatic.Server('build/example');

  docs = new nStatic.Server('doc');

  require('http').createServer(function(request, response) {
    return request.addListener('end', function() {
      var newUrl;

      if (newUrl = request.url.replace(/^\/docs/, '')) {
        console.log("serving docs");
        request.url = newUrl;
        return docs.serve(request, response);
      } else {
        return example.serve(request, response);
      }
    }).resume();
  }).listen(process.env.PORT || 5000);

  console.log("Listening ...");

}).call(this);
