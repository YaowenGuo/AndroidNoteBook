'use strict';

var isChannelReady = false;
var isInitiator = false;
var isStarted = false;
var localStream;
var pc;
var remoteStream;
var turnReady;

var pcConfig = {
  'iceServers': [{
    'urls': 'stun:stun.l.google.com:19302'
  }]
};

// Set up audio and video regardless of what devices are present.
var sdpConstraints = {
  offerToReceiveAudio: true,
  offerToReceiveVideo: true
};

// |-----------------------------------------------
window.room = prompt("Enter room name:");
// 在即将离开当前页面(刷新或关闭)时执行
window.onbeforeunload = function() {
  sendMessage('bye');
}

var socket = io.connect();

if (room !== "") {
  console.log('Message from client: Asking to join room ' + room);
  socket.emit('create or join', room);
}

socket.on('created', function(room, clientId) {
  console.log('Created room ' + room);
  isInitiator = true;
});

socket.on('full', function(room) {
  console.log('Message from client: Room ' + room + ' is full :^(');
});

socket.on('join', function(room) {
  console.log('Another peer made a request to join room' + room);
  console.log('This peer is the initiator of room ' + room + '!');
  isChannelReady = true;
})

socket.on('joined', function(room) {
  console.log('joined: ' + room);
  isChannelReady = true;
});

socket.on('ipaddr', function(ipaddr) {
  console.log('Message from client: Server IP address is ' + ipaddr);
});

socket.on('log', function(array) {
  console.log.apply(console, array);
});

// |-------------------------------------------------


// Thi client receives a message

socket.on('message', function(message) {
  console.log('Client received messsage:', message);
  if (message === 'got user media') {
    maybeStart();
  } else if (message.type === 'offer') {
    if (!isInitiator && !isStarted) {
      maybeStart();
    }
    pc.setRemoteDescription(new RTCSessionDescription(message));
    doAnswer();
  } else if (message.type === 'answer' && isStarted) {
    pc.setRemoteDescription(new RTCSessionDescription(message));
  } else if (message.type === 'candidate' && isStarted) {
    var candidate = new RTCIceCandidate({
      sdpMLineIndex: message.label,
      candidate: message.candidate
    });
    pc.addIceCandidate(candidate);
  } else if (message == 'bye' && isStarted) {
    handleRemoteHangup();
  }
})

// |-------------------------------------------------

let localVideo = document.querySelector('#localVideo');
let remoteVideo = document.querySelector('#remoteVideo');
let hangupBtn = document.querySelector('#hangup');
hangupBtn.addEventListener('click', function(view) {
  view.css
});

let constrains = {
  video: true,
  audio: false
}

console.log('Getting user media with constraints', constrains);

navigator.mediaDevices
.getUserMedia(constrains)
.then(gotStream)
.catch(function(e) {
  alert('getUserMedia() error: ' + e.name);
});


if (location.hostname !== 'localhost') {
  requestTurn(
    'https://computeengineondemand.appspot.com/turn?username=41784574&key=4080218913'
  );
}

function maybeStart() {
  console.log('>>>>>>> maybeStart() ', isStarted, localStream, isChannelReady);
  if (!isStarted && typeof localStream !== 'undefined' && isChannelReady) {
    console.log('>>>>>> creating peer connection');
    createPeerConnection();
    pc.addStream(localStream);
    isStarted = true;
    console.log('isInitiator', isInitiator);
    if (isInitiator) {
      doCall();
    }
  }
}

function doCall() {
  console.log('Sending offer to peer.');
  pc.createOffer(setLocalAndSendMessage, handleCreateOfferError);
}

function doAnswer() {
  console.log('Sending answer to peer.')
  pc.createAnswer(setLocalAndSendMessage, hadleCreateAnswerError)
}

function setLocalAndSendMessage(sessionDescription) {
  pc.setLocalDescription(sessionDescription);
  console.log('setLocalAndSendMessage sending message', sessionDescription);
  sendMessage(sessionDescription)
}

function handleCreateOfferError(event) {
  console.log('createOffer() error: ' + event);
}

function hadleCreateAnswerError(event) {
  console.log('createAnswer() error: ' + event);
}

function gotStream(stream) {
  console.log('Adding local stream.');
  localStream = stream;
  localVideo.srcObject = stream;
  sendMessage('got user media');
  if (isInitiator) {
    maybeStart();
  }
}


function sendMessage(message) {
  console.log('Client sending message: ', message);
  socket.emit('message', message);
}


function requestTurn(turnURL) {
  let turnExists = false;
  for (let i in pcConfig.iceServers) {
    if (pcConfig.iceServers[i].urls.substr(0, 5) === 'turn:') {
      turnExists = true;
      turnReady = true;
      break;
    }
  }

  if (!turnExists) {
    console.log("Getting TURN server from", turnURL);
    // No TURN sever. Get one from omputeengineondemand.appspot.com:
    let xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4&& xhr.status === 200) {
        let turnSever = JSON.parse(xhr.responseText);
        console.log('Got TURN server: ', turnSever);
        pcConfig.iceServers.push({
          'url': 'turn:' + turnSever.username + '@' + turnSever.turn,
          'credential': turnServer.password
        });
        turnReady = ture;
      }
    };
    xhr.open('GET', turnURL, true);
    xhr.send();
  }
}



function createPeerConnection() {
  try {
    pc = new RTCPeerConnection(null);
    pc.onicecandidate = handleIceCandidate;
    pc.onaddstream = handleRemoteStreamAdded;
    pc.onremovestream = handleRemoteStreamRemoved;
    console.log('Created RTCPeerConnection');
  } catch (e) {
    console.log('Failed to create PeerConnection, exception: ' + e.message);
    alert('Cannot create RTCPeerConnection object.');
    return;
  }
}

function handleIceCandidate(event) {
  console.log('icecandidate event: ', event);
  if (event.candidate) {
    sendMessage({
      type: 'candidate',
      label: event.candidate.sdpMLineIndex,
      id: event.candidate.sdpMid,
      candidate: event.candidate.candidate
    });
  } else {
    console.log('End of candidates.');
  }
}

function handleRemoteStreamAdded(event) {
  console.log('Remote stream added.');
  remoteStream = event.stream;
  remoteVideo.srcObject = remoteStream;
}

function handleRemoteStreamRemoved(event) {
  console.log('Remote stream removed. Event:', event);
}

function handleRemoteHangup() {
  console.log('Session terminated.');
  stop();
  isInitiator = false;
}

function stop() {
  isStarted = false;
  pc.close();
  pc = null;
}

function hangup() {
  console.log('Hanging up.');
  stop();
  sendMessage('bye');
}