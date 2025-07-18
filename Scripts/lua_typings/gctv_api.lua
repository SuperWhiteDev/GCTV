--- Generated by Gemini.
--- 

--- @alias Coords {x: number, y: number, z: number}

---@global ScriptStillWorking boolean
---@diagnostic disable: undefined-global
--- GCT Functions
--- 
--- Returns the current GCT version as a number.
--- @return number The GCT version.
function GetGCTVersion() end

--- Returns the current GCT version as a string.
--- @return string The GCT version string.
function GetGCTStringVersion() end

--- Returns the path to the GCT folder.
--- @return string The GCT folder path.
function GetGCTFolder() end

--- Displays help information.
function help() end

--- Pauses script execution for a specified duration.
--- @param ms integer The duration to wait in milliseconds.
function Wait(ms) end

--- Runs another Lua script.
--- @param path string The path to the script.
--- @return boolean True if the script was successfully started, false otherwise.
function RunScript(path) end

--- Converts a string representation of a key (e.g., "ENTER", "ESC") to its corresponding key code.
--- @param key_name string The name of the key.
--- @return integer The key code.
function ConvertStringToKeyCode(key_name) end

--- Checks if a specific key is currently pressed.
--- @param key_code integer The key code to check.
--- @return boolean True if the key is pressed, false otherwise.
function IsPressedKey(key_code) end

--- Retrieves the current mouse cursor position.
--- @return number x The X-coordinate of the mouse cursor.
--- @return number y The Y-coordinate of the mouse cursor.
function GetMousePos() end

--- Sets the mouse cursor position.
--- @param x number The X-coordinate to set.
--- @param y number The Y-coordinate to set.
function SetMousePos(x, y) end

--- Restarts the GCT application.
function Restart() end

--- Calls a game native function.
--- @param function_hash number The hash of the native function to call.
--- @param return_type string The expected return type ("string", "integer32", "integer", "number", "boolean").
--- @param args_table table A table of arguments to pass to the native function. Values in the table can be numbers, strings, or booleans.
--- @return any The return value of the native function, cast to the specified type.
function NativeCall(function_hash, return_type, args_table) end

--- Hashes a string to a 64-bit integer.
--- @param str string The string to hash.
--- @return number The hashed value of the string.
function HashString(str) end

--- Json Functions
--- ---
--- Saves data to a JSON file.
--- @param path string The path to the JSON file.
--- @param data table
function JsonSave(path, data) end

--- Reads a value from a JSON file.
--- @param path string The path to the JSON file.
--- @return table The read value, or nil if not found.
function JsonRead(path) end

--- Reads a list (table) of values from a JSON file.
--- @param path string The path to the JSON file.
--- @return table<integer, string|number|boolean> A table containing the read values.
function JsonReadList(path) end

--- Saves a list (table) of values to a JSON file.
--- @param path string The path to the JSON file.
--- @param data table
function JsonSaveList(path, data) end

--- Communication Functions
--- ---
--- Registers a global variable in the GCT environment.
--- The variable can be accessed by other scripts.
--- @param variable_name string The name of the global variable.
--- @param value string|number|boolean|table The initial value of the global variable. If a table, it should be a flat list of strings or numbers.
function RegisterGlobalVariable(variable_name, value) end

--- Retrieves the value of a global variable.
--- @param variable_name string The name of the global variable.
--- @return string|number|boolean|table|nil The value of the global variable, or nil if not found. If the variable was registered as a table (vector), it will be returned as a Lua table.
function GetGlobalVariable(variable_name) end

--- Sets the value of an existing global variable.
--- @param variable_name string The name of the global variable.
--- @param value string|number|boolean|table The new value for the global variable. If a table, it should be a flat list of strings or numbers.
function SetGlobalVariableValue(variable_name, value) end

--- Checks if a global variable with the given name exists.
--- @param variable_name string The name of the global variable.
--- @return boolean True if the global variable exists, false otherwise.
function IsGlobalVariableExist(variable_name) end

