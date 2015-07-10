#! /usr/bin/python3
# Python GUI to draw live on the globe
# By Tristan Gouge

import itertools,shutil
from struct import *
import PIL,sys,threading
from PIL import Image,ImageEnhance

import tkinter
from tkinter.colorchooser import *
from tkinter.filedialog import askopenfilename,asksaveasfilename

k=8
canvas = None

def rgb2hex(color):
    def clamp(x):
        return max(0, min(x, 255))

    return "#{0:02x}{1:02x}{2:02x}".format(clamp(color[0]), clamp(color[1]), clamp(color[2]))



class Tk2Text(threading.Thread):
    def __init__(self,gui):
        super().__init__(target=self.canvas2text,name="Canvas2Text")

        self.lock = threading.Lock()

        self._stop = threading.Event()
        self._stop.clear()

        self.gui = gui

        self.start()

    def release(self):

        #Need a try-Except because is the lock is already release it crashes
        try:
            self.lock.release()
        except:
            pass

    def stop(self):
        # don't totaly work
        self._stop.set()
        self.release()

    def canvas2text(self):
        x = 0
        global k
        self.lock.acquire()
        while not self._stop.is_set():
            self.lock.acquire()

            if not canvas:
                continue
            def clamp(x,m):
                return max(0, min(x, m))

            matrix = [["#000000" for x in range(49*k)] for x in range(100*k)]

            #fill a rect of k*k with the color of each object
            for id in canvas.find_overlapping(0,0,100*k,49*k):
                o = canvas.coords(id)
                if len(o)>1:
                    color = ""
                    dx = int(o[2] - o[0])
                    dy = int(o[3] - o[1])
                    color =  canvas.itemcget(id, "fill")

                    for x in range(dx):
                        for y in range(dy):
                            matrix[clamp(int(o[0]) + x,100*k-1)] [clamp(int(o[1]) + y,49*k-1)] = color

            finalMatrix = [[matrix[x*k][y*k] for y in range(49)] for x in range(100)]


            try:
                f = open('sphere.colors', 'wb')
            except IOError:
                print("Can't open sphere.colors file !!")
                return

            # begin to write into the file

            # the size of the img Matrix
            f.write(pack('2B',*[100,49]))

            # the color in rgb on 3*100*49 = 14 700 bytes
            for x in range(100):
                for y in range(49):
                    for n in range(0,3):
                        f.write(pack('B',
                            int(finalMatrix[x][y][n*2+1:n*2+3],16)))

            # the rotation speed on 1 byte
            f.write(pack('B',self.gui.getRotationSpeed()))
            f.close()

    def img2text(self,filename):
        if not filename:
            print("Need filename")
            return

        img = PIL.Image.open(filename)

        #increase contrast
        enhancer = PIL.ImageEnhance.Contrast(img)
        img = enhancer.enhance(5)
        enhancer = PIL.ImageEnhance.Sharpness(img)
        img = enhancer.enhance(2)

        imgX = img.size[0]
        imgY = img.size[1]
        ratioX = float(imgX)/100
        ratioY = float(imgY)/49
        if ratioX > ratioY:
            newY = int(imgY/ratioX)
            img = img.resize((100, newY), PIL.Image.ANTIALIAS)
            deltaX = 0
            maxX = 100
            deltaY = (49 - newY)/2
            maxY = newY
        else:
            newX = int(imgX/ratioY)
            img = img.resize((newX, 49), PIL.Image.ANTIALIAS)
            deltaX = (100 - newX)/2
            maxX = newX
            deltaY = 0
            maxY = 49

        m = img.load()

        matrix = [["#000000" for x in range(49)] for x in range(100)]

        # load the img in a matrix and convert rgb color to hex color
        for x in range(img.size[0]):
            for y in range(img.size[1]):
                readX = x + deltaX
                readY = y + deltaY
                if readX < maxX and readY < maxY:
                    matrix[x][y] = rgb2hex(m[readX,readY])

        self.gui.loadSphere(matrix)

