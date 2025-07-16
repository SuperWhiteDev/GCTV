# GCTV JS Functions Documentation

## Table of Contents
- [Base](#Base)
- - [setTimeout](#setTimeout)
- - [sleep](#sleep)
- - [require](#require)
- - [GetGCTVersion](#getgctversion)
- - [GetGCTStringVersion](#getgctstringversion)
- - [GetGCTFolder](#getgctfolder)
- - [Call](#call)
- - [getTimestamp](#getTimestamp)
- - [toUpperCase](#toUpperCase)
- - [toLowerCase](#toLowerCase)
- - [capitalize](#capitalize)
- - [reverseString](#reverseString)
- - [trimString](#trimString)
- - [getCurrentTime](#getCurrentTime)
- - [getRandomNumber](#getRandomNumber)
- [console](#console)
- - [log](#log)
- - [error](#error)
- - [input](#input)
- - [inputFromList](#inputFromList)
- - [setColour](#setColour)
- - [resetColour](#resetColour)
- - [print](#print)
- - [BindCommand](#BindCommand)
- - [UnBindCommand](#UnBindCommand)
- - [IsCommandExist](#IsCommandExist)
- [fs](#fs)
- - [readFile](#readFile)
- - [writeFile](#writeFile)
- - [readdir](#readdir)
- - [deleteFile](#deleteFile)
- - [fileExists](#fileExists)
- - [createDirectory](#createDirectory)
- - [getFileExtension](#getFileExtension)
- - [getFileName](#getFileName)
- [global](#Global)
- - [register](#register)
- - [get](#get)
- - [set](#set)
- - [search](#search)
- [Game](#Game)
- - [New](#New)
- - [NewPointer](#NewPointer)
- - [NewPed](#NewPed)
- - [NewVehicle](#NewVehicle)
- - [NewObject](#NewObject)
- - [NewVector3](#NewVector3)
- - [Delete](#Delete)
- - [DeleteVector3](#DeleteVector3)
- - [GetAllEntities](#GetAllEntities)
- - [GetAllPeds](#GetAllPeds)
- - [GetAllVehicles](#GetAllVehicles)
- - [GetAllObjects](#GetAllObjects)
- - [NativeCall](#NativeCall)
- - [HashString](#HashString)
- - [ReadInt](#ReadInt)
- - [WriteInt](#WriteInt)
- - [WriteFloat](#WriteFloat)
- - [ReadFloat](#ReadFloat)
- - [ReadByte](#ReadByte)
- - [ReadBool](#ReadBool)
- - [ReadDouble](#ReadDouble)
- - [ReadInt64](#ReadInt64)
- - [ReadShort](#ReadShort)
- - [WriteShort](#WriteShort)
- - [ReadBytes](#ReadBytes)
- - [WriteByte](#WriteByte)
- - [WriteBool](#WriteBool)
- - [WriteDouble](#WriteDouble)
- - [WriteBytes](#WriteBytes)
- - [WriteString](#WriteString)
- - [ReadString](#ReadString)
- - [FindValue](#FindValue)
- - [FindPattern](#FindPattern)
- - [GetBaseAddress](#GetBaseAddress)
- [Input](#Input)
- - [Keyboard](#Keyboard)
- - - [stringToKey](#stringToKey)
- - - [isPressed](#isPressed)
- - [Mouse](#Mouse)
- - - [getPos](#getPos)
- - - [setPos](#setPos)
- - - [isScrolledUp](#isScrolledUp)
- - - [isScrolledDown](#isScrolledDown)
- - - [isLeftPressed](#isLeftPressed)
- - - [isRightPressed](#isRightPressed)
- - [Gamepad](#Gamepad)
- - - [selectController](#selectController)
- - - [getController](#getController)
- - - [getPressedKey](#getPressedKey)
- - - [getPressedKeys](#getPressedKeys)
- - - [getLeftStickState](#getLeftStickState)
- - - [getRightStickState](#getRightStickState)
- - - [getTriggersState](#getTriggersState)
- - - [sendVibration](#sendVibration)
# Base

## setTimeout

**Description:**  
Schedules a callback function to be executed after a specified delay (in milliseconds). The function stores the callback in the global stash to prevent it from being garbage-collected before its execution.

**Parameters:**

- **callback** (Function): The callback function to execute after the delay. This should be passed as the first argument.
- **delay** (Number): The time in milliseconds to wait before executing the callback. This is provided as the second argument.

**Return Value:**  
Returns an integer `timerId` that uniquely identifies the scheduled timer.

**Error Handling:**  
- If an error occurs during the callback execution, an error message is logged to the console. However, no exception is directly thrown to the JavaScript context within the timer function.

**Example Usage:**
```js
// Example: Schedule a function to run after 2000ms (2 seconds)
var timerId = set_timeout(function() {
    console.log("Timeout completed!");
}, 2000);
```

---

## sleep

**Description:**  
Pauses the execution of the current script for a specified duration in milliseconds. This is a blocking call that halts further execution until the sleep period is over.

**Parameters:**

- **duration** (Number): The number of milliseconds to sleep. It must be a valid number.

**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
// Example: Pause execution for 1000ms (1 second)
console.log("Starting.");
sleep(1000);
console.log("Finished sleeping.");
```

---

## require

**Description:**  
The `require` function loads and evaluates a JavaScript module file in the GCTV environment. It looks for the module in the default `Scripts` directory but allows specifying either relative or absolute paths.

## Parameters

- **modulePath** (String): The path to the module file to load.  
  - **Relative Path:** A path relative to the default `Scripts` directory, e.g., `"custom/myScript.js"`.  
    The function constructs the full path by appending it to the project's `Scripts` folder.  
  - **Absolute or Custom Relative Path:** If the module is outside the default folder, you can provide an absolute or a custom relative path, e.g., `"/custom/path/to/customScript.js"`.

## Return Value

- Returns the last result of execution in the JavaScript code.

## Error Handling

- If the module file cannot be found, an error is thrown:  
  `"Module '<modulePath>' not found"`
- If the module file exists but cannot be opened, an error is thrown:  
  `"Failed to open module '<modulePath>'"`
- If an error occurs during evaluation, an error is thrown with details:  
  `"Error while importing module '<modulePath>': <error details>"`

## Example Usage

```js
// Load a module from the default Scripts folder
require("modules/myModule.js");

// Load a module using an absolute or custom relative path
require("/custom/path/to/customModule.js");
```

---

## GetGCTVersion

**Description:**  
Returns the current version of the GCTV runtime as an integer. This can be used to check compatibility or for debugging purposes.

**Parameters:**  
None. This function does not accept any arguments.

**Return Value:**  
Returns a `Number` representing the version of the GCTV engine.

**Example Usage:**
```js
var version = GetGCTVersion();
console.log("GCTV version:", version);
```

---

## GetGCTStringVersion

**Description:**  
Returns the current version of the GCTV runtime as a string. Useful for displaying version info or performing string-based comparisons.

**Parameters:**  
None. This function does not accept any arguments.

**Return Value:**  
Returns a `String` representing the version of the GCTV engine.

**Example Usage:**
```js
var versionStr = GetGCTStringVersion();
console.log("GCTV version (string):", versionStr);
```

---

## GetGCTFolder

**Description:**  
Returns the absolute path to the root directory of the current GCTV project. This can be used to construct file paths relative to the project location.

**Parameters:**  
None. This function does not accept any arguments.

**Return Value:**  
Returns a **String** containing the full path to the project's root directory.

**Example Usage:**
```js
var rootPath = GetGCTFolder();
console.log("Project root path:", rootPath);
```

---

## RestartScripts

**Description:**  
Restarts all scripts currently running in the GCTV environment. This function initiates the restart asynchronously and terminates the current script execution immediately.

**Parameters:**  
None. This function does not accept any arguments.

**Return Value:**  
This function does not return normally. It throws a termination signal internally with the string `"AUTOMATIC_TERMINATION"` to indicate the script was stopped for restart.

**Example Usage:**
```js
// Trigger a full script restart
RestartScripts();

// Note: Code after this call will not be executed
```

---

## Call

**Description:**  
Dynamically calls a function from any loaded DLL module using its name and a specified return type. Accepts up to 21 arguments for the target function. The return value is automatically cast and returned according to the provided prototype.

**Parameters:**  
- `functionName` (String): The name of the function to call. Must exist in one of the loaded DLL modules.  
- `Prototype` (String): Specifies the expected return type. Supported values:
  - `"integer"` – returns a 64-bit integer
  - `"integer32"` – returns a 32-bit integer
  - `"float"` – returns a floating-point number
  - `"boolean"` – returns a boolean
  - `"string"` – returns a C-style string
  - `"array(n)"` – returns an array of `n` 64-bit integers  
- `typeof arg1, typeof arg2, ..., typeof argN`: (Optional) Type of arguments to pass to the function (up to 21 total).

**Return Value:**  
Returns the result of the function call, cast to the specified type. If the function is not found or the prototype is invalid, `null` is returned.

**Example Usage:**
```js
var result = Call("AddNumbers", "integer integer integer", 5, 7); // Calls AddNumbers(5, 7) and returns int64 result

var name = Call("GetName", "string"); // Calls GetName() and returns a string

var values = Call("GetTopScores", "array(5) string", name); // Calls GetTopScores() and returns array of 5 integers
```

---

## getTimestamp

**Description:**  
Returns the current Unix timestamp in milliseconds (UTC), measured from January 1, 1970.

**Parameters:**  
This function does take any arguments.

**Return Value:**  
- Returns a `Number` representing the current time in **milliseconds** since the Unix epoch.

**Example Usage:**
```js
var ts = getTimestamp();
print("Current timestamp:", ts);
```

---

## toUpperCase

**Description:**  
Converts the input string to uppercase characters.

**Parameters:**  
- `string` (required): A single string input to be transformed to uppercase.

**Return Value:**  
- Returns a `String` containing the uppercase version of the input.

**Example Usage:**
```js
var result = toUpperCase("hello world");
print(result); // Outputs: "HELLO WORLD"
```

---

## toLowerCase

**Description:**  
Converts the input string to lowercase characters.

**Parameters:**  
- `string` (required): A single string input to be transformed to lowercase.

**Return Value:**  
- Returns a `String` containing the lowercase version of the input.

**Example Usage:**
```js
var result = toLowerCase("HeLLo WoRLD!");
print(result); // Outputs: "hello world!"
```

---

## capitalize

**Description:**  
Converts the first character of the string to uppercase and the remaining characters to lowercase.

**Parameters:**  
- `string` (required): The string to capitalize.

**Return Value:**  
- Returns a `String` where the first character is uppercase and the rest are lowercase.

**Example Usage:**
```js
var result = capitalize("hELLO WoRLD!");
print(result); // Outputs: "Hello world!"
```

---

## reverseString

**Description:**  
Reverses the characters in the given string.

**Parameters:**  
- `string` (required): The input string to be reversed.

**Return Value:**  
- Returns a `String` with characters in reverse order.

**Example Usage:**
```js
var result = reverseString("hello");
print(result); // Outputs: "olleh"
```

---

## trimString

**Description:**  
Removes leading and trailing whitespace characters (spaces and tabs) from the input string.

**Parameters:**  
- `string` (required): The input string to trim.

**Return Value:**  
- Returns a `String` with no leading or trailing spaces or tabs.

**Example Usage:**
```js
var result = trimString("   hello world   ");
print(result); // Outputs: "hello world"
```

---

## getCurrentTime

**Description:**  
Returns the current system time as a formatted string.

**Parameters:**  
- None. This function does not accept any arguments.

**Return Value:**  
- Returns a string representing the current date and time in the format similar to `"Wed Jun 30 21:49:08 1993\n"`.
- Returns `null` if the time formatting fails.

**Example Usage:**
```js
var currentTime = getCurrentTime();
print(currentTime);  // Outputs something like: "Fri May 17 14:23:45 2025\n"
```

---

## getRandomNumber

**Description:**  
Returns a random integer number between `min` and `max` inclusive.

**Parameters:**  
- `min` (integer) — The minimum value of the random number range.
- `max` (integer) — The maximum value of the random number range.

If `min` is greater than `max`, the values will be swapped internally.

**Return Value:**  
- Returns a random integer between `min` and `max`, inclusive.

**Example Usage:**
```js
var randomValue = getRandomNumber(5, 10);
print(randomValue);  // Outputs a random integer between 5 and 10 (inclusive)
```

# console

## log

**Description:**  
Outputs the provided arguments to the console as strings, separated by spaces. Before the output, the function prints the script name to indicate the source of the log message.

**Parameters:**  
- Accepts any number of arguments of any type. Each argument will be converted to a string and concatenated with spaces.

**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
console.log("Hello,", "world!", 123);
// Output: [<ScriptName>] Hello, world! 123
```

--- 

## error

**Description:**  
Outputs the provided arguments to the console as error messages, concatenated as strings separated by spaces. The function also prints the script name before the error message to indicate the source.

**Parameters:**  
- Accepts any number of arguments of any type. Each argument is converted to a string and joined with spaces.

**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
console.error("An error occurred:", errorMessage);
// Output: [<ScriptName>] An error occurred: [errorMessage]
```

---

## input

**Description:**  
Prompts the user for input via the console. Optionally, displays a prompt message before waiting for input.

**Parameters:**  
- **prompt** (String, optional): A string to display as a prompt before waiting for user input. If omitted, no prompt is shown.

**Return Value:**  
Returns the user input as a string.

**Example Usage:**
```js
var name = console.input("Enter your name: ");
console.log("Hello, " + name);
```

---

## inputFromList

**Description:**  
Displays a tooltip with a list of options, allowing the user to select one of them by entering the appropriate index or option name. The function returns the index of the selected option.

**Parameters:**  
- **prompt** (String): A string message displayed to the user before the list of options.
- **values** (Array of Strings): An array containing the list of options from which the user can choose.

**Return Value:**  
Returns an integer representing the index of the selected option in the `values` array.

**Example Usage:**
```js
const options = ["Apple", "Banana", "Orange", "Lime"];
console.print(
    "aqua",
    "User choice is ",
    options[console.inputFromList(
        "Choose what you want: ",
        options
    )]
);
```

---

## setColour

**Description:**  
Sets the console text color based on the provided color name string.

**Parameters:**  
- **color** (String): The name of the color to set. The following color names are supported (case-sensitive):
  - "dark blue"
  - "dark green"
  - "dark aqua"
  - "dark red"
  - "dark purple"
  - "dark yellow"
  - "light gray"
  - "dark gray"
  - "blue"
  - "green"
  - "aqua"
  - "red"
  - "purple"
  - "yellow"
  - "white"


**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
console.setColour("red");
console.print("This text will appear in red.");
```

---

## resetColour

**Description:**  
Resets the console text color to the default color.

**Parameters:**  
This function does not accept any parameters.

**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
console.setColour("blue");
console.print("This text is blue.");
console.resetColour();
console.print("This text is default color.");
```

---

## print

**Description:**  
Prints text to the console in the specified color. The first argument specifies the color, and all subsequent arguments are concatenated into the output string. This function does **not** print the script name.

**Parameters:**  
- **color** (String): The color name to set the text to. Supported colors are:
  - "dark blue"
  - "dark green"
  - "dark aqua"
  - "dark red"
  - "dark purple"
  - "dark yellow"
  - "light gray"
  - "dark gray"
  - "blue"
  - "green"
  - "aqua"
  - "red"
  - "purple"
  - "yellow"
  - "white"
- **...args** (Any): Additional arguments to be concatenated into a single string output.

**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
console.print("green", "Success:", "Operation completed.");
console.print("red", "Error:", "File not found.");
console.print("aqua", "User", userName, "logged in.");
```
---

## write

**Description:**  
Writes text to the console without appending a newline. All arguments passed to the function are concatenated into a single string with spaces between them.

**Parameters:**  
- **...args** (Any): One or more arguments to be concatenated and written to the console.

**Return Value:**  
Returns `undefined`.

**Example Usage:**
```js
console.write("Loading", "please wait...");
console.write("Progress:", progress, "%");
```

---

## BindCommand

**Description:**  
Registers a new console command in GCTV that, when entered by the user in the terminal, triggers the associated JavaScript function.

**Parameters:**  
- **command** (String): The command name to register.
- **callback** (Function): The JavaScript function to execute when the command is entered in the console.

**Return Value:**  
Returns a boolean indicating whether the command was successfully registered (`true`) or if the command already exists (`false`).

**Example Usage:**
```js
console.BindCommand("greet", function() {
    console.log("Greetings from the GCTV command!");
});
```

---

## UnBindCommand

**Description:**  
Unregisters registered console command in GCTV, removing the associated JavaScript callback function. This stops the command from triggering the bound JS function when entered in the terminal.

**Parameters:**  
- **command** (String): The name of the command to unregister.

**Return Value:**  
Returns a boolean indicating whether the command was successfully unregistered (`true`) or if the command was not found or not registered (`false`).

**Example Usage:**
```js
console.UnBindCommand("greet");
```

---

## IsCommandExist

**Description:**  
Checks if a given console command is currently registered in the GCTV environment.

**Parameters:**  
- **command** (String): The name of the command to check.

**Return Value:**  
Returns a boolean value:
- `true` if the command is registered.
- `false` if the command does not exist.

**Example Usage:**
```js
if (console.IsCommandExist("help")) {
    console.log("Help command is available.");
} else {
    console.log("Help command not found.");
}
```

---

# fs

## readFile

**Description:**  
Reads the entire content of a file specified by its filename and returns it as a string.

**Parameters:**  
- **filename** (String): The path to the file to be read.

**Return Value:**  
Returns the content of the file as a string.

**Error Handling:**  
Throws an error if the file cannot be opened.

**Example Usage:**
```js
try {
    var data = fs.readFile("example.txt");
    console.log(data);
} catch (e) {
    console.error("Failed to read file:", e);
}
```

---

## writeFile

**Description:**  
Writes the specified string data to a file at the given filename. If the file does not exist, it will be created or overwritten.

**Parameters:**  
- **filename** (String): The path to the file to write data to.  
- **data** (String): The string content to write into the file.

**Return Value:**  
Returns `undefined`.

**Error Handling:**  
Throws an error if the file cannot be opened for writing.

**Example Usage:**
```js
try {
    fs.writeFile("output.txt", "Hello, world!");
    console.log("File written successfully.");
} catch (e) {
    console.error("Failed to write file:", e);
}
```

---

## readdir

**Description:**  
Lists all regular files (not directories) in the specified folder path and returns them as a JavaScript array of filenames.

**Parameters:**  
- **folderPath** (String): The path to the directory to list files from.

**Return Value:**  
Returns an array of strings, where each string is the filename of a regular file inside the folder.  
Returns `null` if the folder does not exist or is not a directory.

**Error Handling:**  
No explicit error thrown. Returns `null` if the folder path is invalid or not a directory.

**Example Usage:**
```js
var files = fs.readdir("/path/to/folder");
if (files !== null) {
    files.forEach(function(file) {
        console.log(file);
    });
} else {
    console.log("Folder not found or is not a directory.");
}
```

---

## deleteFile

**Description:**  
Deletes the specified file from the filesystem.

**Parameters:**  
- **filePath** (String): The path to the file to be deleted.

**Return Value:**  
Returns `true` if the file was successfully deleted, otherwise returns `false`.

**Error Handling:**  
No exception is thrown; the function simply returns `false` if the file does not exist or could not be deleted.

**Example Usage:**
```js
if (fs.deleteFile("example.txt")) {
    console.log("File deleted successfully.");
} else {
    console.log("Failed to delete file.");
}
```

---

## fileExists

**Description:**  
Checks if a file or directory exists at the specified path.

**Parameters:**  
- **filePath** (String): The path to the file or directory to check.

**Return Value:**  
Returns `true` if the file or directory exists, otherwise `false`.

**Example Usage:**
```js
if (fs.fileExists("example.txt")) {
    console.log("File exists.");
} else {
    console.log("File does not exist.");
}
```

---

## createDirectory

**Description:**  
Creates a new directory at the specified path.

**Parameters:**  
- **dirPath** (String): The path where the new directory should be created.

**Return Value:**  
Returns `true` if the directory was successfully created, otherwise `false` (e.g., if the directory already exists).

**Example Usage:**
```js
if (fs.createDirectory("new_folder")) {
    console.log("Directory created successfully.");
} else {
    console.log("Failed to create directory or it already exists.");
}
```

---

## getFileExtension

**Description:**  
Retrieves the file extension (including the dot) from a given file path.

**Parameters:**  
- **filePath** (String): The full path or name of the file.

**Return Value:**  
Returns the file extension as a string, including the leading dot (e.g., ".txt"). If the file has no extension, returns an empty string.

**Example Usage:**
```js
var ext = fs.getFileExtension("example.txt");
console.log(ext);  // Output: ".txt"
```

---

## getFileName

**Description:**  
Retrieves the file name without its extension from a given file path.

**Parameters:**  
- **filePath** (String): The full path or name of the file.

**Return Value:**  
Returns the file name without the extension as a string.

**Example Usage:**
```js
var name = fs.getFileName("/path/to/example.txt");
console.log(name);  // Output: "example"
```

# global

## register

**Description:**  
Registers a global variable in GCTV's memory space. This global variable becomes accessible to all scripts, including those written in other programming languages supported by the environment. The function supports registering integers, floating-point numbers, strings, or arrays of uniform data types (all numbers or all strings).

**Parameters:**  
- **name** (String): The name of the global variable to register.
- **value** (int | double | string | array): The value to assign to the global variable.  
  - If a number is provided, it is registered as an integer if it has no fractional part, otherwise as a floating-point number.  
  - If a string is provided, it is stored as a string.  
  - If an array is provided, it must be either an array of all numbers (ints or floats) or all strings. Mixed-type arrays are not allowed.

**Return Value:**  
Returns `undefined`.

**Error Handling:**  
- Throws a type error if the value is not an int, double, string, or a uniform array of these types.  
- Throws a type error if the array is empty.  
- Throws a type error if the array elements are not all of the same type (all numbers or all strings).

**Example Usage:**
```js
// Register an integer
global.register("globalInt", 42);

// Register a floating-point number
global.register("globalFloat", 3.14159);

// Register a string
global.register("globalString", "Hello world");

// Register an array of integers
global.register("globalIntArray", [1, 2, 3, 4]);

// Register an array of strings
global.register("globalStringArray", ["foo", "bar", "baz"]);
```

---

## get

**Description:**  
Retrieves the value of a global variable previously registered in GCTV's shared memory. The returned value matches the original type of the global variable and can be a number (integer or double), string, or an array of numbers or strings.

**Parameters:**  
- **name** (String): The name of the global variable to retrieve.

**Return Value:**  
Returns the value of the global variable with the following type mapping:  
- Integer or double numbers are returned as JavaScript numbers.  
- Strings are returned as JavaScript strings.  
- Arrays of numbers or strings are returned as JavaScript arrays.  
- If the variable does not exist or is of an unknown type, returns `null`.

**Example Usage:**
```js
var intValue = global.get("globalInt");
var strValue = global.get("globalString");
var arrayValue = global.get("globalIntArray");
```

---

## set

**Description:**  
Updates the value of an existing global variable in GCTV's shared memory. The value can be a number (integer or double), string, or an array of numbers or strings. The type of the new value must be consistent with the types supported by the global variable system.

**Parameters:**  
- **name** (String): The name of the global variable to update.  
- **value** (Number | String | Array): The new value to set. It can be:  
  - A number (integer or floating point).  
  - A string.  
  - An array of numbers (all integers or all doubles) or strings.

**Return Value:**  
Returns `undefined`.

**Error Handling:**  
- Throws a type error if the second argument is not a number, string, or an array.  
- Throws a type error if the array is empty.  
- Throws a type error if the array elements are not all of the same data type (all numbers or all strings).  
- Throws a runtime error with a descriptive message if internal validation fails.

**Example Usage:**
```js
global.set("globalInt", 42);
global.set("globalString", "Hello World");
global.set("globalIntArray", [1, 2, 3, 4]);
global.set("globalStringArray", ["foo", "bar", "baz"]);
```

---

## search

**Description:**  
Checks if a global variable with the specified name exists in the GCTV shared memory.

**Parameters:**  
- **name** (String): The name of the global variable to check.

**Return Value:**  
Returns a boolean:  
- `true` if the global variable exists.  
- `false` if it does not exist.

**Example Usage:**
```js
if (global.search("myGlobalVar")) {
    console.log("Variable exists");
} else {
    console.log("Variable does not exist");
}
```

# Game

## New

**Description:**  
Allocates a new block of memory in the GTAV. Returns a memory address as a number which can be used for reading and writing later.

**Parameters:**
1. `size` *(number)* — The size of memory to allocate, in bytes.

**Returns:**  
- `number` — Memory address (as a numeric value) of the allocated block.

**Usage Example:**
```js
var mem = Game.New(64); // Allocates 64 bytes and returns the base address
```

---

## NewPointer

**Description:**  
Allocates a memory block sized for a pointer and stores the provided value in it. Returns the memory address of the allocated block.

**Parameters:**
1. `value` *(number)* — A 64-bit integer (pointer-sized value) to store in the newly allocated memory.

**Returns:**  
- `number` — Memory address (as a numeric value) pointing to the allocated block where the pointer was stored.

**Usage Example:**
```js
var ptr = Game.NewPointer(0x12345678); // Allocates memory and stores a pointer value
```

---

## NewPed

**Description:**  
Allocates 4 bytes of memory and stores the given Ped ID in it. Returns the address of the allocated memory.

**Parameters:**
1. `Ped` *(number)* — The Ped ID to store in the allocated memory.

**Returns:**  
- `number` — A pointer (memory address) to the allocated memory containing the Ped ID.

**Usage Example:**
```js
var pedPtr = Game.NewPed(PLAYER.PLAYER_PED_ID()) // Allocates memory and stores the player ped id
```

---

## NewVehicle

**Description:**  
Allocates 4 bytes of memory and stores the given Vehicle ID in it. Returns the address of the allocated memory.

**Parameters:**
1. `Vehicle` *(number)* — The Vehicle ID to store in the allocated memory.

**Returns:**  
- `number` — A pointer (memory address) to the allocated memory containing the Vehicle ID.

**Usage Example:**
```js
var playerVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
var vehPtr = Game.NewVehicle(playerVeh) // Allocates memory and stores the player vehicle id
```

---

## NewObject

**Description:**  
Allocates 4 bytes of memory and stores the given Object ID in it. Returns the address of the allocated memory.

**Parameters:**
1. `Object` *(number)* — The Object ID to store in the allocated memory.

**Returns:**  
- `number` — A pointer (memory address) to the allocated memory containing the Object ID.

**Usage Example:**
```js
var objPtr = Game.NewObject(0x1345) // Allocates memory and stores the object id
```

---

## NewVector3

**Description:**  
Allocates memory for a `Vector3` structure and initializes it with the provided `x`, `y`, and `z` values.

**Parameters:**
1. `value` *(object)* — An object with numeric properties `x`, `y`, and `z` representing coordinates.

**Returns:**  
- `number` — A pointer (memory address) to the allocated and initialized `Vector3`.

**Usage Example:**
```js
var vecPtr = Game.NewVector3({ x: 1.0, y: 2.0, z: 3.0 })
```

---

## Delete

**Description:**  
Frees previously allocated memory at the specified address.

**Parameters:**
1. `pointer` *(number)* — A memory address previously returned by functions like `New`, `NewPointer`, `NewPed`, etc.

**Returns:**  
- `undefined`

**Usage Example:**
```js
var ptr = Game.New(128);
Game.Delete(ptr);
```

---

## DeleteVector3

**Description:**  
Frees memory allocated for a `Vector3` object.

**Parameters:**
1. `pointer` *(number)* — A memory address previously returned by `NewVector3`.

**Returns:**  
- `undefined`

**Usage Example:**
```js
var vec = Game.NewVector3({ x: 0, y: 0, z: 0 });
Game.DeleteVector3(vec);
```

---

## GetAllEntities

**Description:**  
Returns an array of all currently loaded entities in the game world.

**Parameters:**  
- *(none)*

**Returns:**  
- `Array<number>` — An array containing integer Entity IDs.
- `number` — The total number of entities returned.

**Usage Example:**
```js
var result = Game.GetAllEntities();
console.log("Total entities:", result[1]);
console.log("Entity IDs:", result[0]);
```

---

## GetAllPeds

**Description:**  
Returns an array of all currently loaded peds in the game world.

**Parameters:**  
- *(none)*

**Returns:**  
- `Array<number>` — An array containing integer Ped IDs.
- `number` — The total number of peds returned.

**Usage Example:**
```js
var result = Game.GetAllPeds();
console.log("Total peds:", result[1]);
console.log("Ped IDs:", result[0]);
```

---

## GetAllVehicles

**Description:**  
Returns an array of all currently loaded vehicles in the game world.

**Parameters:**  
- *(none)*

**Returns:**  
- `Array<number>` — An array containing integer Vehicle IDs.
- `number` — The total number of vehicles returned.

**Usage Example:**
```js
var result = Game.GetAllVehicles();
console.log("Total vehicles:", result[1]);
console.log("Vehicle IDs:", result[0]);
```

---

## GetAllObjects

**Description:**  
Returns an array of all currently loaded objects in the game world.

**Parameters:**  
- *(none)*

**Returns:**  
- `Array<number>` — An array containing integer Object IDs.
- `number` — The total number of objects returned.

**Usage Example:**
```js
var result = Game.GetAllObjects();
console.log("Total objects:", result[1]);
console.log("Object IDs:", result[0]);
```

---

## NativeCall

**Description:**  
Calls a native game function by its hash with specified arguments and returns the result.

**Parameters:**

- `functionHash` (string): The hash of the native function to call, obtained from the `HashString` function.
- `returnType` (string): Expected return type of the native function. Supported types:
  - `"string"`
  - `"integer32"`
  - `"integer"`
  - `"number"` (float)
  - `"boolean"`
- `args` (array): Array of arguments to pass to the native function.

**Returns:**

- Returns the value from the native function call, converted to the specified return type.
- Returns `undefined` if the function call fails or if the return type is unknown.

**Usage Example:**

```js
var result = Game.NativeCall(Game.HashString("POW"), "number", [2, 6]);
console.log(result) 
```

---

## HashString

**Description:**  
Get a hash from the given string.

**Parameters:**  
- `inputString:` The string to hash.

**Returns:**  
- The hash value as a decimal string.

**Example Usage:**
```js
const hash = Game.HashString("START_SHAPE_TEST_LOS_PROBE");
console.log(hash); // Outputs hash as a string number
```

---

## ReadInt

**Description:**  
Reads an integer value from the specified memory address. This function attempts to retrieve the data and returns the integer stored at the given memory location.

## Parameters

- **address** (Number): The memory address from which the integer value should be read.

## Return Value

- Returns an `Integer` representing the value stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get an integer value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read an integer value from a specific memory address
var someValue = Game.ReadInt(Game.GetBaseAddress() + 0x12345);
console.log("Read value:", someValue);
```

---

## WriteInt

**Description:**  
Writes an integer value to the specified memory address. This function attempts to modify the data stored at the provided address.

## Parameters

- **address** (Number): The memory address where the integer value should be written.
- **value** (Number): The integer value to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write an integer value to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write an integer value to a specific memory address
Game.WriteInt(Game.GetBaseAddress() + 0x12345, 42);
```

---

## WriteFloat

**Description:**  
Writes a floating-point value to the specified memory address. This function attempts to modify the data stored at the provided address.

## Parameters

- **address** (Number): The memory address where the float value should be written.
- **value** (Number): The floating-point number to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write a float value to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write a float value to a specific memory address
Game.WriteFloat(Game.GetBaseAddress() + 0x12345, 3.14);
```

---

## ReadFloat

**Description:**  
Reads a floating-point value from the specified memory address. This function retrieves the stored data and returns it as a float.

## Parameters

- **address** (Number): The memory address from which the floating-point value should be read.

## Return Value

- Returns a **Number** representing the float value stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get a float value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a float value from a specific memory address
var someFloat = Game.ReadFloat(Game.GetBaseAddress() + 0x12345);
console.log("Read float value:", someFloat);
```

---

## ReadByte

**Description:**  
Reads a single byte value from the specified memory address. This function retrieves the stored byte and returns it as an integer.

## Parameters

- **address** (Number): The memory address from which the byte value should be read.

## Return Value

- Returns an **Integer** representing the byte stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get a byte value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a byte value from a specific memory address
var someByte = Game.ReadByte(0x12345678);
console.log("Read byte value:", someByte);
```

---

## ReadBool

**Description:**  
Reads a boolean value from the specified memory address. This function retrieves the stored value and returns it as a boolean (`true` or `false`).

## Parameters

- **address** (Number): The memory address from which the boolean value should be read.

## Return Value

- Returns a **Boolean** (`true` or `false`) representing the value stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get a boolean value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a boolean value from a specific memory address
var someBool = Game.ReadBool(0x12345678);
console.log("Read boolean value:", someBool);
```

---

## ReadDouble

**Description:**  
Reads a double-precision floating-point value from the specified memory address. This function retrieves the stored value and returns it as a double.

## Parameters

- **address** (Number): The memory address from which the double value should be read.

## Return Value

- Returns a **Number** representing the double value stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get a double value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a double value from a specific memory address
var someDouble = Game.ReadDouble(0x12345678);
console.log("Read double value:", someDouble);
```

---

## ReadInt64

**Description:**  
Reads a 64-bit integer value from the specified memory address. This function retrieves the stored data and returns it as an integer.

## Parameters

- **address** (Number): The memory address from which the 64-bit integer value should be read.

## Return Value

- Returns a **Number** representing the 64-bit integer value stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get an integer64 value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a 64-bit integer value from a specific memory address
var someInt64 = Game.ReadInt64(0x12345678);
console.log("Read 64-bit integer value:", someInt64);
```

---

## ReadShort

**Description:**  
Reads a short integer value from the specified memory address. This function retrieves the stored data and returns it as a short integer.

## Parameters

- **address** (Number): The memory address from which the short integer value should be read.

## Return Value

- Returns an **Integer** representing the short value stored at the provided address.

## Error Handling

- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get a short value at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a short integer value from a specific memory address
var someShort = Game.ReadShort(0x12345678);
console.log("Read short value:", someShort);
```

---

## WriteShort

**Description:**  
Writes a short integer value to the specified memory address. This function attempts to modify the data stored at the provided address.

## Parameters

- **address** (Number): The memory address where the short integer value should be written.
- **value** (Number): The short integer value to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write a short value to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write a short integer value to a specific memory address
Game.WriteShort(0x12345678, 32000);
```

---

## ReadBytes

**Description:**  
Reads a sequence of bytes from the specified memory address and returns them as an array.

## Parameters

- **address** (Number): The memory address from which the byte sequence should be read.
- **length** (Number): The number of bytes to read. Must be greater than zero.

## Return Value

- Returns an **Array** of integers, where each element represents a single byte.

## Error Handling

- If `length` is less than or equal to zero, an error is thrown:  
  `"The length of the buffer must be greater than zero"`
- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get bytes at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read 8 bytes from a specific memory address
var byteArray = Game.ReadBytes(0x12345678, 8);
console.log("Read bytes:", byteArray);
```

---

## ReadBytes

**Description:**  
Reads a sequence of bytes from the specified memory address and returns them as an array.

## Parameters

- **address** (Number): The memory address from which the byte sequence should be read.
- **length** (Number): The number of bytes to read. Must be greater than zero.

## Return Value

- Returns an **Array** of integers, where each element represents a single byte.

## Error Handling

- If `length` is less than or equal to zero, an error is thrown:  
  `"The length of the buffer must be greater than zero"`
- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get bytes at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read 8 bytes from a specific memory address
var byteArray = ReadBytes(0x12345678, 8);
console.log("Read bytes:", byteArray);
```

---

## WriteBool

**Description:**  
Writes a boolean value (`true` or `false`) to the specified memory address. This function attempts to modify the data stored at the provided address.

## Parameters

- **address** (Number): The memory address where the boolean value should be written.
- **value** (Boolean): The boolean value (`true` or `false`) to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write a boolean value to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write a boolean value to a specific memory address
Game.WriteBool(0x12345678, true);
```

---


## WriteDouble

**Description:**  
Writes a double-precision floating-point value to the specified memory address. This function attempts to modify the data stored at the provided address.

## Parameters

- **address** (Number): The memory address where the double value should be written.
- **value** (Number): The double-precision floating-point number to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write a double value to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write a double value to a specific memory address
Game.WriteDouble(0x12345678, 3.14159265359);
```

---

## WriteBytes

**Description:**  
Writes a sequence of bytes to the specified memory address. This function modifies the memory contents by copying the provided byte array.

## Parameters

- **address** (Number): The memory address where the byte sequence should be written.
- **bytes** (Array): An array of byte values to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the byte array is empty, an error is thrown:  
  `"Array of bytes cannot be empty"`
- If memory allocation for the byte array fails, an error is thrown:  
  `"Failed to allocate memory for buffer"`
- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write bytes to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write a sequence of bytes to a specific memory address
Game.WriteBytes(0x12345678, [0x12, 0x34, 0x56, 0x78])
```

---

## WriteString

**Description:**  
Writes a string to the specified memory address. This function copies the provided string into the memory location, ensuring it includes the null terminator.

## Parameters

- **address** (Number): The memory address where the string should be written.
- **str** (String): The string to store at the specified memory address.

## Return Value

- Returns `undefined`.

## Error Handling

- If the function fails to write to the specified address, an error is thrown:  
  `"Failed to write string to address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Write a string to a specific memory address
Game.WriteString(0x12345678, "Hello, world!");
```

---

## ReadString

**Description:**  
Reads a string from the specified memory address. This function retrieves the stored data and returns it as a string.

## Parameters

- **address** (Number): The memory address from which the string should be read.
- **length** (Number): The number of characters to read. Must be greater than zero.

## Return Value

- Returns a **String** representing the value stored at the provided address.

## Error Handling

- If `length` is zero, an error is thrown:  
  `"Length of string must be greater than zero"`
- If memory allocation for the string fails, an error is thrown:  
  `"Failed to allocate memory for string"`
- If the function fails to read from the specified address, an error is thrown:  
  `"Failed to get string at address: 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Read a string from a specific memory address
var someString = Game.ReadString(0x12345678, 16);
console.log("Read string:", someString);
```

---

## FindValue

**Description:**  
Searches for a specific integer value within a given memory range. If the value is found, the function returns the memory address where it was located.

## Parameters

- **start** (Number): The starting memory address for the search.
- **end** (Number): The ending memory address for the search.
- **value** (Number): The integer value to search for within the specified range.

## Return Value

- Returns a **Number** representing the memory address where the value was found.
- If the value is not found, returns `null`.

## Error Handling

- If an error occurs during the search, an error is thrown:  
  `"An error occurred when searching for a value between 0xXXXXXXXXXXXX and 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Search for the integer value 42 within a memory range
var foundAddress = Game.FindValue(0x10000000, 0x1000FFFF, 42);
if (foundAddress !== null) {
    console.log("Value found at address:", foundAddress);
} else {
    console.log("Value not found.");
}
```

---

## FindPattern

**Description:**  
Searches for a specific byte pattern within a given memory range. The function scans memory and checks each address against the provided pattern and mask.

## Parameters

- **start** (Number): The starting memory address for the search.
- **end** (Number): The ending memory address for the search.
- **pattern** (String): The byte pattern to search for.
- **mask** (String): A mask defining which bytes in the pattern should be matched (`'x'` for exact match, `'?'` for wildcard).

## Return Value

- Returns a **Number** representing the memory address where the pattern was found.
- If the pattern is not found, returns `null`.

## Error Handling

- If an error occurs during the search, an error is thrown:  
  `"An error occurred when searching for pattern between 0xXXXXXXXXXXXX and 0xXXXXXXXXXXXX"`

## Example Usage

```js
// Search for a specific byte pattern within a memory range
var foundAddress = Game.FindPattern(0x10000000, 0x1000FFFF, "\x90\x90\x90\x90", "xxxx");
if (foundAddress !== null) {
    console.log("Pattern found at address:", foundAddress);
} else {
    console.log("Pattern not found.");
}
```

---

## GetBaseAddress

**Description:**  
Retrieves the base address of the GTAV.

## Parameters

- **None**: This function does not accept any arguments.

## Return Value

- Returns a **Number** representing the base address of the current module.

## Example Usage

```js
// Get the base address of the current module
var baseAddr = Game.GetBaseAddress();
console.log("Base address:", baseAddr);
```

# Input

## Keyboard

### stringToKey

**Description:**
Converts a string representation of a key name into its corresponding numerical key code. This code can then be used by other functions that expect a numerical key code.

**Parameters:**

- **keyName** (String): The string representing the name of the key (e.g., "A", "Enter", "Space"). You can find the full list of keys in Docs/keys.txt.

**Return Value:**
- Returns a `Number` (integer) representing the key code.

**Error Handling:**
- If the string key name cannot be recognized or converted to a key code, an error is thrown with the message: `"Unable to find the key code for: <keyName>"`.

**Example Usage:**
```js
try {
    var keyCodeA = Input.Keyboard.stringToKey("A");
    var keyCodeEnter = Input.Keyboard.stringToKey("Enter");
    console.log("Key code for 'A':", keyCodeA);
    console.log("Key code for 'Enter':", keyCodeEnter);
} catch (e) {
    console.error(e);
}
```

---

### isPressed

**Description:**  
Checks whether a specific key or combination of keys (packed into a single integer) is currently pressed.  
Useful for querying raw virtual key codes directly rather than relying on key name mappings.

**Parameters:**
- `keyCode` (`int`): A packed integer representing one or more key codes (each byte represents one key).

**Returns:**  
- `true` if all specified keys are currently pressed.  
- `false` if at least one of the keys is not pressed.

**How It Works:**  
The function checks up to 4 key codes stored in each byte of the 32-bit `keyCode`.  
Each byte (from least to most significant) is treated as a separate key.  
If a byte is `0`, the loop terminates.

**Example Usage:**
```js
var keyCode = Input.Keyboard.stringToKey("Ctrl + C")
var isCombo = Input.Keyboard.isPressed(keyCode)
if (isCombo) {
    print("Ctrl+C is pressed")
}
```

## Mouse

### getPos

**Description:**  
Returns the current position of the mouse cursor on the screen.

**Returns:**
- An object `{ x: int, y: int }` representing the cursor's coordinates (in screen space).
- Returns `null` if the position could not be retrieved (e.g. system error).

**Usage Example:**
```js
var pos = Input.Mouse.getPos();
if (pos !== null) {
    print("Mouse X:", pos.x);
    print("Mouse Y:", pos.y);
}
```

---

### setPos

**Description:**  
Sets the mouse cursor position on the screen.

**Arguments:**
- `x` *(int)*: The X coordinate in screen pixels.
- `y` *(int)*: The Y coordinate in screen pixels.

**Returns:**
- `undefined`

**Usage Example:**
```js
Input.Mouse.setPos(100, 200);
```

---

### isScrolledUp

**Description:**  
Checks if the mouse wheel was scrolled up since the last input poll.

**Arguments:**  
- *(none)*

**Returns:**  
- `boolean`: `true` if the wheel was scrolled up, `false` otherwise.

**Usage Example:**
```js
if (Input.Mouse.isScrolledUp()) {
    // Zoom in or scroll up
}
```

---

### isScrolledDown

**Description:**  
Checks if the mouse wheel was scrolled down since the last input poll.

**Arguments:**  
- *(none)*

**Returns:**  
- `boolean`: `true` if the wheel was scrolled down, `false` otherwise.

**Usage Example:**
```js
if (Input.Mouse.isScrolledDown()) {
    // Zoom out or scroll down
}
```

---

### isLeftPressed

**Description:**  
Checks if the left mouse button is currently pressed.

**Arguments:**  
- *(none)*

**Returns:**  
- `boolean`: `true` if the left button is pressed, `false` otherwise.

**Usage Example:**
```js
if (Input.Mouse.isLeftPressed()) {
    // Perform action on left-click
}
```

---

### isRightPressed

**Description:**  
Checks if the right mouse button is currently pressed.

**Arguments:**  
- *(none)*

**Returns:**  
- `boolean`: `true` if the right mouse button is pressed, `false` otherwise.

**Usage Example:**
```js
if (Input.Mouse.isRightPressed()) {
    // Perform action on right-click
}
```

## Gamepad

### selectController

**Description:**  
Selects a game controller for the current `Input.Gamepad` object instance.

This function should be called as a method of an `Input.Gamepad` object.

**Arguments:**  
- `controller` (int) — The ID of the controller to select.

**Returns:**  
- `undefined`

**Usage Example:**
```js
var gamepad = Input.Gamepad();
gamepad.selectController(1); // Select controller with ID 1
```

---

### getController

**Description:**  
Retrieves the currently selected controller ID for the current `Input.Gamepad` object instance.

This function should be called as a method of an `Input.Gamepad` object.

**Arguments:**  
- *(none)*

**Returns:**  
- The controller ID as an integer.

**Usage Example:**
```js
var gamepad = Input.Gamepad();
var controllerId = gamepad.getController(); // By default 0
console.log("Selected controller ID:", controllerId);
```

---

### getPressedKey

**Description:**  
Returns the last key pressed on the selected gamepad controller associated with the current instance of the `Input.Gamepad` object.

This function should be called as a method of an `Input.Gamepad` object.
If no key is pressed, it returns `null`.

**Returns:**  
- The pressed key as a string, or `null` if no key is pressed.

**Usage Example:**
```js
var gamepad = Input.Gamepad();
var pressedKey = gamepad.getPressedKey();

if (pressedKey !== null) console.log("Pressed key:", pressedKey);
else console.log("No key pressed");
```

---

### getPressedKeys

**Description:**  
Returns an array of all the most recently pressed keys on the selected gamepad controller associated with the current instance of the `Input.Gamepad` object.

This function should be called as a method of an `Input.Gamepad` object.

If no keys are pressed, it returns an empty array.

**Returns:**  
- An array of strings representing the pressed keys.
- An empty array if no keys are pressed.

**Usage Example:**
```js
var gamepad = Input.Gamepad();
var pressedKeys = gamepad.getPressedKeys();
if (pressedKeys.length > 0) {
    console.log("Pressed keys:", pressedKeys);
} else {
    console.log("No keys pressed");
}
```

---

### getLeftStickState

**Description:**  
Retrieves the current position of the left analog stick of the selected gamepad controller associated with the current `Input.Gamepad` object instance.

The function returns an object containing the horizontal (`ThumbLX`) and vertical (`ThumbLY`) positions of the left stick.

If the controller or stick state is unavailable, the function returns `null`.

**Returns:**  
- An object with the following numeric properties:
  - `ThumbLX`: Horizontal position of the left stick.
  - `ThumbLY`: Vertical position of the left stick.
- `null` if the state cannot be retrieved.

**Usage Example:**
```js
var gamepad = Input.Gamepad();
var leftStick = gamepad.getLeftStickState();

if (leftStick !== null) {
    console.log("Left Stick Position: X="+leftStick.ThumbLX, "Y=", leftStick.ThumbLY);
} else {
    console.log("Left stick state unavailable");
}
```

---

### getRightStickState

**Description:**  
Retrieves the current state of the right analog stick of the selected gamepad controller associated with the current `Input.Gamepad` object instance.

The function returns an object containing the horizontal (`ThumbRX`) and vertical (`ThumbRY`) positions of the right stick.

If the controller or stick state is unavailable, the function returns `null`.

**Returns:**  
- An object with the following numeric properties:
  - `ThumbRX`: Horizontal position of the right stick.
  - `ThumbRY`: Vertical position of the right stick.
- `null` if the state cannot be retrieved.

**Usage Example:**
```js
let gamepad = Input.Gamepad();
let rightStick = gamepad.getRightStickState();

if (rightStick !== null) {
    console.log("Right Stick Position: X=" + rightStick.ThumbRX, "Y="+rightStick.ThumbRY)
} else {
    console.log("Right stick state unavailable")
}
```

---

### getTriggersState

**Description:**  
Retrieves the current state of the left and right triggers of the selected gamepad controller associated with the current `Input.Gamepad` object instance.

The function returns an object containing the pressure values for the left trigger (`LT`) and the right trigger (`RT`).

If the controller or triggers state is unavailable, the function returns `null`.

**Returns:**  
- An object with the following numeric properties:
  - `LT`: Pressure level of the left trigger.
  - `RT`: Pressure level of the right trigger.
- `null` if the state cannot be retrieved.

**Usage Example:**
```js
var gamepad = Input.Gamepad();
var triggers = gamepad.getTriggersState();

if (triggers !== null) {
    console.log("Triggers: Left=" + triggers.LT, "Right=" + triggers.RT);
} else {
    console.log("Triggers state unavailable");
}
```sendVibration

---

### sendVibration

**Description:**  
Triggers vibration on the selected gamepad controller associated with the current `Input.Gamepad` instance. You can control the intensity and specify which motor(s) should vibrate.

**Parameters:**
1. `strength` *(number)* — A float value representing the vibration strength (e.g., `0.0` to `1.0`).
2. `vibrateLeftMotor` *(boolean)* — Whether to activate the left motor.
3. `vibrateRightMotor` *(boolean)* — Whether to activate the right motor.

**Returns:**  
- `undefined`

**Usage Example:**
```js
var gamepad = Input.Gamepad();
gamepad.sendVibration(0.75, true, false); // Vibrates only the left motor with 75% strength
```

