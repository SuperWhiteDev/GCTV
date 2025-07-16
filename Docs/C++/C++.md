# C++
C++ is a powerful and high-performance programming language used for system-level scripting. This section covers how to utilize C++ for scripting in Game Command Terminal V, including details on functions, memory management, and tips for optimal performance.

## C++ Loader

The C++ scripts in your project are native plugins compiled into `.dll` or `.asi` files. On startup, the custom loader checks the `Scripts/` folder for any `.dll` or `.asi` and calls `LoadLibrary` for each of them. This gives you access to GTA V's internals, custom utilities, graphics routines, gamepad input - everything you need to create rich game systems.

## Core Includes & Modules

Every script should pull in the core headers that expose your engine’s API:

```cpp
#include "Game.h"           // Top-level game API (network functions, player/ped helpers, etc.)
#include "Console.hpp"      // Logging and Input functions: Print, Error, Input, InputFromList
#include "Functions.h"      // GCTV functions (Restart, RunScript, GetGCTVFolder, etc.)
#include "Graphics++.hpp"   // 2D drawing primitives, Implemented with ImGui
#include "Gamepad.hpp"      // Polling controller buttons, sticks, triggers
```

## Script Code

In the `main` function you can implement the logic of your script:

If you throw some c++ exception, it will be caught and displayed in the console as an error

```cpp
// Scripts/YourScript/script.cpp
#include "Console.hpp"
#include "Functions.h"

void main()
{
    // Called once, then your loop runs until unload
    while (GCTV::IsScriptsStillWorking())
    {
        throw std::runtime_error("Not implement yet");
    }
}
```

## Available Documentation

For details on additional functions available in the GCTV C++ Scripts, please refer to the documentation:

- **[Functions Documentation](Functions.md)** — Contains descriptions and examples of all custom functions provided by GCTV.
- **Folder Path:** `GCTV/Docs/C++/Functions.md`.

By leveraging C++ within GCTV, developers can enhance gameplay, create custom mechanics, and interact with the game world dynamically.

You can also explore the scripts in the `Scripts\features` folder and in `Scripts\examples` to get a better understanding of how everything works and take code templates for yourself

## Native Functions

To call an in-game native function, specify the namespace in which the function resides and use dot notation to access it, passing the required parameters. You can view the full list of native functions [here](https://alloc8or.re/gta5/nativedb/).