--- Calls a C++ function by its prototype string and passes arguments.
--- This is a generic function to call various internal C++ methods.
--- The return type is dynamic based on the prototype.
--- @param prototype string The prototype string representing the C++ function signature and return type (e.g., "void func()", "int func(float, string)").
--- @param ... any Optional arguments to pass to the C++ function.
--- @return any The return value of the C++ function, type depends on the prototype.
function Call(prototype, ...) end

--- Terminal Functions

--- Prints a Lua table to the terminal.
--- @param tbl table The table to print.
function printTable(tbl) end

--- Binds a Lua function to a terminal command.
--- @param command string The command name (e.g., "mycommand").
--- @param callback function The Lua function to execute when the command is entered.
function BindCommand(command, callback) end

--- Unbinds a Lua function from a terminal command.
--- @param command string The command name to unbind.
function UnBindCommand(command) end

--- Checks if a terminal command is already bound.
--- @param command string The command name to check.
--- @return boolean True if the command is bound, false otherwise.
function IsCommandExist(command) end

--- Prints a message to the terminal with a specified color.
--- @param color string The name of the color (e.g., "red", "green", "blue", "yellow", etc.).
--- @param ... any The values to print. Can be strings, numbers, or booleans.
function printColoured(color, ...) end

--- Sets the terminal's text color.
--- @param color string The name of the color (e.g., "red", "green", "blue").
function SetColor(color) end

--- Resets the terminal's text color to default.
function ResetColor() end

--- Prompts the user for input in the terminal.
--- The prompt will be prefixed with the current script's name.
--- @param prompt string The message to display as a prompt.
--- @param to_lower boolean If true, the input will be converted to lowercase.
--- @return string The user's input.
function Input(prompt, to_lower) end

--- Prompts the user to select an option from a list in the terminal.
--- The prompt will be prefixed with the current script's name.
--- @param prompt string The message to display as a prompt.
--- @param options table<integer, string> A table of strings representing the available options.
--- @return integer The 1-based index of the selected option.
function InputFromList(prompt, options) end

--- Prompts the user to enter an RGB color in the format "R G B".
--- @return integer r The red component (0-255).
--- @return integer g The green component (0-255).
--- @return integer b The blue component (0-255).
function InputRGB() end

--- Displays an error message in the terminal and optionally in-game.
--- The error message will be prefixed with the current script's name.
--- @param display_in_game boolean If true, the error will also be displayed in-game.
--- @param ... any The values to display as an error message. Can be strings, numbers, or booleans.
function DisplayError(display_in_game, ...) end

--- Resets the current terminal line and prints a new message.
--- @param ... any The values to print. Can be strings, numbers, or booleans.
function ResetLineAndPrint(...) end

--- Memory Functions
--- ---
--- Allocates a block of memory of a specified size.
--- @param size number The size of the memory block to allocate in bytes.
--- @return number A pointer (address) to the allocated memory.
function New(size) end

--- Allocates memory for a pointer and stores a given value in it.
--- @param value number The 64-bit integer value to store in the new pointer.
--- @return number A pointer (address) to the allocated memory holding the value.
function NewPointer(value) end

--- Allocates memory for a Ped handle and stores a given value in it.
--- @param ped_handle number The Ped handle to store.
--- @return number A pointer (address) to the allocated memory holding the Ped handle.
function NewPed(ped_handle) end

--- Allocates memory for a Vehicle handle and stores a given value in it.
--- @param vehicle_handle number The Vehicle handle to store.
--- @return number A pointer (address) to the allocated memory holding the Vehicle handle.
function NewVehicle(vehicle_handle) end

--- Allocates memory for an Object handle and stores a given value in it.
--- @param object_handle number The Object handle to store.
--- @return number A pointer (address) to the allocated memory holding the Object handle.
function NewObject(object_handle) end

--- Allocates memory for a Vector3 structure and initializes it with values from a table.
--- @param vector_table table A table with 'x', 'y', and 'z' fields (numbers).
--- @return number A pointer (address) to the allocated Vector3 structure.
function NewVector3(vector_table) end

--- Frees a previously allocated memory block.
--- @param pointer number The pointer (address) to the memory block to free.
function Delete(pointer) end

--- Frees a previously allocated Vector3 memory block.
--- @param pointer number The pointer (address) to the Vector3 memory block to free.
function DeleteVector3(pointer) end

