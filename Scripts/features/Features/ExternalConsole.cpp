#include "ExternalConsole.hpp"
#include "Utils.hpp"
#include "Constants.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>

fs::path             ExternalConsole::outFile;
fs::path             ExternalConsole::inFile;
std::streampos       ExternalConsole::inFileLastPos;
bool                  ExternalConsole::initialized = false;


bool ExternalConsole::Init()
{
    outFile = fs::path(Utils::GetTempFolderPath()) / GCTV_TERMINAL_OUTPUT_FILE;
    inFile = fs::path(Utils::GetTempFolderPath()) / GCTV_TERMINAL_INPUT_FILE;

    /* Creates files if they are not created */
    CreateInFile();
    CreateOutFile();

    initialized = true;

    return true;
}

bool ExternalConsole::Close()
{
    return true;
}

bool ExternalConsole::IsInitialized() { return initialized; }

std::string ExternalConsole::Input(const std::string& prompt)
{
    std::lock_guard lock(GCTV::GetExternalConsoleInMutex());

    Print(prompt);

    std::ifstream file = OpenInFile();
    if (file.is_open()) {
        file.seekg(0, std::ios::end);
        std::streampos size = file.tellg();

        if (size < inFileLastPos) inFileLastPos = 0;

        if (inFileLastPos == -1) {
            file.close();
            Clear();
            file = OpenInFile();
            if (!file.is_open()) throw std::runtime_error("Failed to get input from user.");
            inFileLastPos = 0;
        }

        file.seekg(inFileLastPos);

        std::string line;

        // Main loop: try to read. If there is no data, wait and try again.
        while (GCTV::IsScriptsStillWorking()) {
            // Try to read the new input.
            while (std::getline(file, line)) {
                if (!line.empty() && line.back() == '\r')
                    line.pop_back();

                inFileLastPos = file.tellg();
                return line;
            }

            // Otherwise, if there is no new input, reset the eof flag and wait.
            file.clear();
            Utils::Wait(100);
            // move back to the previous position to try reading again
            file.seekg(inFileLastPos);
        }
    }

    throw std::runtime_error("Failed to get input from user.");
}

std::string ExternalConsole::Input(const std::string& prompt, bool toLower)
{
    std::string res = Input(prompt);

    if (toLower) std::transform(res.begin(), res.end(), res.begin(), ::tolower);

    return res;
}

ExternalConsole::ID ExternalConsole::InputFromList(const std::string& prompt, const std::vector<std::string>& options)
{
    for (size_t i = 0; i < options.size(); ++i)
        Print(std::to_string(i + 1) + ". " + options[i]);

    std::string input = Input(prompt, true);

    if (!input.empty()) {
        if (std::isdigit(input[0])) {
            int choice = std::stoi(input); // Convert the number of the selected option to int.
            if (choice >= 1 && choice <= options.size()) {
                return choice - 1; // Returns the index of the selected option.
            }
        }
        else {
            // Check if the text matches one of the options
            for (size_t i = 0; i < options.size(); ++i) {
                std::string option = options[i];
                std::transform(option.begin(), option.end(), option.begin(), ::tolower);
                if (input == option) {
                    return i; // Returns the index of the selected option.
                }
            }
        }
    }
    return -1;
}

void ExternalConsole::Clear()
{
    std::ofstream file(outFile, std::ios::trunc);
}

void ExternalConsole::CreateInFile()
{
    if (!fs::exists(inFile))
        std::ofstream file(inFile, std::ios::trunc);
}

void ExternalConsole::CreateOutFile()
{
    if (!fs::exists(outFile))
        std::ofstream file(outFile, std::ios::trunc);
}

std::ofstream ExternalConsole::OpenOutFile()
{
    std::ofstream file;

    if (fs::exists(outFile)) {
        int iters = 0;

        do {
            file.open(outFile, std::ios::out | std::ios::app);
            if (!file.is_open()) Utils::Wait(5);
            ++iters;
        } while (iters <= 200 && !file.is_open());

        if (!file.is_open()) throw std::runtime_error("Failed to open output file.");
    }

    return file;
}

std::ifstream ExternalConsole::OpenInFile()
{
    std::ifstream file;

    if (fs::exists(inFile)) {
        int iters = 0;

        do {
            file.open(inFile, std::ios::in);
            if (!file.is_open()) Utils::Wait(5);
            ++iters;
        } while (iters <= 200 && !file.is_open());

        if (!file.is_open()) throw std::runtime_error("Failed to open input file.");
    }

    return file;
}