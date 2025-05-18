#include "Tools.hpp"
#include <filesystem>

#pragma warning(disable : 4996)

std::string GetPathFromPATH(const std::string & folderName) {
    // Получаем значение переменной среды PATH
    const char* path = std::getenv("PATH");
    if (path == nullptr) {
        return ""; // Возвращаем пустую строку, если переменная PATH не найдена
    }

    std::string pathString(path);
    std::stringstream ss(pathString);
    std::string item;

    // Разделяем пути по разделителю
#ifdef _WIN32
    const std::string delimiter = ";";
#else
    const std::string delimiter = ":";
#endif

    while (std::getline(ss, item, delimiter[0])) {
        // Проверяем, совпадает ли имя папки с найденным путем
        std::filesystem::path dir(item);
        if (dir.filename() == folderName) {
            return dir.string(); // Возвращаем полный путь к папке
        }
    }

    return ""; // Возвращаем пустую строку, если папка не найдена
}