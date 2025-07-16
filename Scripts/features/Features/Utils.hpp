#pragma once
#include <string>
#include <vector>

std::string GetPathFromPATH(const std::string & folderName);

namespace Utils
{
    void Wait(int ms);

    std::string GetGCTVPath();

    std::string GetTempFolderPath();

    std::string GetFileNameWithoutExtension(const std::string &fullPath);

    int64_t ConvertStringToKeyCode(const std::string& keys);

    std::vector<std::string> regex_split(const std::string& s, char delimiter);
}