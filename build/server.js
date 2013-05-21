(function() {
  var file, nStatic;

  nStatic = require('node-static');

  file = new nStatic.Server('build/example');

  require('http').createServer(function(request, response) {
    console.log("Listening ...");
    return request.addListener('end', function() {
      return file.serve(request, response);
    }).resume();
  }).listen(process.env.PORT || 5000);

}).call(this);
