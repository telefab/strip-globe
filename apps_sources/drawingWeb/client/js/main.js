/*
 *  I this file, socket are managed and other misc stuff
 */

// the color used to draw
var color = {r: 255, g: 255, b: 255};

// init the color picker using the library colorPicker
var colorSetByText = false;
$('#picker').colpick({
    layout:'rgb',
    color:"ffffff",
    submit:1,
    onChange:function(hsb,hex,rgb,el,bySetColor){
        $(el).css('border-color','#' + hex);

        // Fill the text box just if the color was not set using the text field
        if (!colorSetByText)
            $(el).val(hex);
        colorSetByText = false;

        color = rgb;
    }
}).keyup(function(){
    colorSetByText = true;
    $(this).colpickSetColor(this.value);
});

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
        if(rotImg == 0){
            var val = 255;
        }
        else{
            //Write the value on the slider like if it is a logaritmic slider
            // position will be between 0 and 100
            var minp = 0;
            var maxp = 49;

            // The result should be between 100 an 10000000
            var minv = Math.log(1);
            var maxv = Math.log(255);

            // calculate adjustment factor
            var scale = (maxv-minv) / (maxp-minp);
            var val = (Math.log(rotImg)-minv) / scale + minp;
        }
        $("#rotateImg").val(val);

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
    // Activate pre-selected colors
    console.log($('.color'));
    $(".color").each(function() {
        var color = $(this).attr("data-color");
        $(this).css("background-color", "#" + color);
        $(this).click(function() {
            $('#picker').colpickSetColor(color);
        });
    });
});
