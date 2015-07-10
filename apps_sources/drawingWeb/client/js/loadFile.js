// Hum... load a file, I thing

// This fct is only called by an event, e is an event object.
//
// 2 types of file are supported, img files and colors files
function loadFile(e) {
    if (window.Blob) {
        // Great success! All the File APIs are supported.
    } else {    
        return;
    }

    //Check the filetype of the file

    var fileType = e.target.files[0].name.split('.');
    fileType = fileType[fileType.length - 1].toLowerCase();
    if(['png', 'jpg', 'jpeg', 'gif'].indexOf(fileType) != -1){
        //is img file

        //Caman need an image or a canvas, so, we create an invisible img element 
        //    and you pass it to Caman
        var img = document.createElement('img');
        img.setAttribute('style','display: none');
        img.setAttribute('id','img');

        img.src = URL.createObjectURL(e.target.files[0]);

        $("body").append(img);

        img.addEventListener("load",function(){
            // Modify the image making it more contrasted and more... sharped and finally pass the baton to renderImg
            Caman("#img",function(){
                if($("#imgProcessing:checked").val() == "on"){
                    this.sharpen(50);
                    this.contrast(100);
                }
                this.render(renderImg);
            });
        });
    }

    if(['colors'].indexOf(fileType) != -1){
        //is sphere file
        var reader = new FileReader();
        reader.onload = function(e){
            socket.emit('load file',e.target.result);
        }
        reader.readAsBinaryString(e.target.files[0]);
    }

    function renderImg() {
        //yes, img is a canvas now thks Caman !
        var c = document.getElementById('img');

        // resize the Img to 49*100 keeping proportions
        
        var ratioX = c.width / 100;
        var ratioY = c.height / 49;
        
        var newY,newX;

        var dx,dy; // to put the img to the center

        if(ratioX > ratioY){
            newY = Math.round(c.height / ratioX);
            newX = 100;
            dx = 0;
            dy = Math.round((49 - newY) /2);
        } 
        else{
            newX = Math.round(c.width / ratioY);
            newY = 49;
            dy = 0;
            dx = Math.round((100 - newX) /2);
        }

        var canvas = document.createElement('canvas');
        var context = canvas.getContext("2d");
        
        canvas.width = 100;
        canvas.height = 49;
        
        img = new Image ();
        img.src = c.toDataURL();
        
        context.drawImage(img,0,0,img.width,img.height, dx, dy, newX, newY);
       
        //get the canvas as a pixel Array and put all data in the grid
        var imgData = context.getImageData(0,0,100,49).data;

        initGrid(); // I prefer reset the grid before, I had some trouble because I didn't do that why ? Because Js !
        
        // the array is in one line (too easy other wise)
        var offset = 0;
        for(var x=0; x<100; x++){
            for(var y=0; y<49; y++){
                offset = (y * 100 + x )*4;
                grid[x][y] = [imgData[offset],imgData[++offset],imgData[++offset]];
                // and alpha go to junk, we don't wan't you alpha !
            }

        }

        loadFromGrid();
        
        socket.emit('update img',grid);
        
        //Caman don't like when he have already compute an img (he put an attribute)
        // and I don't like to create two times the same object
        $('#img').remove();

    }
}

// When you choose a file, this event allow me to read your file
document.getElementById('files').addEventListener('change', loadFile, false);
