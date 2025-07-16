// UI.hpp
#pragma once

// ѕримитивы дл€ позиционировани€ и стилизации
struct Position { int x, y; };
struct Size { int width, height; };
struct Color { int r, g, b, a; };

struct RectStyle
{
    Position pos;
    Size     size;
    Color    color;
    int      rounding;
};

namespace UI
{
    namespace Background
    {
        // Menu background rectangle style
        constexpr RectStyle Default = {
            { 10, 10 },             // pos
            { 400, 400 },           // size
            { 100, 100, 100, 200 }, // color RGBA
            15                      // rounding
        };
    }

    namespace Option
    {
        // Inner padding and dimensions of one option background rectangle
        constexpr int paddingX = 10;
        constexpr int paddingY = 10;
        constexpr int spacingY = 5;
        constexpr int height = 30;
        constexpr int rounding = 5;
        constexpr Color color = { 80,  80,  80, 200 };

        constexpr RectStyle Default = {
            {
                Background::Default.pos.x + paddingX,
                Background::Default.pos.y + paddingY
            },
            {
                Background::Default.size.width - 2 * paddingX,
                height
            },
            color,
            rounding
        };
    }

    namespace Cursor
    {
        constexpr int offsetX = 2;
        constexpr int offsetY = 4;
        constexpr int rounding = 5;
        constexpr Color color = { 200, 200, 200, 255 };

        // Style of the "cursor" background rectangle
        constexpr RectStyle Default = {
            {
                Background::Default.pos.x
                  + Option::paddingX
                  - offsetX,
                Background::Default.pos.y
                  + Option::paddingY
                  - offsetY
            },
            {
                Option::Default.size.width + 2 * offsetX,
                Option::Default.size.height + 2 * offsetY
            },
            color,
            rounding
        };
    }
}
