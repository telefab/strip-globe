#! /usr/bin/python3
# Python GUI to draw live on the globe
# By Tristan Gouge

import itertools,shutil
from struct import *
import PIL,sys,threading
from PIL import Image,ImageEnhance
from time import sleep

import tkinter
from tkinter.colorchooser import *
from tkinter.filedialog import askopenfilename,asksaveasfilename

k=8
canvas = None

def clamp(x,m):
    return max(0, min(x, m))

def rgb2hex(color):
    return "#{0:02x}{1:02x}{2:02x}".format(clamp(color[0],255), clamp(color[1],255), clamp(color[2],255))



class Tk2Text(threading.Thread):
    def __init__(self,gui):
        super().__init__(target=self.canvas2text,name="Canvas2Text")
        self._shouldRelease = False
        self._stop = False
        self.gui = gui
        self.start()

    def release(self):
        self._shouldRelease = True

    def stop(self):
        self._stop = True
        self.release()

    def canvas2text(self):
        x = 0
        global k
        while True:
            while not self._shouldRelease:
                pass
            if self._stop:
                return
            self._shouldRelease = False
            if not canvas:
                continue

            matrix = [["#000000" for x in range(49*k)] for x in range(100*k)] # matrix [100][49] 

            #fill a rect of k*k with the color of each object
            for id in canvas.find_overlapping(0,0,99*k,48*k):
                o = canvas.coords(id)
                if len(o)<4:
                    raise Exception("bad Coords")

                color = ""
                brushSize   =int((o[2] - o[0])/ k)
                newX        =int(o[2]) 
                newY        =int(o[1]) 
                color =  canvas.itemcget(id, "fill")

                for x in range(brushSize):
                    for y in range(brushSize):
                        matrix[clamp(newX+x,99*k)] [clamp(newY+y,48*k)] = color
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
            f.write(pack('B',0)
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
            deltaY = int((49 - newY)/2)
            maxY = newY
        else:
            newX = int(imgX/ratioY)
            img = img.resize((newX, 49), PIL.Image.ANTIALIAS)
            deltaX = int((100 - newX)/2)
            maxX = newX
            deltaY = 0
            maxY = 49

        m = img.load()

        matrix = [["#000000" for x in range(49)] for x in range(100)]

        # load the img in a matrix and convert rgb color to hex color
        for x in range(maxX):
            for y in range(maxY):
                matrix[x + deltaX][y + deltaY] = rgb2hex(m[x,y])
        self.gui.loadSphere(matrix)

class Gui:
    def __init__(self):

        #Canvas dimensions
        self.canvas_height = 48*k
        self.canvas_width = 99*k

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

        self.bouttonAskColor = tkinter.Button(self.master, command=self.selectColor)
        self.bouttonSelectImg = tkinter.Button(self.master,command=self.selectImg)
        self.bouttonLoadSphere = tkinter.Button(self.master, command=self.selectSphere)
        self.bouttonSaveSphere = tkinter.Button(self.master, command=self.saveSphere)

        self.labelAskBrushSize = tkinter.Label(self.master)
        self.bouttonAskBrushSize = tkinter.Scale(self.master, from_= 1 , to= 50, variable=self.brushSize,orient=tkinter.HORIZONTAL)

        self.labelAskRotationSpeed = tkinter.Label(self.master)
        self.bouttonAskRotationSpeed = tkinter.Scale(self.master, from_= 0 , to= 40, variable=self.speed, command=self.onSpeedChange, orient=tkinter.HORIZONTAL)

        self.bouttonClear = tkinter.Button(self.master, command=self.clear)
       
        self.lang = tkinter.StringVar()
        self.lang.set("en") # initialize

        #Select lang
        self.bouttonFr = tkinter.Radiobutton(self.master, text="Français", variable=self.lang, command=self.setLang, value = "fr")
        self.bouttonEn = tkinter.Radiobutton(self.master, text="English", variable=self.lang,command=self.setLang, value = "en")

        self.bouttonExit = tkinter.Button(self.master, command=self.stop)

        self.canvas.grid(row=0,column=0,rowspan=9)

        self.bouttonAskColor.grid(row=0,column=1,columnspan=2)
        self.bouttonSelectImg.grid(row=1,column=1,columnspan=2)
        self.bouttonSaveSphere.grid(row=2,column=1,columnspan=2)
        self.bouttonLoadSphere.grid(row=3,column=1,columnspan=2)

        self.labelAskBrushSize.grid(row=4,column=1)
        self.bouttonAskBrushSize.grid(row=4,column=2)

        self.labelAskRotationSpeed.grid(row=5,column=1)
        self.bouttonAskRotationSpeed.grid(row=5,column=2)

        self.bouttonClear.grid(row=6,column=1, columnspan=2)
        
        self.bouttonFr.grid(row=7,column=1)
        self.bouttonEn.grid(row=7,column=2)

        self.bouttonExit.grid(row=8,column=1, columnspan=2)


        #initialize Bindings
        self.canvas.bind( "<B1-Motion>", self.paint )


        self.master.wm_protocol ("WM_DELETE_WINDOW", self.stop)  # does work

        self.master.resizable(width=False, height=False)

        self.setLang()
        tkinter.mainloop()

    def setLang(self,lang=''):
        if lang == '':
            lang = self.lang.get()
        languages = {
                "fr" : {
                    "askColor" : "Cliquez pour choisir la couleur",
                    "selectImg" : "Cliquez pour charger une image",
                    "loadSphere" : "Cliquez pour charger une sphère",
                    "saveSphere" : "Cliquez pour sauvegarder l'image dessinée",
                    "brushSize" : "Taille de la brosse",
                    "speedRotation" : "Vitesse de rotation",
                    "clear" : "Nettoyer la zone de dessin",
                    "exit" : "Quitter"
                    },
                "en" : {
                    "askColor" : "Click to choose the color",
                    "selectImg" : "Click to load a picture",
                    "loadSphere" : "Click to load a saved sphere",
                    "saveSphere" : "Click to save the drawed sphere",
                    "brushSize" : "Brush size",
                    "speedRotation" : "Rotation speed",
                    "clear" : "Clear",
                    "exit" : "Exit"
                    }
                }

        self.bouttonAskColor["text"]        = languages[lang]["askColor"]
        self.bouttonSelectImg["text"]       = languages[lang]["selectImg"]
        self.bouttonLoadSphere["text"]      = languages[lang]["loadSphere"]
        self.bouttonSaveSphere["text"]      = languages[lang]["saveSphere"]
        self.labelAskBrushSize["text"]      = languages[lang]["brushSize"]
        self.labelAskRotationSpeed["text"]  = languages[lang]["speedRotation"]
        self.bouttonClear["text"]           = languages[lang]["clear"]
        self.bouttonExit["text"]            = languages[lang]["exit"]






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
        sleep(.2)
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
                self._paint(x*k,y*k,matrix[x][y],False)
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
        # call this fct at the end of the prg
        self.tk2text.stop()
        self.master.destroy()

    def onSpeedChange(self, event):
        # Not supported on the globe (software part)
        self.tk2text.release()

    def paint(self,event):
        # a callback on mouse click-and-move behavior
        x, y = event.x,event.y
        if x > self.canvas_width or y > self.canvas_height:
            return

        # remove objects the color is black (buggy)
        #if self.color == "#000000":
        #    items = self.canvas.find_enclosed(x-k/2,y-k/2, x+k/2,y+k/2)
        #    for item in items:
        #        self.canvas.delete(item)
        #    self.tk2text.release()
        #    return

        # otherwise, create a new object

        # allow to align with the 49 * 100 matrix
        newX = int((x+1)/k) * k  
        newY = int((y+1)/k) * k 
        self._paint(newX,newY,self.color,True)
        self.tk2text.release()

    def _paint(self,x,y,color,useBrushSize = True):
        # draw a rect of k*k of center the point (x,y) and fill it with the color pass in argument
        if useBrushSize:
            rect = self.canvas.create_rectangle(
                int((x - int(k * self.brushSize.get()/2)) / k) * k,
                int((y - int(k * self.brushSize.get()/2)) / k) * k,
                int((x + int(k * self.brushSize.get()/2)) / k) * k,
                int((y + int(k * self.brushSize.get()/2)) / k) * k,
                fill=color, width=0)

        else:
            rect = self.canvas.create_rectangle(
                int(x - k/2),
                int(y - k/2),
                int(x + k/2),
                int(y + k/2),
                fill=color, width=0)

        # bah !!! It's really ugly !
        global canvas
        canvas = self.canvas


if __name__ == "__main__":
    gui = Gui()
