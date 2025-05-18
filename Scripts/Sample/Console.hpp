#pragma once
#include "Functions.h"
#include <algorithm>
#include <mutex>
#include <iostream>
#include <sstream>
#include <vector>
#include <Windows.h>


typedef int ID;

enum ConsoleColor {
    BLACK = 0,
    DARK_BLUE = 1,
    DARK_GREEN = 2,
    DARK_AQUA = 3,
    DARK_RED = 4,
    DARK_PURPLE = 5,
    DARK_YELLOW = 6,
    LIGHT_GRAY = 7,
    DARK_GRAY = 8,
    BLUE = 9,
    GREEN = 0xA,
    AQUA = 0xB,
    RED = 0xC,
    PURPLE = 0xD,
    YELLOW = 0xE,
    WHITE = 0xF
};

class Console {
public:
    template <typename... Args>
    static void Print(Args... args) {
        // Захват мьютекса
        std::lock_guard<std::mutex> lock(GetConsoleMutex());

        // Создание выходного потока
        std::ostringstream oss;
        ((oss << args << " "), ...); // Разворачиваем пакет аргументов

        // Вывод строки в консоль
        std::cout << oss.str() << std::endl;
    }

    static void Print(uint64_t value) {
        // Захват мьютекса для потокобезопасного вывода
        std::lock_guard<std::mutex> lock(GetConsoleMutex());

        // Вывод UINT64 в шестнадцатеричном формате
        std::cout << "0x" << std::hex << std::uppercase << value << std::dec << std::endl;
    }

    static void Print(const char* string, uint64_t value) {
        // Захват мьютекса для потокобезопасного вывода
        std::lock_guard<std::mutex> lock(GetConsoleMutex());

        // Вывод UINT64 в шестнадцатеричном формате
        std::cout << string << " " << "0x" << std::hex << std::uppercase << value << std::dec << std::endl;
    }

    template <typename... Args>
    static void PrintColoured(ConsoleColor color, Args... args)
    {
        // Захват мьютекса
        std::lock_guard<std::mutex> lock(GetConsoleMutex());

        // Создание выходного потока
        std::ostringstream oss;
        ((oss << args << " "), ...); // Разворачиваем пакет аргументов

        // Вывод цветной строки в консоль
        Console::SetColor(color);
        std::cout << oss.str() << std::endl;
        Console::ResetColor();
    }

    template <typename... Args>
    static void Write(Args... args) {
        // Захват мьютекса
        std::lock_guard<std::mutex> lock(GetConsoleMutex());

        // Создание выходного потока
        std::ostringstream oss;
        ((oss << args), ...); // Разворачиваем пакет аргументов

        // Вывод строки в консоль
        std::cout << oss.str();
    }

    static void SetColor(ConsoleColor textColor) {
        HANDLE consoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);
        SetConsoleTextAttribute(consoleHandle, textColor);
    }

    static void ResetColor() {
        Console::SetColor(LIGHT_GRAY);
    }

    std::string Input(const std::string& prompt) {
        // Захват мьютекса для потокобезопасного ввода
        std::lock_guard<std::mutex> lock(GetConsoleMutex());
        std::string input;

        std::cout << prompt;
        std::getline(std::cin, input);
        return input;
    }

    static std::string Input(const std::string& prompt, bool toLower)
    {
        std::lock_guard<std::mutex> lock(GetConsoleMutex());
        std::string input;

        std::cout << prompt;
        std::getline(std::cin, input);

        if (toLower) std::transform(input.begin(), input.end(), input.begin(), ::tolower);

        return input;
    }

    static ID InputFromList(const std::string& prompt, const std::vector<std::string>& options)
    {
        for (size_t i = 0; i < options.size(); ++i) {
            std::cout << i + 1 << ". " << options[i] << "\n";
        }

        std::string Input = Console::Input(prompt, true);

        if (std::isdigit(Input[0])) {
            int choice = std::stoi(Input); // Преобразуем номер в int
            if (choice >= 1 && choice <= options.size()) {
                return choice - 1;
            }
        }
        else {
            // Проверяем, совпадает ли текст с одним из вариантов
            for (size_t i = 0; i < options.size(); ++i) {
                std::string option = options[i];
                std::transform(option.begin(), option.end(), option.begin(), ::tolower);
                if (Input == option) {
                    return i; // Возвращаем индекс варианта
                }
            }
        }

        return -1;
    }
};