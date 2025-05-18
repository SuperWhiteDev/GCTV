import os
import GCT
import utils.Graphics.graphicspp as Graphics

directory = GCT.GetGCTFolder()+"\\"+"Scripts\\features"

Graphics.Notification("Starting GCTV ...")

for filename in os.listdir(directory):
    if filename.endswith(".py"):
        GCT.RunScript(os.path.join(directory, filename))
    
""" 

import GCT
import Gamepad
from time import sleep

gamepad = Gamepad.Gamepad()
        
while GCT.IsScriptsStillWorking():
    print("LStick", gamepad.get_left_stick_state())
    print("RStick", gamepad.get_right_stick_state())
    sleep(0.5)
"""