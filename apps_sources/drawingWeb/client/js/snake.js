/*
 *  Simple snake game
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

    socket.on('set rot img',function(rotImg){
        //Write the value on the slider like if it is a logaritmic slider
        // position will be between 0 and 100
        var minp = 0;
        var maxp = 50;

        // The result should be between 100 an 10000000
        var minv = Math.log(1);
        var maxv = Math.log(255);

        var val;
        if(rotImg == 0){
            val = 0;
        }
        else{
            // calculate adjustment factor
            var scale = (maxv-minv) / (maxp-minp);
            val = (Math.log(rotImg)-minv) / scale + minp;
        }
        $("#rotateImg").val(maxp-val);
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

// send to the server the rotation speed of the image
// the val is calculated to follow a logarithmic law
function setRotateImg(){
    if($('#rotateImg').val() == 50)
        var val = 0;

    else
    {
        //thks Stack Overflow
        // the slide will be between 0 and 49 (50 -> 0)
        var minp = 0;   // actual min
        var maxp = 50;  // actual max

        var minv = Math.log(1);   //future min
        var maxv = Math.log(255); //future max

        // calculate adjustment factor
        var scale = (maxv-minv) / (maxp-minp);

        var val = Math.exp(minv + scale * ((maxp - $('#rotateImg').val()) - minp));
    }
    socket.emit("set rot img",Math.round(val));
}

$(function() {
    // Try to connect
    wsConnect();

    // Configuration
    var width = 100;
    var height = 49;
    var snakeControls = [
        {"ArrowLeft": [-1, 0], "ArrowRight": [1, 0], "ArrowUp": [0, -1], "ArrowDown": [0, 1]},
        {"q": [-1, 0], "d": [1, 0], "z": [0, -1], "s": [0, 1]}
    ];
    var snakeColor = [
        [255, 0, 0],
        [0, 0, 255]
    ];
    var appleColor = [0, 255, 0];
    var backgroundColor = [0, 0, 0];

    // Current state
    var snakeActive;
    var snakeLocation;
    var appleLocation;
    var snakeDirection;
    var gameOver;

    // Do not rotate
    socket.emit("set rot img",255);

    // Reset function
    function resetGame() {
        snakeActive = [
            true,
            false
        ];
        snakeLocation = [
            [[0, Math.floor(height/2)]],
            [[Math.floor(width/2), Math.floor(height/2)]]
        ];
        snakeDirection = [[1,0], [1,0]];
        gameOver = false;
        clearScreen(backgroundColor);
        launchApple();
    }
    $("#restart").click(resetGame);
    resetGame();

    // Set game over mode
    function setGameOver(loser) {
        gameOver = true;
        clearScreen(snakeColor[loser]);
    }

    // Find a free new location for an apple
    function launchApple() {
        var newLocation = null;
        while (newLocation === null) {
            newLocation = [Math.floor(Math.random() * width), Math.floor(Math.random() * height)];
            if (checkSnakeCollision(newLocation))
                newLocation = null;
        }
        appleLocation = newLocation;
        socket.emit('update pixel', [appleLocation, appleColor]);
    }

    // Clear the whole screen with a given color
    function clearScreen(color) {
        var screen = [];
        for (var i = 0; i < width; i++) {
            screen[i] = [];
            for (var j = 0; j < height; j++) {
                screen[i][j] = color;
            }
        }
        socket.emit('update img', screen);
    }

    // Check if given location is occupied by a snake
    function checkSnakeCollision(newLocation) {
        for (var i = 0; i < 2; i++) {
            if (snakeActive[i]) {
                for (var j = 0; j < snakeLocation[i].length; j++) {
                    if (snakeLocation[i][j][0] == newLocation[0] && snakeLocation[i][j][1] == newLocation[1])
                        return true;
                }
            }
        }
        return false;
    }

    // Detect direction changes
    $("#keylogger").keypress(function(event) {
        var key = event.key;
        for (var i = 0; i < 2; i++) {
            var dir = snakeControls[i][key];
            if (dir) {
                snakeDirection[i] = dir;
                snakeActive[i] = true;
            }
        }
    });
    $("#keylogger").focus();

    // Move periodically 
    setInterval(function() {
        // Make sure the key logger is focused
        $("#keylogger").focus();
        // Do not move if game over
        if (gameOver)
            return;
        // Move the snakes by one step
        for (var i = 0; i < 2; i++) {
            if (snakeActive[i]) {
                var headLocation = [(snakeLocation[i][0][0] + snakeDirection[i][0] + width) % width, (snakeLocation[i][0][1] + snakeDirection[i][1] + height) % height];
                var growing = false;
                // Check for a collision
                if (checkSnakeCollision(headLocation)) {
                    setGameOver(i);
                    return;
                }
                // Check for an apple
                var growing = (headLocation[0] == appleLocation[0] && headLocation[1] == appleLocation[1]);
                // Add the head to the snake
                snakeLocation[i].splice(0, 0, headLocation);
                socket.emit('update pixel', [headLocation, snakeColor[i]]);
                if (growing) {
                    // Draw a new apple
                    launchApple()
                } else {
                    // Remove the tail
                    var tailLocation = snakeLocation[i].pop();
                    socket.emit('update pixel', [tailLocation, backgroundColor]);
                }
            }
        }
    }, 500);
});
