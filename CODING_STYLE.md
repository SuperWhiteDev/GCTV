# GCTV Coding Style Guide

This guide establishes consistent coding standards across all programming languages used in the GCTV project (Python, C++, Lua, JavaScript) to ensure readability, maintainability, and collaboration.

---

## 1. Naming Conventions

### 1.1. Variables, Functions, and Local Scope: `snake_case`

Use `snake_case` (lowercase words separated by underscores) for all variable names, function names, and methods within classes or modules. This applies to local variables and private/protected members where applicable.

**Examples:**
* **Python:** `user_input`, `process_data()`
* **C++:** `int entity_id;`, `void get_player_coords();`
* **Lua:** `local current_vehicle`, `function update_status()`
* **JavaScript:** `let player_health;`, `function calculate_distance() {}`

### 1.2. Classes and Types: `PascalCase`

Use `PascalCase` (first letter of each word capitalized) for class names, struct names, enums, and custom types.

**Examples:**
* **Python:** `class PlayerManager:`
* **C++:** `class VehicleControl;`, `enum CommandType;`
* **Lua:** (N/A, Lua is not object-oriented in the same way, but applies to constructors or factory functions like `Player:new()`)
* **JavaScript:** `class GameState;`

### 1.3. Global Variables (GCTV Registered): `PascalCase`

For global variables registered through specific GCTV mechanisms (e.g., Lua's `RegisterGlobalVariable`), use `PascalCase`. This clearly distinguishes them as globally accessible project-specific entities.

**Examples:**
* **Python:** `GCT.Globals.register("VehicleSmokeLevel", 9.0)`
* **C++:** `GCTV::Global::Register("ThisScriptStatus", "active");`
* **Lua (GCTV):** `RegisterGlobalVariable("PlayerVehicleHandle", 0.0)`
* **JavaScript:** `global.register("Friend name", "Ethan Hunt");`

### 1.4. GCTV Framework Functions / API: `camelCase`

For functions provided by the core GCTV framework or its specific APIs, use `PascalCase` (first word lowercase, subsequent words capitalized).

**Examples:**
* `GetGCTFolder()`
* `GetGCTStringVersion()`

### 1.5. Native Functions (Game/System API): `UPPER_SNAKE_CASE`

When calling native functions from the game engine or underlying system (e.g., RAGE Native functions, Windows API), follow their established naming convention. Often, these are `UPPER_SNAKE_CASE`. Do not rename or wrap them merely for stylistic reasons unless creating a clear, intention-revealing abstraction.

**Examples:**
* `PLAYER.PLAYER_PED_ID()` (Lua)
* `ENTITY.GET_ENTITY_FORWARD_VECTOR(entity)` (Python)
* `APPLY_DAMAGE_TO_PED(ped, damageAmount, p2, p3, weaponType)` (JavaScript)

### 1.6. Constants: `UPPER_SNAKE_CASE`

Use `UPPER_SNAKE_CASE` (all uppercase words separated by underscores) for constants, which are values that do not change during program execution.

**Examples:**
* **Python:** `MAX_PLAYERS = 32`
* **C++:** `const int MAX_RETRIES = 5;`
* **Lua:** `local DEFAULT_TIMEOUT_MS = 1000`
* **JavaScript:** `const PI = 3.14159;`

### 1.7. File Names: `snake_case`

All source code files (`.py`, `.cpp`, `.h`, `.lua`, `.js`, etc.) should use `snake_case`.

**Examples:**
* `player_commands.lua`
* `vehicle_control.cpp`
* `network_utils.py`
* `ui_elements.js`

---

## 2. Formatting

### 2.1. Indentation

Use **4 spaces** for indentation. Never use tabs. Configure your editor accordingly.

### 2.2. Whitespace

* Place a single space around binary operators (`=`, `+`, `-`, `*`, `/`, `==`, `!=`, `<`, `>`, `<=`, `>=`, `and`, `or`, `not`).
* Place a single space after commas in lists, arguments, and table/array declarations.
* Avoid trailing whitespace at the end of lines.

### 2.3. Line Length

Aim for a maximum line length of **120 characters**. Break longer lines into multiple lines for readability.

### 2.4. Trailing Commas

Prefer using trailing commas in multi-line lists, arrays, or table definitions where supported by the language. This reduces diff noise and makes reordering or adding elements cleaner.