class Gui:
    def __init__(self):

        #Canvas dimensions
        self.canvas_height = 49*k-1
        self.canvas_width = 100*k-1

        #initialize Main window
        self.tk2text = Tk2Text(self)
        self.master = tkinter.Tk()
        self.master.title( "sphere drawing" )

        #initialize Canvas
        self.canvas = tkinter.Canvas(self.master,
           width=self.canvas_width,
           height=self.canvas_height,
           bg="black")


        self.color = "#FFFFFF"
        self.speed = tkinter.IntVar()
        self.brushSize = tkinter.IntVar()

        #initialize Buttons

        bouttonAskColor = tkinter.Button(self.master, text = "click to select color", command=self.selectColor)
        bouttonSelectImg = tkinter.Button(self.master, text = "click to select an image", command=self.selectImg)
        bouttonLoadSphere = tkinter.Button(self.master, text = "click to load a sphere", command=self.selectSphere)
        bouttonSaveSphere = tkinter.Button(self.master, text = "click to save the drawed sphere", command=self.saveSphere)

        labelAskBrushSize = tkinter.Label(self.master, text="Brush size")
        bouttonAskBrushSize = tkinter.Scale(self.master, from_= 1 , to= 50, variable=self.brushSize,orient=tkinter.HORIZONTAL)

        labelAskRotationSpeed = tkinter.Label(self.master, text="Speed Rotation")
        bouttonAskRotationSpeed = tkinter.Scale(self.master, from_= 0 , to= 40, variable=self.speed, command=self.onSpeedChange, orient=tkinter.HORIZONTAL)

        bouttonClear = tkinter.Button(self.master, text = "Clear", command=self.clear)

        self.canvas.grid(row=0,column=0,rowspan=7)

        bouttonAskColor.grid(row=0,column=1,columnspan=2)
        bouttonSelectImg.grid(row=1,column=1,columnspan=2)
        bouttonSaveSphere.grid(row=2,column=1,columnspan=2)
        bouttonLoadSphere.grid(row=3,column=1,columnspan=2)

        labelAskBrushSize.grid(row=4,column=1)
        bouttonAskBrushSize.grid(row=4,column=2)

        labelAskRotationSpeed.grid(row=5,column=1)
        bouttonAskRotationSpeed.grid(row=5,column=2)

        bouttonClear.grid(row=6,column=1, columnspan=2)


        #initialize Bindings
        self.canvas.bind( "<B1-Motion>", self.paint )
        self.master.protocol("WM_DELETE_WINDOW", self.stop)

        self.master.resizable(width=False, height=False)
        tkinter.mainloop()

    def selectSphere(self):
        filename = askopenfilename(parent=self.master,filetypes = [("Sphere's colors File",'.colors')])
        if not filename:
            return
        try:
            f = open(filename,"rb")
        except IOError:
            print("error during file loading")
            return
        xMax = unpack('B',f.read(1))[0]
        yMax = unpack('B',f.read(1))[0]
        matrix = [["#000000" for x  in range(yMax)] for x in range(xMax)]
        for x in range(xMax):
            for y in range(yMax):
                color = unpack('3B',f.read(3))
                matrix[x][y] = rgb2hex(color)
        self.speed.set(unpack('B',f.read(1)))
        self.loadSphere(matrix)

    def saveSphere(self):
        #just copy the current sphere to the desired file

        self.tk2text.release()
        filename = asksaveasfilename(parent=self.master,filetypes = [("Sphere's colors File",'.colors')])

        if not filename:
            return
        try:
            shutil.copyfile("sphere.colors",filename)
        except IOError as error:
            print("error during the save", error)

    def loadSphere(self,matrix,removeOld=True):
        # Draw a matrix to the Canvas
        # if removeOld is set to False, the canvas won't be delete

        if removeOld:
            self.canvas.delete()
        for x in range(len(matrix)):
            for y in range(len(matrix[x])):
                self._paint(x*k,y*k,matrix[x][y])
        self.tk2text.release()

    def getRotationSpeed(self):
        return self.speed.get()

    def selectImg(self):
        # a callback for the select Image Button
        # this fct will open an image and draw the image to the canvas

        filename = askopenfilename(parent=self.master,filetypes = [('Image File','.*')])
        self.tk2text.img2text(filename)

    def selectColor(self):
        # a callback for the select color button

        self.color = askcolor(self.color)[1]

    def clear(self):
        # clear all objects of the Canvas
        self.canvas.delete("all")
        self.tk2text.release()

    def stop(self):
        # Don't totaly work, should stop all thread and finish the program
        self.tk2text.stop()
        self.master.destroy()

    def onSpeedChange(self, event):
        self.tk2text.release()

    def paint(self,event):
        # a callback on mouse click-and-move behavior

        x, y = event.x,event.y
        if x > self.canvas_width or y > self.canvas_height:
            return

        # remove objects the color is black (buggy)
        #if self.color == "#000000":
        #    items = self.canvas.find_enclosed(x-k,y-k, x+k,y+k)
        #    for item in items:
        #        self.canvas.delete(item)
        #    self.tk2text.release()
        #    return

        # otherwise, create a new object
        self._paint(x,y,self.color)
        self.tk2text.release()

    def _paint(self,x,y,color,useBrushSize = True):
        # draw a rect of k*k of center the point (x,y) and fill it with the color pass in argument
        if useBrushSize:
            rect = self.canvas.create_rectangle(
                int(x- k/2 - k*self.brushSize.get()/2),
                int(y - k/2 - k*self.brushSize.get()/2),
                int(x + k/2 + k*self.brushSize.get()/2),
                int(y + k/2 + k*self.brushSize.get()/2),
                fill=color, width=0)

        else:
            rect = self.canvas.create_rectangle(
                int(x- k/2),
                int(y - k/2),
                int(x + k/2),
                int(y + k/2),
                fill=color, width=0)

        # bah !!! It's really ugly !
        global canvas
        canvas = self.canvas


if __name__ == "__main__":
    gui = Gui()