--- Game Features Functions
--- ---
--- Deletes a game vehicle entity.
--- @param vehicle_handle number The handle of the vehicle to delete.
function DeleteVehicle(vehicle_handle) end

--- Deletes a game ped entity.
--- @param ped_handle number The handle of the ped to delete.
function DeletePed(ped_handle) end

--- Deletes a game object entity.
--- @param object_handle number The handle of the object to delete.
function DeleteObject(object_handle) end

--- Retrieves all entities currently in the game world.
--- @return table<integer, number> A table containing the handles of all entities.
--- @return integer The total count of entities found.
function GetAllEntities() end

--- Retrieves all peds (pedestrians and players) currently in the game world.
--- @return table<integer, number> A table containing the handles of all peds.
--- @return integer The total count of peds found.
function GetAllPeds() end

--- Retrieves all vehicles currently in the game world.
--- @return table<integer, number> A table containing the handles of all vehicles.
--- @return integer The total count of vehicles found.
function GetAllVehicles() end

--- Retrieves all objects currently in the game world.
--- @return table<integer, number> A table containing the handles of all objects.
--- @return integer The total count of objects found.
function GetAllObjects() end

--- Casting Functions
--- ---
--- Converts a string to a 32-bit signed integer. Supports decimal and hexadecimal (0x prefix) formats.
--- @param value_str string The string to convert.
--- @return integer The 32-bit signed integer value.
function tonumber32(value_str) end

--- Math Functions (Libs)
--- ---
--- Returns the maximum of two numbers.
--- @param value1 number The first number.
--- @param value2 number The second number.
--- @return number The larger of the two numbers.
function max(value1, value2) end

--- Returns the base raised to the power of the exponent.
--- @param x number The base.
--- @param y number The exponent.
--- @return number The result of x raised to the power of y.
function pow(x, y) end


-- The 'Game' table provides low-level memory access and pattern searching functionalities.
Game = {}

--- Reads an integer value from the specified memory address.
-- @param address number The memory address to read from.
-- @returns number The integer value read.
function Game.ReadInt(address) end

--- Writes an integer to the specified memory address.
-- @param address number The memory address to write to.
-- @param value number The integer value to write.
function Game.WriteInt(address, value) end

--- Writes a float to the specified memory address.
-- @param address number The memory address to write to.
-- @param value number The float value to write.
function Game.WriteFloat(address, value) end

--- Reads a float from the specified memory address.
-- @param address number The memory address to read from.
-- @returns number The float value read.
function Game.ReadFloat(address) end

--- Reads a byte from the specified memory address.
-- @param address number The memory address to read from.
-- @returns number The byte value read (0-255).
function Game.ReadByte(address) end

--- Reads a boolean value from the specified memory address.
-- @param address number The memory address to read from.
-- @returns boolean The boolean value read.
function Game.ReadBool(address) end

--- Reads a double-precision value from the specified memory address.
-- @param address number The memory address to read from.
-- @returns number The double-precision value read.
function Game.ReadDouble(address) end

--- Reads a 64-bit integer from the specified memory address.
-- @param address number The memory address to read from.
-- @returns number The 64-bit integer value read.
function Game.ReadInt64(address) end

--- Reads a short integer from the specified memory address.
-- @param address number The memory address to read from.
-- @returns number The short integer value read.
function Game.ReadShort(address) end

--- Writes a short integer to the specified memory address.
-- @param address number The memory address to write to.
-- @param value number The short integer value to write.
function Game.WriteShort(address, value) end

--- Reads an array of bytes from the specified memory address and returns them as a Lua table.
-- @param address number The memory address to read from.
-- @param length number The number of bytes to read.
-- @returns table A Lua table containing the bytes.
function Game.ReadBytes(address, length) end

--- Writes a 64-bit integer to the specified memory address.
-- @param address number The memory address to write to.
-- @param value number The 64-bit integer value to write.
function Game.WriteInt64(address, value) end

--- Writes a byte to the specified memory address.
-- @param address number The memory address to write to.
-- @param value number The byte value to write (0-255).
function Game.WriteByte(address, value) end

--- Writes a boolean value to the specified memory address.
-- @param address number The memory address to write to.
-- @param value boolean The boolean value to write.
function Game.WriteBool(address, value) end

