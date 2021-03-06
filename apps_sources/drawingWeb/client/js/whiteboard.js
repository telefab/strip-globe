// This factor is used for the drawing to an other size than 49*100
var k = 10;

// The canvas where we draw
var can = document.getElementById("can");
var ctx = can.getContext("2d");

var mouseButtonDown = false;
can.height = 48 * k;
can.width = 99 * k;

// A mouse button have to be down and the mouse have to move to draw something

function paintPoint(pointX, pointY) {

    // transform the dictionary of color 
    //    {r:"RED COLOR",g:"GREEN COLOR",b: "BLUE COLOR"} to an [r,g,b] array
    var rgb = [color["r"],color["g"],color["b"]]; 

    // Allign the mouse position to the grid and transform the position to the real position (on the 49*100 matrix)
    var y = Math.round(pointY / k - parseInt($("#brushSize").val())/2),
        x = Math.round(pointX / k - parseInt($("#brushSize").val())/2);

    // Update the draw on all clients
    pixel = [[x,y],rgb,$("#brushSize").val()];

    for(var i=x;i < Math.max(0, Math.min(99,x + parseInt($("#brushSize").val()))); i++){    //0 < x + brushSize < 100
        for(var j=y;j < Math.max(0, Math.min(48,y + parseInt($("#brushSize").val()))); j++){//0 < y + brushSize < 49
            drawPixel(i,j,rgb);
            grid[i][j] = rgb;

            socket.emit('update pixel', [[i,j],rgb]);
        }
    }

}

can.onmousemove = function(e){
    if (!mouseButtonDown)
        return;
    paintPoint(e.offsetX, e.offsetY);
}

can.onclick = function(e){
    paintPoint(e.offsetX, e.offsetY);
}

can.ontouchmove = function(e) {
    for (var i = 0; i < e.changedTouches.length; i++) {
        var touch = e.changedTouches[i];
        paintPoint(touch.clientX - can.offsetParent.offsetLeft, touch.clientY - can.offsetParent.offsetTop);
    }
}

can.ontouchstart = function(e) {
    for (var i = 0; i < e.changedTouches.length; i++) {
        var touch = e.changedTouches[i];
        paintPoint(touch.clientX - can.offsetParent.offsetLeft, touch.clientY - can.offsetParent.offsetTop);
    }
}

document.body.onmousedown = function() { 
    mouseButtonDown = true;
}

document.body.onmouseup = function() {
    mouseButtonDown = false;
}

function clearWhiteboard(){
    socket.emit('clear img');
}

// Read the grid var and fill the canvas
//     with square of the good color and size at the good place
function loadFromGrid(){
    ctx.clearRect(0, 0, can.width, can.height);

    for(var x=0;x<grid.length;x++){
        for(var y=0; y<grid[x].length ;y++){
            drawPixel(x,y,grid[x][y]);
        }
    }
}

function drawPixel(x,y,rgb){
    ctx.fillStyle = 'rgb(' + rgb[0] 
            + ',' + rgb[1] 
            + ',' + rgb[2] 
            + ')';
            ctx.fillRect(x*k,y*k,k,k);
            }
