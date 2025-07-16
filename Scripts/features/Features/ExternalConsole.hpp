#pragma once
#include "Functions.hpp"

#include <string>
#include <mutex>
#include <fstream>
#include <filesystem>

namespace fs = std::filesystem;

class ExternalConsole
{
    // Path to the file where we dump console output
    static fs::path outFile;
    // Path to the file from which we read user commands
    static fs::path inFile;

    // Tracks how far we've read in inFile so Input() only picks up new data
    static std::streampos inFileLastPos;

    static bool initialized;
public:
    typedef int ID;

    static bool Init();
    static bool Close();
    static bool IsInitialized();

    /* Function for output to the console */

    template<typename ...Args>
    static void Print(Args ...args)
    {
        std::lock_guard lock(GCTV::GetExternalConsoleOutMutex());

        std::ofstream file = OpenOutFile();

        if (file.is_open()) {
            std::ostringstream oss;
            ((oss << args << " "), ...);

            file << oss.str() << std::endl;

            file.close();
        }
    }

    template<typename ...Args>
    static void Error(std::string moduleName, Args ...args)
    {
        // Print the rest of the error message.
        Print("[JavaScript]: ", args...);
    }

    // Like Print(), but writes raw data without appending newline
    template<typename ...Args>
    static void Write(Args ...args)
    {
        std::lock_guard lock(GCTV::GetExternalConsoleOutMutex());

        std::ofstream file = OpenOutFile();

        if (file.is_open()) {
            std::ostringstream oss;
            ((oss << args), ...);

            file << oss.str();

            file.close();
        }
    }

    /* Method for secure user input */

    // Block until a new command line appears, then return it as-is
    static std::string Input(const std::string& prompt);
    static std::string Input(const std::string& prompt, bool toLower);
    static ID InputFromList(const std::string& prompt, const std::vector<std::string>& options);

    // Clear both files and reset read offset
    static void Clear();
private:
    static void CreateInFile();
    static void CreateOutFile();
    static std::ofstream OpenOutFile();
    static std::ifstream OpenInFile();
};