--- Writes a double-precision floating point value to the specified memory address.
-- @param address number The memory address to write to.
-- @param value number The double-precision value to write.
function Game.WriteDouble(address, value) end

--- Writes an array of bytes (provided as a Lua table) to the specified memory address.
-- @param address number The memory address to write to.
-- @param bytes table A Lua table containing the bytes.
function Game.WriteBytes(address, bytes) end

--- Writes a null-terminated string to the specified memory address.
-- @param address number The memory address to write to.
-- @param value string The string to write.
function Game.WriteString(address, value) end

--- Reads a string of the specified length from the given memory address.
-- @param address number The memory address to read from.
-- @param length number The length of the string to read.
-- @returns string The string read.
function Game.ReadString(address, length) end

--- Searches memory between the specified addresses for a particular integer and returns its address if found.
-- @param start_address number The starting memory address for the search.
-- @param end_address number The ending memory address for the search.
-- @param value number The integer value to search for.
-- @returns number|nil The address where the value was found, or nil if not found.
function Game.FindValue(start_address, end_address, value) end

--- Searches for a memory pattern using the provided mask and returns the address if the pattern is matched.
-- @param start_address number The starting memory address for the search.
-- @param end_address number The ending memory address for the search.
-- @param pattern string The byte pattern to search for (e.g., "\x90\x90\x90").
-- @param mask string The mask string (e.g., "xxx" where 'x' means check, '?' means ignore).
-- @returns number|nil The address where the pattern was matched, or nil if not found.
function Game.FindPattern(start_address, end_address, pattern, mask) end

--- Returns the base address of the current process.
-- @returns number The base address of the current process.
function Game.GetBaseAddress() end


--- Gamepad Functions
--- ---

--- @class Gamepad
--- Represents a gamepad controller object, allowing interaction with its state and vibration.
--- To create a Gamepad object, call the global `Gamepad()` function:
--- `local myGamepad = Gamepad()`
Gamepad = {}

--- Selects a game controller by its index.
--- @param controller_id number The 0-based index of the controller to select.
--- @return boolean True if the controller was successfully selected, false otherwise.
function Gamepad:select_controller(controller_id) end

--- Returns the index of the currently selected controller for this Gamepad object.
--- @return number The 0-based index of the selected controller.
function Gamepad:get_selected_controller() end

--- Returns the string representation of the last key/button pressed on the selected controller.
--- @return string|nil The name of the pressed key/button, or nil if no key is pressed.
function Gamepad:get_pressed_key() end

--- Returns a list of string representations of all currently pressed keys/buttons on the selected controller.
--- @return table<integer, string> A table (list) containing the names of all pressed keys/buttons.
function Gamepad:get_pressed_keys() end

--- Returns the current state of the left analog stick.
--- @return {ThumbLX: number, ThumbLY: number}|nil A table containing the X and Y axis values (numbers from -1.0 to 1.0), or nil if the state cannot be retrieved.
function Gamepad:get_left_stick_state() end

--- Returns the current state of the right analog stick.
--- @return {ThumbRX: number, ThumbRY: number}|nil A table containing the X and Y axis values (numbers from -1.0 to 1.0), or nil if the state cannot be retrieved.
function Gamepad:get_right_stick_state() end

--- Returns the current state of the left and right triggers.
--- @return {LT: number, RT: number}|nil A table containing the values of the Left Trigger (LT) and Right Trigger (RT) (numbers from 0.0 to 1.0), or nil if the state cannot be retrieved.
function Gamepad:get_triggers_state() end

--- Sends vibration feedback to the controller.
--- @param strength number The overall strength of the vibration (0.0 to 1.0).
--- @param vibrate_left_motor boolean True to vibrate the left motor, false otherwise.
--- @param vibrate_right_motor boolean True to vibrate the right motor, false otherwise.
--- @return nil
function Gamepad:send_vibration(strength, vibrate_left_motor, vibrate_right_motor) end

--- Global function to create a new Gamepad object.
--- Each Gamepad object manages its own unique ID for controller state.
--- @return Gamepad A new Gamepad object.
function Gamepad() end