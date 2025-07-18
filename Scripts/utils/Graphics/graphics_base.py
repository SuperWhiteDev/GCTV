import utils.GCT_utils as utils
import GCT

def get_graphics_module_name():
    version = GCT.Globals.get("GTA_VERSION")
    if version == "Enhanced":
        return "Graphics++_Enhanced.dll"
    elif version == "Legacy":
        return"Graphics++.dll"
    else:
        return"Graphics++.dll"
    
def IsGraphicsLibraryLoaded() -> bool:
    return utils.Call(get_graphics_module_name(), "IsGraphicsLibraryLoaded", utils.ctypes.c_bool)

def GetAvailableFonts() -> None:
    utils.Call(get_graphics_module_name(), "GetAvailableFonts", None)

def AddFont(fontFile : str, fontName : str, sizePixels : int) -> None:
    utils.Call(get_graphics_module_name(), "AddFont", None, fontFile, fontName, sizePixels)

def DrawLine(x1 : int, y1 : int, x2 : int, y2 : int, r : int, g : int, b : int, alpha : int, thickness : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawLine", utils.ctypes.c_int64, x1, y1, x2, y2, r, g, b, alpha, thickness)

def DrawRect(x : int, y : int, width : int, height : int, r : int, g : int, b : int, alpha : int, rounding : int, flags : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawRect", utils.ctypes.c_int64, x, y, width, height, r, g, b, alpha, rounding, flags)

def DrawRectWithBorders(x : int, y : int, width : int, height : int, r : int, g : int, b : int, alpha : int, border_r, border_g, border_b, border_thickness, rounding : int, flags : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawRectWithBorders", utils.ctypes.c_int64, x, y, width, height, r, g, b, alpha, border_r, border_g, border_b, border_thickness, rounding, flags)

def DrawGradientRect(x : int, y : int, width : int, height : int,
                     left_bottom_red : int, left_bottom_green : int, left_bottom_blue : int, left_bottom_alpha : int,
                     left_top_red : int, left_top_green : int, left_top_blue : int, left_top_alpha : int,
                     right_top_red : int, right_top_green : int, right_top_blue : int, right_top_alpha : int,
                     right_bottom_red : int, right_bottom_green : int, right_bottom_blue : int, right_bottom_alpha : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawGradientRect", utils.ctypes.c_int64, x, y, width, height,
                      left_bottom_red, left_bottom_green, left_bottom_blue, left_bottom_alpha,
                      left_top_red, left_top_green, left_top_blue, left_top_alpha,
                      right_top_red, right_top_green, right_top_blue, right_top_alpha,
                      right_bottom_red, right_bottom_green, right_bottom_blue, right_bottom_alpha)

def DrawTriangle(x1 : int, y1 : int, x2 : int, y2 : int, x3 : int, y3 : int, r : int, g : int, b : int, alpha : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawTriangle", utils.ctypes.c_int64, x1, y1, x2, y2, x3, y3, r, g, b, alpha)

def DrawEllipse(x : int, y : int, radiusX : int, radiusY : int, r : int, g : int, b : int, alpha : int, numSegments : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawEllipse", utils.ctypes.c_int64, x, y, radiusX, radiusY, r, g, b, alpha, numSegments)

def DisplayText(text : str, x : int, y : int, font : str, font_size : int, r : int, g : int, b : int, alpha : int) -> int:
    return utils.Call(get_graphics_module_name(), "DisplayText", utils.ctypes.c_int64, text, x, y, font, font_size, r, g, b, alpha)

def DrawWatermark(text : str, x : int, y : int, width : int, height : int, start_r : int, start_g : int, start_b : int, end_r : int, end_g : int, end_b : int, alpha : int, font : str, font_size : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawWatermark", utils.ctypes.c_int64, text, x, y, width, height, start_r, start_g, start_b, end_r, end_g, end_b, alpha, font, font_size)

def DrawImage(image_path : str, x : int, y : int, width : int, height : int) -> int:
    return utils.Call(get_graphics_module_name(), "DrawImage", utils.ctypes.c_int64, image_path, x, y, width, height)

def ShowNotification(text : str, duration : int) -> None:
    utils.Call(get_graphics_module_name(), "ShowNotification", None, text, duration)

def SetGlobalFontSize(font_size : int) -> None:
    utils.Call(get_graphics_module_name(), "SetGlobalFontSize", None, font_size)

""" 
font_size:
small
standart
medium
big
"""
def SetGlobalFontSizeStr(font_size : str) -> None:
    utils.Call(get_graphics_module_name(), "SetGlobalFontSizeStr", None, font_size)

def SetElementPosition(element_id : int, *args) -> None:
    utils.Call(get_graphics_module_name(), "SetElementPosition", None, element_id, utils.list_to_array(args, utils.ctypes.c_int64))

def SetElementSize(element_id : int, width : int, height : int) -> None:
    utils.Call(get_graphics_module_name(), "SetElementSize", None, element_id, width, height)
    
def SetElementColor(element_id : int, r : int, g : int, b : int, alpha : int) -> None:
    utils.Call(get_graphics_module_name(), "SetElementColor", None, element_id, r, g, b, alpha)

def SetElementText(element_id : int, text : str) -> None:
    utils.Call(get_graphics_module_name(), "SetElementText", None, element_id, text)

def SetElementExtra(element_id : int, *args) -> None:
    utils.Call(get_graphics_module_name(), "SetElementExtra", None, element_id, utils.list_to_array(args, utils.ctypes.c_int64))

def SetElementFont(element_id : int, font : str, font_size : int) -> None:
    utils.Call(get_graphics_module_name(), "SetElementFont", None, element_id, font, font_size)

def DeleteElement(element_id : int) -> None:
    utils.Call(get_graphics_module_name(), "DeleteElement", None, element_id)

def ClearRenderList() -> None:
    utils.Call(get_graphics_module_name(), "ClearRenderList", None)
    
def GetDisplaySize() -> tuple[int, int]:
    size = utils.array_to_list(utils.Call(get_graphics_module_name(), "GetDisplaySize", utils.ctypes.POINTER(utils.ctypes.c_int64)), 2, utils.ctypes.c_int64)
    return tuple(size)

def GetCountElementsAtPoint(x : int, y : int) -> int:
    return utils.Call(get_graphics_module_name(), "GetCountElementsAtPoint", utils.ctypes.c_int, x, y)
def GetElementsAtPoint(x : int, y : int) -> tuple:
    elements = utils.array_to_list(utils.Call(get_graphics_module_name(), "GetElementsAtPoint", utils.ctypes.POINTER(utils.ctypes.c_int64), x, y), GetCountElementsAtPoint(x, y), utils.ctypes.c_int64)
    return tuple(elements)
