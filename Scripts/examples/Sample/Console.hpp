#pragma once
#include "Functions.hpp"
#include <algorithm>
#include <mutex>
#include <iostream>
#include <sstream>
#include <vector>
#include <Windows.h>

typedef int ID;



class Console {
public:
    enum Color {
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

    template <typename... Args>
    static void Print(Args... args) {
        // Acquire the mutex to ensure thread-safe output.
        std::lock_guard<std::mutex> lock(GCTV::GetConsoleMutex());

        // Create an output string stream.
        std::ostringstream oss;
        ((oss << args << " "), ...); // Unpack the argument pack.

        // Output the assembled string to the console.
        std::cout << oss.str() << std::endl;
    }

    template <typename... Args>
    static void PrintColoured(Color color, Args... args)
    {
        // Acquire the mutex to guarantee thread-safe colored output.
        std::lock_guard<std::mutex> lock(GCTV::GetConsoleMutex());

        // Create an output string stream.
        std::ostringstream oss;
        ((oss << args << " "), ...); // Unpack the argument pack.

        // Set the console text to the desired color, output the string, then reset the color.
        Console::SetColor(color);
        std::cout << oss.str() << std::endl;
        Console::ResetColor();
    }

    template <typename... Args>
    static void Write(Args... args) {
        // Acquire the mutex for thread-safe output.
        std::lock_guard<std::mutex> lock(GCTV::GetConsoleMutex());

        // Create an output string stream.
        std::ostringstream oss;
        ((oss << args), ...); // Unpack the argument pack.

        // Output the string to the console without appending a newline.
        std::cout << oss.str();
    }

    static void SetColor(Color textColor) {
        HANDLE consoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);
        // Set console text attribute to the specified color.
        SetConsoleTextAttribute(consoleHandle, textColor);
    }

    static void ResetColor() {
        // Reset the console text color to LIGHT_GRAY.
        Console::SetColor(LIGHT_GRAY);
    }

    static std::string Input(const std::string& prompt) {
        // Acquire the mutex for thread-safe input.
        std::lock_guard<std::mutex> lock(GCTV::GetConsoleMutex());
        std::string input;

        std::cout << prompt;
        std::getline(std::cin, input);
        // Optionally, you can add input error checking here.
        return input;
    }

    static std::string Input(const std::string& prompt, bool toLower)
    {
        // Acquire the mutex for thread-safe input.
        std::lock_guard<std::mutex> lock(GCTV::GetConsoleMutex());
        std::string input;

        std::cout << prompt;
        std::getline(std::cin, input);

        // Convert the input string to lowercase if required.
        if (toLower) std::transform(input.begin(), input.end(), input.begin(), ::tolower);

        return input;
    }

    static ID InputFromList(const std::string& prompt, const std::vector<std::string>& options)
    {
        // Display the list of options to the user with numbering.
        for (size_t i = 0; i < options.size(); ++i) {
            std::cout << i + 1 << ". " << options[i] << "\n";
        }

        // Get the user's input; note that this should not be empty.
        std::string input = Console::Input(prompt, true);
        if (input.empty()) {
            // If input is empty, return an invalid index.
            return -1;
        }

        // If the first character is a digit, assume the user selected an option number.
        if (std::isdigit(input[0])) {
            int choice = std::stoi(input); // Convert the string number to an integer.
            if (choice >= 1 && static_cast<size_t>(choice) <= options.size()) {
                return choice - 1; // Return a zero-based index.
            }
        }
        else {
            // Check if the provided text matches any of the options (case-insensitive).
            for (size_t i = 0; i < options.size(); ++i) {
                std::string option = options[i];
                std::transform(option.begin(), option.end(), option.begin(), ::tolower);
                if (input == option) {
                    return i; // Return the matching option's index.
                }
            }
        }

        // Return -1 if no valid option was found.
        return -1;
    }

    template <typename... Args>
    static void Error(Args... args) {
        // Output the error prefix with a designated colored label.
        std::cout << "[";
        SetColor(DARK_RED);
        std::cout << "JavaScript"; // This label represents the error context; consider parameterizing it if needed.
        ResetColor();
        std::cout << "] ";

        // Print the rest of the error message.
        Print(args...);
    }

    static void Clear()
    {
        system("cls");
    }
};
