const GraphicsBase = require("utils\\Graphics\\graphics_base.js");

globalThis.Graphics = (function() {
    // Function to wait for loading of graphics library
    function isGraphicsLibAvailable() {
        while (!GraphicsBase.isGraphicsLibraryLoaded()) sleep(100)

        GraphicsBase.setGlobalFontSizeStr("medium")
        
        return true
    }

    // --- Constructor function for Line ---
    function Line(x1, y1, x2, y2, r, g, b, alpha, thickness) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawLine(x1, y1, x2, y2, r, g, b, alpha, thickness);
    }
    Line.prototype.setPosition = function(x1, y1, x2, y2) {
        GraphicsBase.setElementPosition(this.elementId, x1, y1, x2, y2);
    };
    Line.prototype.setColor = function(r, g, b, alpha) {
        GraphicsBase.setElementColor(this.elementId, r, g, b, alpha);
    };
    Line.prototype.setThickness = function(thickness) {
        GraphicsBase.setElementExtra(this.elementId, thickness);
    };
    Line.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Rect(x, y, width, height, r, g, b, alpha, rounding) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawRect(x, y, width, height, r, g, b, alpha, rounding, 0);
    }
    Rect.prototype.setPosition = function(x, y) {
        GraphicsBase.setElementPosition(this.elementId, x, y);
    };
    Rect.prototype.setSize = function(width, height) {
        GraphicsBase.setElementSize(this.elementId, width, height);
    };
    Rect.prototype.setColor = function(r, g, b, alpha) {
        GraphicsBase.setElementColor(this.elementId, r, g, b, alpha);
    };
    Rect.prototype.setRounding = function(rounding) {
        GraphicsBase.setElementExtra(this.elementId, rounding, -1);
    };
    Rect.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Triangle(x1, y1, x2, y2, x3, y3, r, g, b, alpha) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawTriangle(x1, y1, x2, y2, x3, y3, r, g, b, alpha);
    }
    Triangle.prototype.setPosition = function(x1, y1, x2, y2, x3, y3) {
        GraphicsBase.setElementPosition(this.elementId, x1, y1, x2, y2, x3, y3);
    };
    Triangle.prototype.setColor = function(r, g, b, alpha) {
        GraphicsBase.setElementColor(this.elementId, r, g, b, alpha);
    };
    Triangle.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Ellipse(x, y, radiusX, radiusY, r, g, b, alpha, segments) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawEllipse(x, y, radiusX, radiusY, r, g, b, alpha, segments);
    }
    Ellipse.prototype.setPosition = function(x, y) {
        GraphicsBase.setElementPosition(this.elementId, x, y);
    };
    Ellipse.prototype.setRadius = function(radiusX, radiusY) {
        GraphicsBase.setElementSize(this.elementId, radiusX, radiusY);
    };
    Ellipse.prototype.setColor = function(r, g, b, alpha) {
        GraphicsBase.setElementColor(this.elementId, r, g, b, alpha);
    };
    Ellipse.prototype.setSegments = function(segments) {
        GraphicsBase.setElementExtra(this.elementId, segments);
    };
    Ellipse.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Text(text, x, y, font, fontSize, r, g, b, alpha) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.displayText(text, x, y, font, fontSize, r, g, b, alpha);
    }
    Text.prototype.setPosition = function(x, y) {
        GraphicsBase.setElementPosition(this.elementId, x, y);
    };
    Text.prototype.setText = function(text) {
        GraphicsBase.setElementText(this.elementId, text);
    };
    Text.prototype.setFont = function(font, fontSize) {
        GraphicsBase.setElementFont(this.elementId, font, fontSize);
    };
    Text.prototype.setColor = function(r, g, b, alpha) {
        GraphicsBase.setElementColor(this.elementId, r, g, b, alpha);
    };
    Text.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function RectWithBorders(x, y, width, height, red, green, blue, alpha, border_r, border_g, border_b, border_thickness, rounding) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawRectWithBorders(x, y, width, height, red, green, blue, alpha,
                                                           border_r, border_g, border_b, border_thickness,
                                                           rounding, 0);
    }
    RectWithBorders.prototype.setPosition = function(x, y, x2, y2) {
        GraphicsBase.setElementPosition(this.elementId, x, y, x2, y2);
    };
    RectWithBorders.prototype.setSize = function(width, height) {
        GraphicsBase.setElementSize(this.elementId, width, height);
    };
    RectWithBorders.prototype.setColor = function(red, green, blue, alpha) {
        GraphicsBase.setElementColor(this.elementId, red, green, blue, alpha);
    };
    RectWithBorders.prototype.setBordersColor = function(red, green, blue, alpha) {
        GraphicsBase.setElementExtra(this.elementId, red, green, blue, alpha, -1, -1, -1);
    };
    RectWithBorders.prototype.setRounding = function(rounding) {
        GraphicsBase.setElementExtra(this.elementId, -1, -1, -1, -1, rounding, -1, -1);
    };
    RectWithBorders.prototype.setThickness = function(thickness) {
        GraphicsBase.setElementExtra(this.elementId, -1, -1, -1, -1, -1, thickness, -1);
    };
    RectWithBorders.prototype.setFlags = function(flags) {
        GraphicsBase.setElementExtra(this.elementId, -1, -1, -1, -1, -1, -1, flags);
    };
    RectWithBorders.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function GradientRect(x, y, width, height,
                          left_bottom_red, left_bottom_green, left_bottom_blue, left_bottom_alpha,
                          left_top_red, left_top_green, left_top_blue, left_top_alpha,
                          right_top_red, right_top_green, right_top_blue, right_top_alpha,
                          right_bottom_red, right_bottom_green, right_bottom_blue, right_bottom_alpha) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawGradientRect(x, y, width, height,
                                  left_bottom_red, left_bottom_green, left_bottom_blue, left_bottom_alpha,
                                  left_top_red, left_top_green, left_top_blue, left_top_alpha,
                                  right_top_red, right_top_green, right_top_blue, right_top_alpha,
                                  right_bottom_red, right_bottom_green, right_bottom_blue, right_bottom_alpha);
    }
    GradientRect.prototype.setPosition = function(x, y) {
        GraphicsBase.setElementPosition(this.elementId, x, y);
    };
    GradientRect.prototype.setSize = function(width, height) {
        GraphicsBase.setElementSize(this.elementId, width, height);
    };
    GradientRect.prototype.setColor = function(
        left_bottom_red, left_bottom_green, left_bottom_blue, left_bottom_alpha,
        left_top_red, left_top_green, left_top_blue, left_top_alpha,
        right_top_red, right_top_green, right_top_blue, right_top_alpha,
        right_bottom_red, right_bottom_green, right_bottom_blue, right_bottom_alpha) {
        GraphicsBase.setElementExtra(this.elementId,
                                     left_bottom_red, left_bottom_green, left_bottom_blue, left_bottom_alpha,
                                     left_top_red, left_top_green, left_top_blue, left_top_alpha,
                                     right_top_red, right_top_green, right_top_blue, right_top_alpha,
                                     right_bottom_red, right_bottom_green, right_bottom_blue, right_bottom_alpha);
    };
    GradientRect.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Watermark(text, x, y, width, height, start_r, start_g, start_b, end_r, end_g, end_b, alpha, font, font_size) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawWatermark(text, x, y, width, height,
                                                     start_r, start_g, start_b, end_r, end_g, end_b, alpha,
                                                     font, font_size);
    }
    Watermark.prototype.setPosition = function(x, y) {
        GraphicsBase.setElementPosition(this.elementId, x, y);
    };
    Watermark.prototype.setSize = function(width, height) {
        GraphicsBase.setElementSize(this.elementId, width, height);
    };
    Watermark.prototype.setLabel = function(text) {
        GraphicsBase.setElementText(this.elementId, text);
    };
    Watermark.prototype.setFont = function(font, font_size) {
        GraphicsBase.setElementFont(this.elementId, font, font_size);
    };
    Watermark.prototype.setStartColor = function(red, green, blue, alpha) {
        GraphicsBase.setElementColor(this.elementId, red, green, blue, alpha);
    };
    Watermark.prototype.setEndColor = function(red, green, blue, alpha) {
        GraphicsBase.setElementExtra(this.elementId, red, green, blue, alpha);
    };
    Watermark.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Image(image_file, x, y, width, height) {
        isGraphicsLibAvailable();
        this.elementId = GraphicsBase.drawImage(image_file, x, y, width, height);
    }
    Image.prototype.setPosition = function(x, y) {
        GraphicsBase.setElementPosition(this.elementId, x, y);
    };
    Image.prototype.setSize = function(width, height) {
        GraphicsBase.setElementSize(this.elementId, width, height);
    };
    Image.prototype.hide = function() {
        GraphicsBase.setElementExtra(this.elementId, 1);
    };
    Image.prototype.show = function() {
        GraphicsBase.setElementExtra(this.elementId, 0);
    };
    Image.prototype.delete = function() {
        GraphicsBase.deleteElement(this.elementId);
    };

    function Notification(message) {
        isGraphicsLibAvailable();
        GraphicsBase.showNotification(message, 10);
    }
    function NotificationWithDuration(message, duration) {
        isGraphicsLibAvailable();
        GraphicsBase.showNotification(message, duration);
    }

    return {
        Line: Line,
        Rect: Rect,
        Triangle: Triangle,
        Ellipse: Ellipse,
        Text: Text,
        RectWithBorders: RectWithBorders,
        GradientRect: GradientRect,
        Watermark: Watermark,
        Image: Image,
        Notification: Notification,
        NotificationWithDuration: NotificationWithDuration
    };
})();
