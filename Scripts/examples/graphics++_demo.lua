-- This script demonstrates various functionalities of the graphics++ and graphics_base libraries
-- for drawing UI elements, displaying notifications, and managing fonts and images in GCTV.

-- Require the graphics++ library, which provides advanced drawing primitives.
local Graphics = require("graphics++")
-- Require the graphics_base library, which provides fundamental graphics utilities.
local GraphicsBase = require("graphics_base")

-- Wait until the graphics library is fully loaded before proceeding.
-- This ensures that all graphics functions are available and ready for use.
while not GraphicsBase.IsGraphicsLibraryLoaded() do
    Wait(1) -- Wait for 1 millisecond to avoid busy-waiting.
end

-- GraphicsBase.GetAvailableFonts() -- This line is commented out in the original, likely for debugging purposes.
                                   -- It would typically return a list of fonts available in the system.

-- Set the global font size for all subsequent text rendering operations.
-- "medium" is a predefined size string.
GraphicsBase.SetGlobalFontSizeStr("medium")

-- Create and draw a rectangle.
-- Parameters: x, y, width, height, r, g, b, a (color), layer (float, lower means behind).
-- The initial color is magenta (255, 0, 255, 255).
local rect1 = Graphics.Rect.DrawRect(30, 50, 600, 450, 255, 0, 255, 255, 1.0)
-- Adjust the position of the rectangle after creation.
rect1:SetPosition(5, 50)
-- Adjust the size of the rectangle after creation.
rect1:SetSize(300, 200)

-- Draw a watermark on the screen.
-- Parameters: text, x, y, width, height, r, g, b, a (text color),
--             r, g, b, a (background color), font_name, font_size.
-- Note: The original example had an empty string for font_name, which might default
-- to a standard font if not specified, or cause issues if a font is strictly required.
local watermark1 = Graphics.Watermark.DrawWatermark("This is graphics++ demo script", 5.0, 5.0, 300.0, 4.0, 0, 255, 255, 255, 255, 0, 255, "", 22.0)

-- Display a notification message to the user.
-- Parameters: message_text, display_time_in_seconds.
GraphicsBase.ShowNotification("Congratulations!!!\nYou've launched GCTV!", 10.0)

-- Initialize the alpha value for the gradient rectangle, starting fully opaque.
local gradient_rect_alpha = 255
-- Draw a rectangle with a gradient color.
-- Parameters: x, y, width, height,
--             r1, g1, b1, a1 (top-left color),
--             r2, g2, b2, a2 (top-right color),
--             r3, g3, b3, a3 (bottom-right color),
--             r4, g4, b4, a4 (bottom-left color).
local gradient_rect1 = Graphics.GradientRect.DrawRect(800.0, 800.0, 550, 150, 
                                                      200, 0, 0, gradient_rect_alpha,      -- Top-left (red)
                                                      200, 200, 0, gradient_rect_alpha,    -- Top-right (yellowish)
                                                      0, 200, 0, gradient_rect_alpha,      -- Bottom-right (green)
                                                      0, 200, 255, gradient_rect_alpha)    -- Bottom-left (cyan)

-- Add a custom font from a file path and register it with a custom name and size.
-- This font can then be used by its custom name.
GraphicsBase.AddFont("C:\\Windows\\Fonts\\Arial\\ariblk.ttf", "MyFont", 16.0)
-- Draw text that will be displayed over the gradient rectangle.
-- Parameters: text_content, x, y, r, g, b, a (text color), font_name, font_size.
local gradient_rect_text = Graphics.Text.DrawText("Gradient Rect", 985.0, 865.0, 255, 0, 0, 255, "MyFont", 30.0)

-- Get the current display size (width and height) for responsive positioning.
local displayX, displayY = GraphicsBase.GetDisplaySize()
-- Create and display an image.
-- Parameters: image_path, x, y, width, height.
-- The image is positioned near the top-right corner of the screen.
local image1 = Graphics.Image.Image("C:\\Program Files\\GCTV\\Images\\picture.png", displayX-35.0, 0.0, 30.0, 30.0)

-- Main loop for continuous animation and updates.
while true do
    -- Animation loop: Transition from Red to Green for rect1, and fade out gradient_rect1/text.
    for i = 0, 255 do
        local r = 255 - i   -- Red component decreases from 255 to 0.
        local g = i         -- Green component increases from 0 to 255.
        local b = 0         -- Blue component remains 0.
        rect1:SetColor(r, g, b, 255) -- Update color of rect1.
        Wait(25) -- Wait for 25 milliseconds for smooth animation.

        -- Decrease alpha for the gradient rectangle and its text.
        gradient_rect_alpha = gradient_rect_alpha - 1
        if gradient_rect_alpha < 0 then
            gradient_rect_alpha = 0 -- Clamp alpha to minimum 0.
        end
        -- Update the colors of the gradient rectangle with the new alpha.
        gradient_rect1:SetColor(200, 0, 0, gradient_rect_alpha, 200, 200, 0, gradient_rect_alpha, 0, 200, 0, gradient_rect_alpha, 0, 200, 255, gradient_rect_alpha)
        -- Update the color of the gradient text with the new alpha.
        gradient_rect_text:SetColor(255, 0, 0, gradient_rect_alpha)
    end
    
    -- Animation loop: Transition from Green to Blue for rect1, and fade in gradient_rect1/text.
    for i = 0, 255 do
        local r = 0         -- Red component remains 0.
        local g = 255 - i   -- Green component decreases from 255 to 0.
        local b = i         -- Blue component increases from 0 to 255.
        rect1:SetColor(r, g, b, 255) -- Update color of rect1.
        Wait(25) -- Wait for 25 milliseconds.

        -- Increase alpha for the gradient rectangle and its text.
        gradient_rect_alpha = gradient_rect_alpha + 1
        if gradient_rect_alpha > 255 then
            gradient_rect_alpha = 255 -- Clamp alpha to maximum 255.
        end
        -- Update the colors of the gradient rectangle with the new alpha.
        gradient_rect1:SetColor(200, 0, 0, gradient_rect_alpha, 200, 200, 0, gradient_rect_alpha, 0, 200, 0, gradient_rect_alpha, 0, 200, 255, gradient_rect_alpha)
        -- Update the color of the gradient text with the new alpha.
        gradient_rect_text:SetColor(255, 0, 0, gradient_rect_alpha)
    end
    
    -- Animation loop: Transition from Blue to Red for rect1 (completing the cycle).
    for i = 0, 255 do
        local r = i         -- Red component increases from 0 to 255.
        local g = 0         -- Green component remains 0.
        local b = 255 - i   -- Blue component decreases from 255 to 0.
        rect1:SetColor(r, g, b, 255) -- Update color of rect1.
        Wait(25) -- Wait for 25 milliseconds.
    end

    -- After the color cycles, change the font of the gradient text.
    -- This demonstrates dynamic font changes.
    gradient_rect_text:SetFont("Algerian", 30.0)
end
