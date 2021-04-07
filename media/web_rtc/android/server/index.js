'use strict';

const os = require('os');
const nodeStatic = require('node-static');
const socketIO = require('socket.io');
const fs = require('fs');
const fileServer = new(nodeStatic.Server)();

const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};
const http = require('https');
const app = http.createServer(options, function(req, res) {
  fileServer.serve(req, res);
}).listen(80, "0.0.0.0");

let file = "access.log",
     date = new Date(),
     day = date.getDate(),
     month = date.getMonth(),
     year = date.getFullYear(),
     hours = date.getHours(),
     seconds = date.getMinutes(),
     milis = date.getSeconds(),
     zone = "+8400";

app.on("request",function(req,res){
    function getLog(req,status,size){
      let rizhi = "",
           ip,
           time,
           method,
           page,
           protocol,
           statusCode,
           userAgent;
      ip = req.connection.remoteAddress;
      time = `[${day}/${month}/${year}:${hours}:${seconds}:${milis} ${zone}]`;
      method = req.method;
      page = req.url;
      protocol = req.httpVersion;
      statusCode = status;
      size = size;
      userAgent = req.headers["user-agent"];
      rizhi = `${ip} - - ${time} "${method} ${page} HTTP${protocol}" ${statusCode} ${size} "-" "${userAgent}"`;
      console.log(rizhi);
      return rizhi;
     }
     function writeLog(file,req,res,status,size,fn){
         let rizhi = fn(req,status,size);
         fs.writeFileSync(file,rizhi)
     }

    writeLog(file, req, res, 0, 0, getLog);
 });

var io = socketIO(app);
io.sockets.on('connection', function(socket) {

  // convenience function to log server messages on the client
  function log() {
    var array = ['Message from server:'];
    array.push.apply(array, arguments);
    socket.emit('log', array);
  }

  socket.on('message', function(message) {
    log('Client said: ', message);
    // for a real app, would be room-only (not broadcast)
    socket.broadcast.emit('message', message);
  });

  socket.on('create or join', function(room) {
    log('Received request to create or join room ' + room);

    console.log(io.sockets.adapter.rooms); 
    var clientsInRoom = io.sockets.adapter.rooms.get(room);
    var numClients = clientsInRoom ? clientsInRoom.size : 0;

    log('Room ' + room + ' now has ' + numClients + ' client(s)');

    if (numClients === 0) {
      socket.join(room);
      console.log(room + " joined room");
      console.log(io.sockets.adapter.rooms); 
      console.log(socket.rooms); 
      log('Client ID ' + socket.id + ' created room ' + room);

      socket.emit('created', room, socket.id);
      clientsInRoom = io.sockets.adapter.rooms[room];

      log('Create room num: ' + JSON.stringify(socket.rooms));
    } else if (numClients === 1) {
      log('Client ID ' + socket.id + ' joined room ' + room);
      io.sockets.in(room).emit('join', room);
      socket.join(room);
      socket.emit('joined', room, socket.id);
      io.sockets.in(room).emit('ready');
    } else { // max two clients
      socket.emit('full', room);
    }
  });

  socket.on('ipaddr', function() {
    var ifaces = os.networkInterfaces();
    for (var dev in ifaces) {
      ifaces[dev].forEach(function(details) {
        if (details.family === 'IPv4' && details.address !== '127.0.0.1') {
          socket.emit('ipaddr', details.address);
        }
      });
    }
  });

  socket.on('bye', function(){
    console.log('received bye');
  });

});

// const https = require('https');
// const fs = require('fs');

// const options = {
//   key: fs.readFileSync('key.pem'),
//   cert: fs.readFileSync('cert.pem')
// };

// https.createServer(options, function (req, res) {
//   res.writeHead(200);
//   res.end("hello world\n");
// }).listen(80);