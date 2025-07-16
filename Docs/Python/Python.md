# Python

Python is a versatile and widely used programming language known for its simplicity and readability. Here, you'll find information on integrating Python scripts into Game Command Terminal V, documentation on available APIs, and examples of practical use.

## Python Engine in GCTV

The Python engine in GCTV runs on Python 3.10.11 provides inbuilt functions, libraries including a graphics library, specifically designed for game scripting. These additional functions go beyond the standard Python capabilities and allow direct interaction with the game environment.

### Built-in Functions and Modules

GCTV includes custom modules tailored for game scripting:

- **`GCT`** – (Module) Provides basic GCTV functionality.
- **`GTAV`** – (Module) Contains all modules of native classes such as PLAYER, PED, VEHICLE, BUILTIN ... .
- **`Gamepad`** – (Class) Provides data from the gamepad such as pressed keys, stick positions and more
- **`Game`** – (Module) Allows for easy manipulation of game memory.
- ...

Additionally, all **native function modules** are registered within the Python environment. These functions mirror their official definitions, including names and parameter structures. You can find the full list of **GTA V native functions** [here](https://alloc8or.re/gta5/nativedb/).

## Available Documentation

For details on additional functions available in the GCTV Python engine, please refer to the documentation:

- **[Functions Documentation](Functions.md)** — Contains descriptions and examples of all custom functions provided by GCTV.
- **Folder Path:** `GCTV/Docs/Python/Functions.md`.

By leveraging Python within GCTV, developers can enhance gameplay, create custom mechanics, and interact with the game world dynamically.

You can also explore the scripts in the `Scripts\features` folder and in `Scripts\examples` to get a better understanding of how everything works and take code templates for yourself

## Native Functions

To call an in-game native function, import its namespace from the ‘GTAV’ module, through dot notation, specify the namespace and function name to access it, passing the necessary parameters. You can view the full list of native functions [here](https://alloc8or.re/gta5/nativedb/).

Native functions that return custom types such as `Ped`, `Entity`, `Vehicle`, `Object`, and others, actually return numeric identifiers. For example, the `Ped` type corresponds to a pointer to the ped structure in the game's memory.

Functions that return a `Vector3` in python provide a tuple with three values `x`,`y`, `z`. For example:

```python
from GTAV import ENTITY, PLAYER
player_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), True)
x, y, z = player_coords
print(f"Player coords: X = {x} Y = {y} Z = {z}")
```

If you need to pass a Vector3* (a pointer to a Vector3) to a function, you must first create one using NewVector3. For example:

```python
import GCT
import Game
from GTAV import MISC, ENTITY, PLAYER
minimum = GCT.NewVector3({ "x": 0.0, "y": 0.0, "z": 0.0 })
maximum = GCT.NewVector3({ "x": 0.0, "y": 0.0, "z": 0.0 })

if minimum and maximum:
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(PLAYER.PLAYER_PED_ID()), minimum, maximum)
    minX = Game.ReadFloat(minimum + 0 * 8) # base address + index(0) * 8
    minY = Game.ReadFloat(minimum + 1 * 8) # base address + index(1) * 8
    minZ = Game.ReadFloat(minimum + 2 * 8) # base address + index(2) * 8

    maxX = Game.ReadFloat(maximum + 0 * 8) # base address + index(0) * 8
    maxY = Game.ReadFloat(maximum + 1 * 8) # base address + index(1) * 8
    maxZ = Game.ReadFloat(maximum + 2 * 8) # base address + index(2) * 8

    print("Player minimum dimension", minX, minY, minZ)
    print("Player minimum dimension", maxX, maxY, maxZ)

    GCT.DeleteVector3(minimum)
    GCT.DeleteVector3(maximum)
```

Additionally, the Scripts/utils folder contains Python files that provide extra functions to work with the game's native functions.

## Available libraries

You can see a list of all available libraries by running the code below in a python environment in GCTV

```python
import pkgutil

modules = sorted(m.name for m in pkgutil.iter_modules())
print("\n".join(modules))
```

To install the library you need, you can either copy all the files associated with the library you need from the `Lib` and `DLLs` folder to the `Lib`, `DLLs` folder inside the `Python` folder in the GCTV root folder. To find out where the `Lib`, `DLLs` folders of your python environment are, type.

```bash
where python
```

in the terminal and you will get the path to the python environment. You can also copy the `DLLs`, `Libs` folders to the `Python` folder in the GCTV folder and then you will have access to all the libraries that are available to you from your normal python environment.

## Update

You can easily update the python version in GCTV by simply replacing python310.dll in the Python folder with the new version of pythonXXX.dll.