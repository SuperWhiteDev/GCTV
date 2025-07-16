#pragma once
#include <string>
#include <Windows.h>
#include <sstream>


enum class MessageBoxState {
    ID_OK = 1,            // ������ "OK"
    ID_CANCEL = 2,       // ������ "Cancel"
    ID_ABORT = 3,        // ������ "Abort"
    ID_RETRY = 4,        // ������ "Retry"
    ID_IGNORE = 5,       // ������ "Ignore"
    ID_YES = 6,          // ������ "Yes"
    ID_NO = 7,           // ������ "No"
    // �������� ���� ����� �������� �� �������������� ������
    ID_HELP = 0x00004000 // ������ "Help" (�������� ����������� ������)
};

std::string GetPathFromPATH(const std::string & folderName);