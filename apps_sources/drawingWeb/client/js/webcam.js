/*
 *  I this file, socket are managed and other misc stuff
 */

// Contain the img file in a 100*49 array of color(3 bytes)
var grid;

// Same as server.js
function initGrid(){
    grid = new Array(100);
    for(var i=0; i<100; i++){
        grid[i] = new Array(49);
        for(var j=0; j<49; j++){
            grid[i][j] = new Array([0,0,0]);
        }
    }
}

initGrid();
$('#waitForConnection').hide();

var socket;

var ellipsis = ['', '.', '..', '...'];
var runEllipsis = false;

// a function for a funny effect 
// e.g: Reconnecting.
//      Reconnecting..
function animateEllipsis(el, count) {
    el.innerHTML = ellipsis[count%4];
    if(runEllipsis == true) {
        window.setTimeout( function(){
            animateEllipsis(el, ++count);
        }, 250 );
    }
}

function startEllipsis() {
    runEllipsis = true;
    animateEllipsis(document.getElementById('ellipsisSpan'), 0);
}
function stopEllipsis() {
    runEllipsis = false;
}

// Management of websocket event + connection
function wsConnect(){

    socket = io("http://" + window.location.hostname + ":2345");   

    socket.on('reconnecting',function(){
        // notify the user that he is currently deconnected
        $("#status").html(langs[lang].reconnecting + "<span id='ellipsisSpan'></span>");
        startEllipsis();
    });
    socket.on('reconnect',function(){
        stopEllipsis();
    })
    socket.on('connect', function() {
        $("#server").hide();
        $('#waitForConnection').show();
        $("#status").html(langs[lang].connected);
        socket.emit("fetch img");
    });

    socket.on('close', function() {
        console.log('disconnected');
        $("#server").show();
        $('#waitForConnection').hide();
    });

    socket.on('update img',function(data) {
        grid = data;
        loadFromGrid();
    });

    socket.on('update pixel',function(pixel) {
        grid[pixel[0][0]][pixel[0][1]] = pixel[1];
        drawPixel(pixel[0][0],pixel[0][1],pixel[1]);
    });

    socket.on('set rot speed',function(rotSpeed){
        $("#rotationSpeed").val(rotSpeed);
    });

    // receive a binary Array and transform it to array to finally save it with the library FileSaver
    socket.on('get raw file',function(rawFile){
        // You can't directly use a binary Array, to use it, you have to create a DataView
        var data = new DataView(rawFile);
        var offset = 0;
        var array = new Array(rawFile.byteLength);
        while(offset < rawFile.byteLength)
        {
            //An array isn't a binary array, so, we have to transform uint8 to char 
            array[offset] = String.fromCharCode(data.getUint8(offset));
            offset++;
        } 

        saveAs(new Blob(array),"sphere.colors");
    });
}

function setRotationSpeed(){
    socket.emit("set rot speed",$("#rotationSpeed").val());
}

$(function() {
    // Try to connect
    wsConnect();
    // Activate the webcam
    var video = $("#video")[0];
    var videoStarted = false;
     
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia || navigator.oGetUserMedia;
     
    function handleVideo(stream) {
        video.src = window.URL.createObjectURL(stream);
        setTimeout(function() {
            videoStarted = true;
        }, 3000);
    }

    // Do not rotate
    socket.emit("set rot img", 0);

    setInterval(function() {
        if (!videoStarted)
            return;
        var canvas = $("<canvas />")[0];
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        var ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0);
        var xRatio = 100/canvas.width;
        var yRatio = 49/canvas.height;
        var xOffset = parseInt($("#rotationOffset").val());
        var yOffset = 0;
        var ratio;
        if (xRatio > yRatio) {
            ratio = yRatio;
            xOffset+= Math.floor((100 - canvas.width * ratio)/2);
        } else {
            ratio = xRatio;
            yOffset = Math.floor((49 - canvas.height * ratio)/2);
        }
        var imgData = ctx.getImageData(0,0,canvas.width,canvas.height).data;
        var counts = new Array();
        for (var i=0; i<100; i++) {
            counts[i] = new Array();
            for (var j=0; j<49; j++) {
                counts[i][j] = 0;
            }
        }
        grid = [];
        for (var i=0; i<100; i++) {
            grid[i] = [];
            for (var j=0; j<49; j++) {
                grid[i][j] = [0,0,0];
            }
        }
        for (var x=0; x<canvas.width; x++) {
            for (var y=0; y<canvas.height; y++) {
                var offset = (y * canvas.width + x) * 4;
                var scaledX = (Math.floor(x * ratio) + xOffset) % 100;
                var scaledY = Math.floor(y * ratio) + yOffset;
                grid[scaledX][scaledY][0]+= imgData[offset];
                grid[scaledX][scaledY][1]+= imgData[offset+1];
                grid[scaledX][scaledY][2]+= imgData[offset+2];
                counts[scaledX][scaledY]++;
            }
        }
        for (var i=0; i<100; i++) {
            for (var j=0; j<49; j++) {
                var count = counts[i][j];
                if (count > 0) {
                    for (var color = 0; color < 3; color++) {
                        colorValue = Math.floor(grid[i][j][color] / count);
                        grid[i][j][color] = colorValue >= 128 ? 255 : 0;
                    }
                }
            }
        }
        loadFromGrid();
        socket.emit('update img',grid);
    }, 1000);

    if (navigator.getUserMedia) {       
        navigator.getUserMedia({video: true}, handleVideo, function(){});
    }
});
