#include "Terminal.hpp"
#include "Logs.hpp"
#include "Constants.h"
#include "Utils.hpp"
#include "Functions.hpp"

#include <Windows.h>
#include <filesystem>

namespace fs = std::filesystem;

bool Terminal::isInitialized = false;

void Terminal::Init()
{
    if (IsExternalConsoleActive()) ExternalConsole::Init();
    isInitialized = true;
}

bool Terminal::IsConsoleActive() { return GCTV::IsConsoleActive(); }
bool Terminal::IsExternalConsoleActive() { return GCTV::IsExternalConsoleActive(); }

Terminal::Color Terminal::StringToColor(std::string string)
{
    // Default color.
    Color color = Color::LIGHT_GRAY;

    std::transform(string.begin(), string.end(), string.begin(),
        [](unsigned char c) -> unsigned char {
            return std::tolower(c);
        });


    // Map string values (expected to be in lowercase) to corresponding Console::Color enum values.
    if (string == "dark blue") color = Color::DARK_BLUE;
    else if (string == "dark green") color = Color::DARK_GREEN;
    else if (string == "dark aqua") color = Color::DARK_AQUA;
    else if (string == "dark red") color = Color::DARK_RED;
    else if (string == "dark purple") color = Color::DARK_PURPLE;
    else if (string == "dark yellow") color = Color::DARK_YELLOW;
    else if (string == "light gray") color = Color::LIGHT_GRAY;
    else if (string == "dark gray") color = Color::DARK_GRAY;
    else if (string == "blue") color = Color::BLUE;
    else if (string == "green") color = Color::GREEN;
    else if (string == "aqua") color = Color::AQUA;
    else if (string == "red") color = Color::RED;
    else if (string == "purple") color = Color::PURPLE;
    else if (string == "yellow") color = Color::YELLOW;
    else if (string == "white") color = Color::WHITE;

    return color;
}

/* In methods */

void Terminal::Clear()
{
    if (IsConsoleActive()) {
        Console::Clear();
    }
    if (IsExternalConsoleActive() && isInitialized) {
        ExternalConsole::Clear();
    }
}

std::string Terminal::Input(const std::string& prompt)
{
    if (IsConsoleActive())
        return Console::Input(prompt);
    else if (IsExternalConsoleActive() && isInitialized)
        return ExternalConsole::Input(prompt);
}

std::string Terminal::Input(const std::string& prompt, bool toLower)
{
    if (IsConsoleActive()) {
        return Console::Input(prompt, toLower);
    }
    else if (IsExternalConsoleActive() && isInitialized)
        return ExternalConsole::Input(prompt, toLower);
}

Terminal::ID Terminal::InputFromList(const std::string& prompt, const std::vector<std::string>& options)
{
    if (IsConsoleActive())
        return Console::InputFromList(prompt, options);
    else if (IsExternalConsoleActive() && isInitialized)
        return ExternalConsole::InputFromList(prompt, options);
}

void Terminal::SetColor(Color textColor)
{
    if (IsConsoleActive()) Console::SetColor(textColor);
}

void Terminal::ResetColor()
{
    if (IsConsoleActive()) Terminal::ResetColor();
}


// Function for binding a command to a handler function
void Terminal::Commands::Bind(const std::string& command, Terminal::CommandCallBack callback) { GCTV::BindCommand(command.c_str(), callback); }

void Terminal::Commands::UnBind(const std::string& command) { GCTV::UnBindCommand(command.c_str()); }

bool Terminal::Commands::IsBinded(const std::string& command) { GCTV::IsCommandExist(command.c_str()); }