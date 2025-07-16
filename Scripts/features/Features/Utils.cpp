#include "Utils.hpp"
#include "Constants.h"
#include <filesystem>
#include <unordered_map>
#include <regex>

#pragma warning(disable : 4996)

namespace Utils
{
    /* Map to store key names and their corresponding virtual key codes */
    std::unordered_map<std::string, int> keyMap = {
        // Letters
        {"A", 65},
        {"B", 66},
        {"C", 67},
        {"D", 68},
        {"E", 69},
        {"F", 70},
        {"G", 71},
        {"H", 72},
        {"I", 73},
        {"J", 74},
        {"K", 75},
        {"L", 76},
        {"M", 77},
        {"N", 78},
        {"O", 79},
        {"P", 80},
        {"Q", 81},
        {"R", 82},
        {"S", 83},
        {"T", 84},
        {"U", 85},
        {"V", 86},
        {"W", 87},
        {"X", 88},
        {"Y", 89},
        {"Z", 90},

        // Arrow keys
        {"Left Arrow", 37},
        {"Up Arrow", 38},
        {"Right Arrow", 39},
        {"Down Arrow", 40},

        // Modifiers
        {"Ctrl", 17},
        {"LCtrl", 162},
        {"RCtrl", 163},
        {"Shift", 16},
        {"LShift", 160},
        {"RShift", 161},
        {"Alt", 18},

        // Function keys
        {"F1", 112},
        {"F2", 113},
        {"F3", 114},
        {"F4", 115},
        {"F5", 116},
        {"F6", 117},
        {"F7", 118},
        {"F8", 119},
        {"F9", 120},
        {"F10", 121},
        {"F11", 122},
        {"F12", 123},

        // Numbers
        {"0", 48},
        {"1", 49},
        {"2", 50},
        {"3", 51},
        {"4", 52},
        {"5", 53},
        {"6", 54},
        {"7", 55},
        {"8", 56},
        {"9", 57},

        // Special keys
        {"Space", 32},
        {"Enter", 13},
        {"Backspace", 8},
        {"Tab", 9},
        {"Escape", 27},
        {"Insert", 45},
        {"Delete", 46},
        {"Home", 36},
        {"End", 35},
        {"Page Up", 33},
        {"Page Down", 34},

        // Miscellaneous keys
        {"Print Screen", 44},
        {"Scroll Lock", 145},
        {"Pause/Break", 19},
        {"Caps Lock", 20},
        {"Num Lock", 144},

        // Navigation keys
        {"Left Windows", 91},
        {"Right Windows", 92},
        {"Applications", 93},

        // Mouse buttons
        {"Mouse Left", 1},
        {"Mouse Right", 2},
        {"Mouse Middle", 4},
        {"Mouse X1", 5},
        {"Mouse X2", 6},
        {"Mouse Wheel Up", 2048},
        {"Mouse Wheel Down", 2049},

        // Additional virtual keys
        {"Audio Volume Mute", 173},
        {"Audio Volume Down", 174},
        {"Audio Volume Up", 175},
        {"Media Next Track", 176},
        {"Media Previous Track", 177},
        {"Media Stop", 178},
        {"Media Play/Pause", 179},
        {"Launch Mail", 180},
        {"Launch Media", 181},
        {"Launch Application 1", 182},
        {"Launch Application 2", 183},
    };

    std::string GetPathFromPATH(const std::string& folderName) {
        // Get the value of the PATH environment variable
        const char* path = std::getenv("PATH");
        if (path == nullptr) {
            return ""; // Return an empty string if the PATH variable is not found
        }

        std::string pathString(path);
        std::stringstream ss(pathString);
        std::string item;

        // Split paths by delimiter
#ifdef _WIN32
        const std::string delimiter = ";";
#else
        const std::string delimiter = ":";
#endif

        while (std::getline(ss, item, delimiter[0])) {
            // Check if the folder name matches the found path
            std::filesystem::path dir(item);
            if (dir.filename() == folderName) {
                return dir.string(); // Return the full path of the folder
            }
        }

        return ""; // Return an empty string if the folder is not found
    }

    void Wait(int ms)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(ms));
    }

    std::string GetGCTVPath()
    {
        return Utils::GetPathFromPATH(GCTV_NAME);
    }

    std::string GetTempFolderPath() {
        const char* temp = std::getenv("TEMP");
        if (!temp) {
            temp = std::getenv("TMP");
        }
        if (!temp) {
            temp = "/tmp"; // Default path for Unix-like systems
        }
        return temp;
    }

    std::string GetFileNameWithoutExtension(const std::string& fullPath) {
        size_t lastSlash = fullPath.find_last_of("/\\");
        std::string fileName = (lastSlash != std::string::npos) ? fullPath.substr(lastSlash + 1) : fullPath;

        size_t lastDot = fileName.find_last_of('.');
        return (lastDot != std::string::npos) ? fileName.substr(0, lastDot) : fileName; // Return the file name without extension
    }

    /* Function to convert a string of key names into a key code number */
    int64_t ConvertStringToKeyCode(const std::string& keys) {
        std::istringstream stream(keys);
        std::string key;
        int64_t result = 0;
        int byteIndex = 0;

        while (std::getline(stream, key, '+')) { // Split the input by '+'
            if (byteIndex >= 8) return 0;

            key = key; // No trimming required in this case
            auto it = keyMap.find(key);
            if (it != keyMap.end()) {
                result |= (it->second << (byteIndex * 8)); // Shift and add to result
                byteIndex++;
            }
            else {
                return 0; // Return 0 if key name not found
            }
        }

        return result;
    }

    /* Function to split a string using regex */
    std::vector<std::string> regex_split(const std::string& s, char delimiter) {
        std::vector<std::string> result;
        std::stringstream ss(s);

        std::string item;

        while (std::getline(ss, item, delimiter)) result.push_back(item);

        return result;
    }
}