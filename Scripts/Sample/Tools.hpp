#pragma once
#include <string>
#include <Windows.h>
#include <sstream>


enum class MessageBoxState {
    ID_OK = 1,            //  нопка "OK"
    ID_CANCEL = 2,       //  нопка "Cancel"
    ID_ABORT = 3,        //  нопка "Abort"
    ID_RETRY = 4,        //  нопка "Retry"
    ID_IGNORE = 5,       //  нопка "Ignore"
    ID_YES = 6,          //  нопка "Yes"
    ID_NO = 7,           //  нопка "No"
    // «начени€ ниже могут зависеть от дополнительных кнопок
    ID_HELP = 0x00004000 //  нопка "Help" (возможно расширенные кнопки)
};

std::string GetPathFromPATH(const std::string & folderName);