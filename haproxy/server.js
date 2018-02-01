// File: /srv/server.js
var http = require('http');
var url = require('url');

var requestCount = 0;

function serve(ip, port)
{
 http.createServer(function (req, res) {
 requestCount = requestCount + 1;
 var url_parts = url.parse(req.url,true).query;

 res.writeHead(200, {'Content-Type': 'text/plain'});
 res.write(JSON.stringify(req.headers) + "\n");
 res.write("endpoint: "+ip+":"+port+"\n");
 res.write("requestcount: " + requestCount + "\n");
 res.end("echo: " + url_parts.echo + "\n");
 console.log("served request: " + requestCount + " on port " + port);
 }).listen(port, ip);
 console.log("started server on " + ip + ":" + port);
}

// Create three servers for
// the load balancer, listening on any
// network on the following three ports
var port = parseInt(process.argv[2]);
console.log('Server started at ' + port + '\n');
serve('0.0.0.0', port);
serve('0.0.0.0', port+1);
serve('0.0.0.0', port+2);
