var express = require('express');
var app = express();
var server = require('http').createServer(app);
var io = require('socket.io')(server);
var path = require('path');

var port = process.env.PORT || 8443;

app.use(express.static(path.join(__dirname, 'public')));

// In-memory wheel device simulation
var virtualWheelDevice = null;
var padId = 0;

// Register io events
io.on('connection', function(socket) {
  console.log('Client connected');
  socket.on('connectWheel', function() {
    virtualWheelDevice = { padId: padId };
    console.log('[DEBUG] Wheel connected for player', padId);
    io.to(socket.id).emit('wheelConnected', { padId: padId });
    padId = (padId + 1) % 4; // simulate 4 players
  });

  socket.on('wheelEvent', function(data) {
    // Logs every ABS/EV/Axis event so we can validate our changes
    const typeName = ['EV_SYN','EV_KEY','EV_REL','EV_ABS','?','?','?'][data.type] || ('0x'+data.type.toString(16));
    const codeName = {
      0x00:'ABS_X',0x01:'ABS_Y',0x02:'ABS_Z',0x03:'ABS_RX',0x04:'ABS_RY',0x05:'ABS_RZ',
      0x110:'BTN_LEFT',0x111:'BTN_RIGHT',
    }[data.code] || ('0x'+data.code.toString(16));
    if (data.value !== undefined) {
      console.log(`[EV] type=${typeName} code=${codeName} value=${data.value}`);
    } else {
      console.log(`[EV] type=${typeName} code=${codeName} no value`);
    }
  });
});

server.listen(port, function() {
  console.log('Debug server listening on http://localhost:'+port+'  Ctrl+C to stop.');
  console.log('Open: http://localhost:'+port+'/wheel.html');
});
