const Graphics = {
    isGraphicsLibraryLoaded: function () {
        return Call("IsGraphicsLibraryLoaded", "boolean");
    },

    getAvailableFonts: function () {
        Call("GetAvailableFonts", "nil");
    },

    addFont: function (fontFile, fontName, sizePixels) {
        Call("AddFont", "nil string string float", fontFile, fontName, sizePixels);
    },

    drawLine: function (x1, y1, x2, y2, r, g, b, alpha, thickness) {
        return Call("DrawLine", "integer float float float float number number number number float", x1, y1, x2, y2, r, g, b, alpha, thickness);
    },

    drawRect: function (x, y, width, height, r, g, b, alpha, rounding, flags) {
        return Call("DrawRect", "integer float float float float number number number number float number", x, y, width, height, r, g, b, alpha, rounding, flags);
    },

    drawRectWithBorders: function (x, y, width, height, r, g, b, alpha, borderR, borderG, borderB, borderThickness, rounding, flags) {
        return Call("DrawRectWithBorders", "integer float float float float number number number number float number", x, y, width, height, r, g, b, alpha, borderR, borderG, borderB, borderThickness, rounding, flags);
    },

    drawGradientRect: function(x, y, width, height) {
        // Получаем дополнительные аргументы начиная с позиции 4.
        var colors = Array.prototype.slice.call(arguments, 4);
    
        // Эмулируем repeat для строки "number " 16 раз (используем цикл)
        var protoNumbers = "";
        for (var i = 0; i < 16; i++) {
            protoNumbers += "number ";
        }
        
        var prototypeStr = "integer float float float float " + protoNumbers;
    
        // Формируем массив аргументов для Call:
        // Первый элемент – имя функции, второй – прототип, затем x, y, width, height и остальные аргументы
        var args = ["DrawGradientRect", prototypeStr, x, y, width, height].concat(colors);
    
        // Используем apply для передачи массива аргументов
        return Call.apply(null, args);
    },    

    drawTriangle: function (x1, y1, x2, y2, x3, y3, r, g, b, alpha) {
        return Call("DrawTriangle", "integer float float float float float float number number number number", x1, y1, x2, y2, x3, y3, r, g, b, alpha);
    },

    drawEllipse: function (x, y, radiusX, radiusY, r, g, b, alpha, numSegments) {
        return Call("DrawEllipse", "integer float float float float number number number number number", x, y, radiusX, radiusY, r, g, b, alpha, numSegments);
    },

    displayText: function (text, x, y, font, font_size, r, g, b, alpha) {
        return Call("DisplayText", "integer string float float string float number number number number", text, x, y, font, font_size, r, g, b, alpha);
    },

    drawWatermark: function (text, x, y, width, height, start_r, start_g, start_b, end_r, end_g, end_b, alpha, font, font_size) {
        return Call("DrawWatermark", "integer string float float float float number number number number number number number string float", text, x, y, width, height, start_r, start_g, start_b, end_r, end_g, end_b, alpha, font, font_size);
    },

    drawImage: function (imagePath, x, y, width, height) {
        return Call("DrawImage", "integer string float float number number", imagePath, x, y, width, height);
    },

    showNotification: function (text, duration) {
        Call("ShowNotification", "nil string number", text, duration);
    },

    setGlobalFontSize: function (fontSize) {
        Call("SetGlobalFontSize", "nil float", fontSize);
    },

    setGlobalFontSizeStr: function (fontSize) {
        Call("SetGlobalFontSizeStr", "nil string", fontSize)
    },

    setElementPosition: function (id) {
        var position = Array.prototype.slice.call(arguments, 1);
        Call("SetElementPosition", "nil number array", id, position);
    },

    setElementSize: function (id, width, height) {
        Call("SetElementSize", "nil number number number", id, width, height);
    },

    setElementColor: function (id, r, g, b, alpha) {
        Call("SetElementColor", "nil number number number number number", id, r, g, b, alpha);
    },

    setElementText: function (id, text) {
        Call("SetElementText", "nil number string", id, text);
    },

    setElementExtra: function (id) {
        var extra = Array.prototype.slice.call(arguments, 1);

        Call("SetElementExtra", "nil number array", id, extra);
    },

    setElementFont: function (id, font, fontSize) {
        Call("SetElementFont", "nil number string float", id, font, fontSize);
    },

    deleteElement: function (id) {
        Call("DeleteElement", "nil number", id);
    },

    clearRenderList: function () {
        Call("ClearRenderList", "nil");
    },

    getDisplaySize: function () {
        var size = Call("GetDisplaySize", "array(2)");

        return { width: size[0], height: size[1] };
    }
};

globalThis.Graphics = Graphics; // Export to global scope