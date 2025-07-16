/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

console.log("=== Script Start ===");

// 1. Print the current time (using the getCurrentTime function)
var currentTime = getCurrentTime();
console.log("Current time: " + currentTime);

// 2. Demonstrate math operations via the custom Math object:
console.log("=== Math Operations ===");
console.log("abs(-7) = " + Math.abs(-7));
console.log("acos(0.5) = " + Math.acos(0.5));
console.log("asin(0.5) = " + Math.asin(0.5));
console.log("atan(1) = " + Math.atan(1));
console.log("atan2(1, 1) = " + Math.atan2(1, 1));
console.log("ceil(3.2) = " + Math.ceil(3.2));
console.log("cos(0) = " + Math.cos(0));
console.log("exp(1) = " + Math.exp(1));
console.log("floor(3.8) = " + Math.floor(3.8));
console.log("log(2.71828) = " + Math.log(2.71828));
console.log("max(3, 7, 2, -5) = " + Math.max(3, 7, 2, -5));
console.log("min(3, 7, 2, -5) = " + Math.min(3, 7, 2, -5));
console.log("pow(2, 8) = " + Math.pow(2, 8));
console.log("random() = " + Math.random());
console.log("round(3.5) = " + Math.round(3.5));
console.log("sin(1.57) = " + Math.sin(1.57));
console.log("sqrt(16) = " + Math.sqrt(16));
console.log("tan(0.785) = " + Math.tan(0.785));

// Generate a random number using Math.random()
var rnd = Math.random();
console.log("Generated random number: " + rnd);

// 3. Demonstrate string manipulation functions:
var originalText = "   ExaMPle STRING FOR ManIPUlatiON   ";
console.log("Original text: [" + originalText + "]");

var trimmed = trimString(originalText);
console.log("After trimString(): [" + trimmed + "]");

var lower = toLowerCase(trimmed);
console.log("After toLowerCase(): [" + lower + "]");

var capitalized = capitalize(lower);
console.log("After capitalize(): [" + capitalized + "]");

// 4. File system demonstration:
// Use fs.readdir to get an array of file names from a directory, and fs.readFile to read file content.
var scriptsFolder = GetGCTFolder() + "\\Scripts\\examples";
var fileList = fs.readdir(scriptsFolder);
console.log("Files in directory [" + scriptsFolder + "]: " + fileList.join(", "));

// If there are files, read the content of the first file.
if (fileList.length > 0) {
    var firstFilePath = scriptsFolder + "\\" + fileList[0];
    var content = fs.readFile(firstFilePath);
    console.log("Content of file [" + fileList[0] + "]:\n" + content);
} else {
    console.log("No files found in the directory.");
}

// 5. JSON objects demonstration:
var person = {
    name: capitalized,
    age: Math.floor(20 + Math.random() * 10), // random age between 20 and 30
    registeredAt: currentTime
};

var jsonStr = JSON.stringify(person);
console.log("Serialized JSON: " + jsonStr);

var parsedPerson = JSON.parse(jsonStr);
console.log("Parsed JSON: Name: " + parsedPerson.name + ", Age: " + parsedPerson.age);

// 6. Array iteration and filtering demonstration:
var numbers = [ -10, -5, 0, 5, 10, 15, 20 ];
console.log("Original array of numbers: " + numbers);

// Filter for positive numbers.
var positives = [];
for (var i = 0; i < numbers.length; i++) {
    if (numbers[i] > 0) {
        positives.push(numbers[i]);
    }
}
console.log("Positive numbers: " + positives.join(", "));

// 7. Complex mathematical expression example:
// Compute the formula: y = sqrt(pow(x, 2) + pow(10, 2))
var x = 5;
var y = Math.sqrt(Math.pow(x, 2) + Math.pow(10, 2));
console.log("For x = " + x + ", y = sqrt(x^2 + 10^2) = " + y);

// 8. Loop and conditional demonstration:
// Generate 5 random numbers and check if each is even or odd.
console.log("Checking parity of random numbers:");
for (var i = 0; i < 5; i++) {
    var rndNum = Math.floor(Math.random() * 100);
    var parity = (rndNum % 2 === 0) ? "even" : "odd";
    console.log(rndNum + " is " + parity);
}

console.log("=== Script End ===");
