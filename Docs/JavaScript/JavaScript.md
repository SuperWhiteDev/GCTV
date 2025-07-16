# JavaScript

JavaScript is a dynamic programming language primarily used for web applications but also supported for game scripting. In Game Command Terminal V (GCTV), JavaScript is powered by the **Duktape** engine, which implements the **ECMAScript 5.1** standard. Duktape offers partial support for ECMAScript 6 features (e.g., Proxy objects, ArrayBuffer/TypedView functionalities). However, Duktape does not fully support the latest ECMAScript features, so some modern JavaScript capabilities may be unavailable. Before writing scripts, it is recommended to familiarize yourself with the specific ECMAScript version that Duktape supports to avoid unexpected limitations.

## JavaScript Engine in GCTV

The JavaScript engine in GCTV has several built-in functions and namespaces that extend its functionality beyond standard JavaScript. These additional features allow developers to interact with the game environment more efficiently.

### Built-in Functions and Namespaces

GCTV includes custom functions and namespaces designed for game scripting:

- **`require`** – Used for importing external modules.
- **`sleep`** – Allows adding delays in script execution.
- **`Game`** – Provides access to game-related functions and modifications.
- **`Input`** – Handles user input and interaction.

Additionally, all **native function namespaces** are registered in the JavaScript engine. These namespaces and functions mirror their official definitions, including names and parameter structures. You can find the full list of **GTA V native functions** [here](https://alloc8or.re/gta5/nativedb/).

## Available Documentation

For details on additional functions available in the GCTV JavaScript engine, please refer to the documentation:

- **[Functions Documentation](Functions.md)** — Contains descriptions and examples of all custom functions provided by GCTV.
- **Folder Path:** `GCTV/Docs/JavaScript/Functions.md`.

By leveraging JavaScript within GCTV, developers can extend gameplay, create custom mechanics, and interact with the game world in powerful ways.

## Native Functions

To call an in-game native function, you must specify the namespace in which the function resides and use dot notation to access it, passing the required parameters. You can view the full list of native functions [here](https://alloc8or.re/gta5/nativedb/).

Native functions that return custom types such as `Ped`, `Entity`, `Vehicle`, `Object`, and so on, actually return plain numbers. For example, the `Ped` type is simply an identifier corresponding to an element in an array of pointers to the ped structure in the game's memory.

Functions that return a `Vector3` in JavaScript will provide an object with the attributes `x`, `y`, and `z`. For example:
```js
var playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true);
console.log("Player coords: X = " + playerCoords.x + " Y = " + playerCoords.y + " Z = " + playerCoords.z);
```

If you need to pass a Vector3* (a pointer to a Vector3) to a function, you must first create one using Game.NewVector3. For example:
```js
const vecPtr = Game.NewVector3({ x: 0.0, y: 0.0, z: 0.0 });

if (TASK.WAYPOINT_RECORDING_GET_COORD("h3set1_buddy1", 1, vecPtr)) {
    var x = Game.ReadFloat(vecPtr + 0 * 8); // base address + index * 8
    var y = Game.ReadFloat(vecPtr + 1 * 8); // base address + index * 8
    var z = Game.ReadFloat(vecPtr + 2 * 8); // base address + index * 8

    console.log(x, y, z);
}

Game.DeleteVector3(vecPtr);
```

Additionally, the Scripts/utils folder contains JavaScript files that provide extra functions to work with the game's native functions.
