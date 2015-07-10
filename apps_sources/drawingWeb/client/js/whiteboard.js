// This factor is used for the drawing to an other size than 49*100
var k = 8;

// The canvas where we draw
var can = document.getElementById("can");
var ctx = can.getContext("2d");

var mouseButtonDown = false;
can.height = 48 * k;
can.width = 99 * k;

// A mouse button have to be down and the mouse have to move to draw something

can.addEventListener("mousemove",function(e){

    if(!mouseButtonDown)
        return;

    // transform the dictionary of color 
    //    {r:"RED COLOR",g:"GREEN COLOR",b: "BLUE COLOR"} to an [r,g,b] array
    var rgb = [color["r"],color["g"],color["b"]]; 

    // Allign the mouse position to the grid and transform the position to the real position (on the 49*100 matrix)
    var y = Math.round(e.offsetY / k),
        x = Math.round(e.offsetX / k);

    // Update the draw on all clients
    pixel = [[x,y],rgb,$("#brushSize").val()];

    for(var i=x;i < Math.min(99,x + parseInt($("#brushSize").val())); i++){
        for(var j=y;j < Math.min(48,y + parseInt($("#brushSize").val())); j++){
            drawPixel(i,j,rgb);
            grid[i][j] = rgb;

            socket.emit('update pixel', [[i,j],rgb]);
        }
    }

});

can.addEventListener("mousedown",function(e){
    mouseButtonDown = true;
});

can.addEventListener("mouseup",function(e){
    mouseButtonDown = false;
});


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
