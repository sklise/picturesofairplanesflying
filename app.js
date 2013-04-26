var director = require('director'),
  ecstatic = require('ecstatic'),
  fs = require('fs'),
  union = require('union');

var photos = function () {
  var airplanes = fs.readdirSync('./public/airplanes/small', function (err) {
    if (err) throw err;
  });

  this.res.writeHead(200, {'Content-Type': 'application/json'});
  this.res.end(JSON.stringify(airplanes))
}

var router = new director.http.Router({
  '/photos.json' : { get: photos }
});

var server = union.createServer({
  before: [
    function (req, res) {
      var found = router.dispatch(req, res);
      if (!found) res.emit('next');
    },
    ecstatic({ root: __dirname + '/public', autoIndex: true })
  ]
});

server.listen(9393);