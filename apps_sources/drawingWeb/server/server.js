/*
 * Modules needed: 
 *      socket.io 
 *          website: socket.io
 *          to install: npm install socket.io
 *          license: MIT
 *      jParser
 *          website: none
 *          to install: npm install jParser
 *          license: ?
 *          remark: install during the same time jDataView under WTFPL license
 */
var io = require('socket.io')(2345);
var fs = require('fs');
var jParser = require('jParser');

"use strict";

// Contain the img, in array of 100 lines and 49 columns of color,
//  which is represented by an 3 bytes array : (r,g,b)
var grid;

// should be an uint8
//  if rotate = 0, il won't rotate, otherwise, it describes the time between 2 shift
var rotateImg = 0; //in sec * 100

//The speed of the globe, a good value is 35.
//  under 25, the globe can't turn
var rotationSpeed = 0; // arbitrary unit

//a lock use to don't write more than once on the file
var lock = false;

//The function is called each time you have to reset the img 
//  or change completly the img
function initGrid(){
    grid = new Array(100);
    for(var i=0; i<100; i++){
        grid[i] = new Array(49);
        for(var j=0; j<49; j++){
            grid[i][j] = new Array(0,0,0);
        }
    }
}

// Will load sphere file (sphere.colors by default, otherwise, the second arg)
var filename = "";
initGrid();

if(process.argv.length > 2){
    filename = process.argv[2];
}
else{
    filename = "sphere.colors";
}

loadSphereFile(filename);
var refreshFile = setInterval(save2file,1000);



// Websocket events management
io.on('connection', function (socket) {

    // used for save the file client-side
    socket.on("get raw file",function(){
        fs.readFile("sphere.colors",function(err,data){
            if(err){
                console.log(err);
                return;
            }
            socket.emit("get raw file",data);
        });
    });

    socket.on("set rot speed",function(data){
        rotationSpeed = Math.min(data,255);
        io.emit("set rot speed",data);
    });

    socket.on('set rot img',function (data){
        rotateImg = Math.min(data,255);
        io.emit("set rot img",data);
    });

    //receive a sphere.colors file and parse it
    socket.on('load file',function (data){
        var buffer = new Buffer(data,'binary');
        loadFromBuffer(buffer);
    });

    socket.on('fetch img',function (){
        // Don't need to add an other event client-side
        socket.emit("update img",grid);
    });

    socket.on('clear img', function (){
        initGrid();
        io.emit('update img',grid);
    });

    // change pixel by pixel the grid, useful when you just change 1 or 2 pixels
    // /!\ Don't use it if you wan't to change an entire img, 
    //     it's really too much long
    // pixel should be [[x,y], color]
    socket.on('update pixel',function (pixel){
        if(pixel[0][0] >= 100 || pixel[0][1] >= 49)
            return;
        if(!pixel)
            return;
        grid[pixel[0][0]][pixel[0][1]] = pixel[1];
        io.emit("update pixel",[[pixel[0][0],pixel[0][1]],pixel[1]]);
    });

    // change the img in only one send
    // /!\ Use update pixel if you wan't to change a little part of the img,
    //     otherwise, it'll be buggy and you will lose data (if you draw sthg but you don't send him),
    //     it will be erasen by previous data
    socket.on('update img',function (data){
        data = data;
        io.emit("update img",data);
        initGrid();
        grid = data;
    });
});


/*
 * Save the grid in sphere.colors file.
 * FORMAT (binary):
 *  - uint8: nbr of column (100)                    (1)
 *  - uint8: nbr of line (49)                       (2)
 *  - array: 100 * 49 colors (3 bytes) => 14700 bytes (3)
 *  - uint8: speed of the rotation of the image     (4)
 *  - uint8: speed of the globe                     (5)
 *  ==> 14704 bytes
 */
function save2file(data){
    if(!data)
        data = grid;
    if(lock)
        return;
    lock = true;
    try{
        var buf = new Buffer(14704);

        var offset = 0;

        buf.writeUInt8(100, offset++); // (1)
        buf.writeUInt8(49, offset++);  // (2)

        // (3)
        for(var x = 0; x<100;x++){
            for(var y = 0; y<49;y++){
                for(var i = 0; i<3 ;i++){
                    buf.writeUInt8(data[x][y][i],offset++);
                }
            
            }
        }

        buf.writeUInt8(rotateImg,offset++);  // (4)
        buf.writeUInt8(rotationSpeed,offset);// (5)
    }

    catch(err){
        console.log(err);
        // on any error, return, no fail
        return;
    }
    var wstream = fs.createWriteStream('sphere.colors');

    wstream.on('error', function (err) {
        console.log(err);
        return;
    });

    wstream.write(buf);
    wstream.end();
    lock = false;
}

function loadSphereFile(filename){
    fs.readFile(filename,function(err,data){
        if(err){
            console.log(err);
            save2file(grid);
            return;
        }
        loadFromBuffer(data);
    });     

}

// Parse the binary file and set up the all variables
// Need in entry a buffer of the good size containing the good data
function loadFromBuffer(data){
    var parser = new jParser(data,{
        columns       : 'uint8',
        lines         : 'uint8',
        image         : ['array',['array',["array",'uint8',3],49],100],
        shift         : 'uint8',
        rotationSpeed : 'uint8'
    });
    parser.parse('columns');
    parser.parse('lines');
    grid = parser.parse('image');
    rotateImg = parser.parse('shift');
    rotationSpeed = parser.parse('rotationSpeed');

    io.emit('update img',grid);
    io.emit('set rot img',rotateImg);
    io.emit('set rot speed',rotationSpeed);
}


process.stdin.on('data', function (text) {
    if (text == 'quit\n') {
        quit();
    }          
});

function quit(){
    console.log("Quit in 1,5s");
    clearInterval(refreshFile);
    setTimeout(function(){
        process.exit();
    },1500);
}
