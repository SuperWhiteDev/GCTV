//const Graphics = require("utils\\Graphics\\graphics_base.js") 
const Graphics = require("utils\\Graphics\\graphics++.js")

function mainUI()
{
    Graphics.Notification("Starting graphics example......")

    oldStyle()

    setTimeout(newStyle, 2000)
}

function newStyle() {
    // A collection of raindrops
    var drops = [];
    var numberDrops = 100;
    var screenWidth = 800;
    var screenHeight = 600;

    // If the screen size function is available, use it
    if (typeof GraphicsBase.getDisplaySize === "function") {
        var ds = GraphicsBase.getDisplaySize();
        screenWidth = ds.width;
        screenHeight = ds.height;
    }

    // Create a raindrop object using the Ellipse constructor.
    // radiusX - horizontal size (usually small), radiusY - vertical size (can be longer for the drop effect)
    for (var i = 0; i < numberDrops; i++) {
        var x = Math.random() * screenWidth;
        // Initial vertical position: slightly above the screen (negative value)
        var y = Math.random() * -screenHeight;

        var r = Math.floor(Math.random() * 256);
        var g = Math.floor(Math.random() * 256);
        var b = Math.floor(Math.random() * 256);

        // Create a drop
        var drop = new Graphics.Ellipse(x, y, 15, 10, r, g, b, 200, 30);
        // Save the coordinates in their own properties for easy updating.
        drop.x = x;
        drop.y = y;
        // Set the drop rate (can be varied, for example, from 5 to 10 pixels per update)
        drop.speed = 5 + Math.random() * 5;
        drops.push(drop);
    }

    var iters = 0

    // Rain animation main loop
    while (ScriptStillWorking && iters <= 150) {
        for (var i = 0; i < drops.length; i++) {
            var drop = drops[i];

            drop.y += drop.speed;
            // If the drop has gone beyond the lower boundary of the screen, reset it to the upper boundary.
            if (drop.y > screenHeight) {
                drop.y = Math.random() * -50;
                drop.x = Math.random() * screenWidth;
            }
            
            drop.setPosition(drop.x, drop.y);
        }

        ++iters

        sleep(30);
    }

    for (var i = 0; i < drops.length; ++i) drops[i].delete()
}


function oldStyle()
{
    while (!GraphicsBase.isGraphicsLibraryLoaded()) sleep(100)

    const width = 200
    const height = 100

    const displaySize = GraphicsBase.getDisplaySize()

    const x = displaySize.width/2 - width/2
    const y = displaySize.height/2 - height/2

    const rectId = GraphicsBase.drawRect(x, y, width, height, 200, 200, 0, 200, 1.0, 0)
    const textId = GraphicsBase.displayText("Hello from javascript!!!\n  Finally it worked!", x+1, y+5, "", 20, 255, 255, 255, 255)
    
    animateRGB(textId, 5000)

    GraphicsBase.deleteElement(rectId)
    GraphicsBase.deleteElement(textId)
}

/**
 * Converts HSL parameters to RGB.
 * h: hue in degrees [0, 360]
 * s: saturation from 0 to 1
 * l: luminance 0 to 1
 * Returns an array [r, g, b] in the range [0, 255]
 */
function hslToRgb(h, s, l) {
    h = h % 360;
    var c = (1 - Math.abs(2 * l - 1)) * s;
    var hPrime = h / 60;
    var x = c * (1 - Math.abs((hPrime % 2) - 1));
    var r1, g1, b1;
    if (hPrime < 1) {
        r1 = c; g1 = x; b1 = 0;
    } else if (hPrime < 2) {
        r1 = x; g1 = c; b1 = 0;
    } else if (hPrime < 3) {
        r1 = 0; g1 = c; b1 = x;
    } else if (hPrime < 4) {
        r1 = 0; g1 = x; b1 = c;
    } else if (hPrime < 5) {
        r1 = x; g1 = 0; b1 = c;
    } else {
        r1 = c; g1 = 0; b1 = x;
    }
    var m = l - c/2;
    var r = Math.round((r1 + m) * 255);
    var g = Math.round((g1 + m) * 255);
    var b = Math.round((b1 + m) * 255);
    return [r, g, b];
}

function animateRGB(element, timeout) {
    var hue = 0;
    var iters = 0

    // Animation main loop
    while (ScriptStillWorking && iters < (timeout/10)/2) {
        // Convert the current hue to RGB at full saturation and medium brightness
        var rgb = hslToRgb(hue, 1, 0.5);
        
        // Call the API function to change the colour of the element;
        // typical signature: setElementColor(id, r, g, b, a)
        GraphicsBase.setElementColor(element, rgb[0], rgb[1], rgb[2], 255);
        
        // Increase the tint by 1 degree.
        hue++;
        if (hue >= 360) {
            hue = 0;
        }

        iters++
        
        sleep(20);
    }
}

setTimeout(mainUI, 1000)