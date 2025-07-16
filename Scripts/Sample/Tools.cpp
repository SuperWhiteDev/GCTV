#include "Tools.hpp"
#include <filesystem>

#pragma warning(disable : 4996)

std::string GetPathFromPATH(const std::string & folderName) {
    // �������� �������� ���������� ����� PATH
    const char* path = std::getenv("PATH");
    if (path == nullptr) {
        return ""; // ���������� ������ ������, ���� ���������� PATH �� �������
    }

    std::string pathString(path);
    std::stringstream ss(pathString);
    std::string item;

    // ��������� ���� �� �����������
#ifdef _WIN32
    const std::string delimiter = ";";
#else
    const std::string delimiter = ":";
#endif

    while (std::getline(ss, item, delimiter[0])) {
        // ���������, ��������� �� ��� ����� � ��������� �����
        std::filesystem::path dir(item);
        if (dir.filename() == folderName) {
            return dir.string(); // ���������� ������ ���� � �����
        }
    }

    return ""; // ���������� ������ ������, ���� ����� �� �������
}