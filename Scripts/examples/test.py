from time import sleep
from os import path
from math import cos, sin

import GCT
import Game
from GTAV import PLAYER, ENTITY, PATHFIND

from utils.Graphics.graphicspp import Rect, Image, Watermark, Ellipse, RectWithBorders
from utils.Graphics.graphics_base import GetDisplaySize

rects : dict[int, Rect] = {}

if __name__ == "__main__":
    GCT.Globals.register("Sample.dll_state", "active(runned)")
    
    
    sleep(2)
    
    #img = Image(path.join(GCT.GetGCTFolder(),"Images","picture.png"), 1820, 980, 100, 100)
    
    #img2 = Image(path.join(GCT.GetGCTFolder(),"Images","lophophores.jpg"), 300, 0, 200, 300)
    
    # Need to fix all of this!!
    """
    rect = Rect(0, 0, 100, 200, 0, 200, 200, 100, 10.0)
    
    wm = Watermark("You are using Game Command Terminal", 0, 0, 300, 80, 0, 255, 255, 255, 255, 0, 255, "", 20)
    
    display_width, display_height = GetDisplaySize()
    radius = 10
    
    circle = Ellipse(display_width//2, display_height//2, radius, radius, 100, 220, 0, 255)
    
    rb_width = 130
    rb_height = 300
    rb = RectWithBorders(display_width-rb_width-10, 10, rb_width, rb_height, 255, 153, 204, 200, 230, 230, 230, 2, 5)
    """
    
    i = -1
    
    while GCT.IsScriptsStillWorking():
        sleep(1)
        
        #if i % 2 == 0:
        #    img.hide()
        #else:
        #    img.show()
        
        i += 1
        #vehs = GCT.GetAllVehicles()
        #peds = GCT.GetAllPeds()
        #objs = GCT.GetAllObjects()
        
        #GCT.GCTOut(f"Vehs {len(vehs)} Peds {len(peds)} objs {len(objs)}")
