# Lua

Lua is a lightweight, high-performance scripting language commonly used for embedded applications and game development. In Game Command Terminal V (GCTV), Lua powers scripting capabilities, allowing developers to modify game behavior and create custom functionality.

## Lua Engine in GCTV

The Lua engine in GCTV provides inbuilt functions, libraries including a graphics library, specifically designed for game scripting. These additional functions go beyond the standard Lua capabilities and allow direct interaction with the game environment.

### Built-in Functions and Modules

GCTV includes custom functions and modules tailored for game scripting:

- **`require`** – (Function) Loads external Lua modules.
- **`Wait`** – (Function) Pauses execution for a specified amount of time.
- **`Gamepad`** – (Object) Provides data from the gamepad such as pressed keys, stick positions and more
- **`Call`** – (Function) Allows you to call functions from dll libraries so the possibilities for lua scripting are simply unlimited.
- ...

Additionally, all **native function namespaces** are registered within the Lua environment. These functions mirror their official definitions, including names and parameter structures. You can find the full list of **GTA V native functions** [here](https://alloc8or.re/gta5/nativedb/).

## Available Documentation

For details on additional functions available in the GCTV Lua engine, please refer to the documentation:

- **[Functions Documentation](Functions.md)** — Contains descriptions and examples of all custom functions provided by GCTV.
- **Folder Path:** `GCTV/Docs/Lua/Functions.md`.

By leveraging Lua within GCTV, developers can enhance gameplay, create custom mechanics, and interact with the game world dynamically.

You can also explore the scripts in the `Scripts\features` folder and in `Scripts\examples` to get a better understanding of how everything works and take code templates for yourself

## Native Functions

To call an in-game native function, specify the namespace in which the function resides and use dot notation to access it, passing the required parameters. You can view the full list of native functions [here](https://alloc8or.re/gta5/nativedb/).

Native functions that return custom types such as `Ped`, `Entity`, `Vehicle`, `Object`, and others, actually return numeric identifiers. For example, the `Ped` type corresponds to a pointer to the ped structure in the game's memory.

Functions that return a `Vector3` in Lua will provide a table with attributes `x`, `y`, and `z`. For example:

```lua
local playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
print("Player coords: X = " .. playerCoords.x .. " Y = " .. playerCoords.y .. " Z = " .. playerCoords.z)
```

If you need to pass a Vector3* (a pointer to a Vector3) to a function, you must first create one using NewVector3. For example:

```lua
local minimum = NewVector3({ x = 0.0, y = 0.0, z = 0.0 })
local maximum = NewVector3({ x = 0.0, y = 0.0, z = 0.0 })

if minimum and maximum then
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(PLAYER.PLAYER_PED_ID()), minimum, maximum)
    local minX = Game.ReadFloat(minimum + 0 * 8) -- base address + index * 8
    local minY = Game.ReadFloat(minimum + 1 * 8) -- base address + index * 8
    local minZ = Game.ReadFloat(minimum + 2 * 8) -- base address + index * 8

    local maxX = Game.ReadFloat(maximum + 0 * 8) -- base address + index * 8
    local maxY = Game.ReadFloat(maximum + 1 * 8) -- base address + index * 8
    local maxZ = Game.ReadFloat(maximum + 2 * 8) -- base address + index * 8

    print("Player minimum dimension", minX, minY, minZ)
    print("Player minimum dimension", maxX, maxY, maxZ)
end

DeleteVector3(minimum)
DeleteVector3(maximum)
```

Additionally, the Scripts/utils folder contains Lua files that provide extra functions to work with the game's native functions.

## IDE Setup for Lua Scripting

To significantly enhance your Lua scripting experience within GCTV, especially with features like autocompletion and type checking, it is highly recommended to use an Integrated Development Environment (IDE) such as **VS Code**.

The GCTV project is pre-configured to provide an optimal development environment for Lua. It includes:

* **Definition Files (Stubs)**: Located in the `lua_typings/` directory, these files provide your IDE with detailed information about GCTV's built-in functions, custom modules (like `map_utils`, `world_utils`), and all GTA V native functions. This allows your IDE to offer intelligent hints and autocompletion, even though the actual implementations are external to your Lua scripts.

* **VS Code Workspace Settings**: A `.vscode/settings.json` file is included in the project root. This file automatically configures the recommended Lua extension to use the provided definition files, ensuring a seamless setup.

## Steps to Configure VS Code

1.**Install VS Code**: If you don't have it already, download and install Visual Studio Code from the [official website](https://code.visualstudio.com/).

2.**Install the Lua Extension**:
    * Open VS Code.
    * Navigate to the Extensions view (Ctrl+Shift+X or Cmd+Shift+X).
    * Search for "Lua" and install the extension by **sumneko**. This is the recommended Lua language server for robust features.

3.**Open the GCTV Project Folder**:
    * Open VS Code and choose "File" > "Open Folder...".
    * Navigate to and select the root directory of your GCTV project (the folder containing `Scripts/` and `.vscode/`).


Once the folder is opened, VS Code will automatically detect and apply the settings from `.vscode/settings.json`. The sumneko Lua extension will then use the definition files in `lua_typings/` to provide:

`Warning: Open the Lua extension settings and go to Lua->Workspace: Preload File Size and change from 500 to 2000 so that the file with native function declarations for IntelliSense can be loaded.`

* **Autocompletion**: Suggestions for GCTV built-in functions (e.g., `Input`, `DisplayError`), native GTA V functions (e.g., `PLAYER.PLAYER_PED_ID`, `MISC.GET_WIND_SPEED`), and functions from custom utility modules (e.g., `map_utils.get_waypoint_coords`).
* **Parameter Hints**: Information about the expected parameters when you call a function.
* **Type Checking**: Basic static analysis to catch potential type-related errors in your Lua scripts.

This setup significantly streamlines the Lua scripting process within GCTV, allowing you to write code more efficiently and with fewer errors.