local Graphics = require("graphics++")
local GraphicsBase = require("graphics_base")

while not GraphicsBase.IsGraphicsLibraryLoaded() do
    Wait(1)
end

--GraphicsBase.GetAvailableFonts()

GraphicsBase.SetGlobalFontSizeStr("medium")

local rect1 = Graphics.Rect.DrawRect(30, 50, 600, 450, 255, 0, 255, 255, 1.0)
rect1:SetPosition(5, 50)
rect1:SetSize(300, 200)

local watermark1 = Graphics.Watermark.DrawWatermark("This is graphics++ demo script", 5.0, 5.0, 300.0, 4.0, 0, 255, 255, 255, 255, 0, 255, "", 22.0)

GraphicsBase.ShowNotification("Congratulations!!!\nYou've launched GCTV!", 10.0)

local gradient_rect_alpha = 255
local gradient_rect1 = Graphics.GradientRect.DrawRect(800.0, 800.0, 550, 150, 200, 0, 0, gradient_rect_alpha, 200, 200, 0, gradient_rect_alpha, 0, 200, 0, gradient_rect_alpha, 0, 200, 255, gradient_rect_alpha)

GraphicsBase.AddFont("C:\\Windows\\Fonts\\Arial\\ariblk.ttf", "MyFont", 16.0)
local gradient_rect_text = Graphics.Text.DrawText("Gradient Rect", 985.0, 865.0, 255, 0, 0, 255, "MyFont", 30.0)


local displayX, displayY = GraphicsBase.GetDisplaySize()
local image1 = Graphics.Image.Image("C:\\Program Files\\GCTV\\Images\\picture.png", displayX-35.0, 0.0, 30.0, 30.0)

while true do
    -- Переход от красного к зеленому
    for i = 0, 255 do
        local r = 255 - i  -- Красный уменьшается
        local g = i        -- Зеленый увеличивается
        local b = 0        -- Синий остается 0
        rect1:SetColor(r, g, b, 255)
        Wait(25)

        gradient_rect_alpha = gradient_rect_alpha - 1
        if gradient_rect_alpha < 0 then
            gradient_rect_alpha = 0
        end
        gradient_rect1:SetColor(200, 0, 0, gradient_rect_alpha, 200, 200, 0, gradient_rect_alpha, 0, 200, 0, gradient_rect_alpha, 0, 200, 255, gradient_rect_alpha)
        gradient_rect_text:SetColor(255, 0, 0, gradient_rect_alpha)
    end
    
    -- Переход от зеленого к синему
    for i = 0, 255 do
        local r = 0        -- Красный остается 0
        local g = 255 - i  -- Зеленый уменьшается
        local b = i        -- Синий увеличивается
        rect1:SetColor(r, g, b, 255)
        Wait(25)

        gradient_rect_alpha = gradient_rect_alpha + 1
        if gradient_rect_alpha > 255 then
            gradient_rect_alpha = 255
        end
        gradient_rect1:SetColor(200, 0, 0, gradient_rect_alpha, 200, 200, 0, gradient_rect_alpha, 0, 200, 0, gradient_rect_alpha, 0, 200, 255, gradient_rect_alpha)
        gradient_rect_text:SetColor(255, 0, 0, gradient_rect_alpha)
    end
    
    -- Переход от синего к красному
    for i = 0, 255 do
        local r = i        -- Красный увеличивается
        local g = 0        -- Зеленый остается 0
        local b = 255 - i  -- Синий уменьшается
        rect1:SetColor(r, g, b, 255)
        Wait(25)
    end

    gradient_rect_text:SetFont("Algerian", 30.0)
end