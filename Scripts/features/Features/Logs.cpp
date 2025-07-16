#include "Logs.hpp"
#include "Utils.hpp"
#include "Constants.h"
#include "Console.hpp"
#include "Functions.hpp"
#include <fstream>
#include <ctime>
#include <filesystem>

#pragma warning(disable : 4996)

namespace fs = std::filesystem;

void Logger::Log(LogLevel level, const std::string& message) {
    std::lock_guard<std::mutex> lock(GCTV::GetLogsMutex());

    fs::path logFilePath = fs::path(Utils::GetGCTVPath()) / GCTV_LOGS_FOLDER / GCT_LOG_FILE;

    // Open the log file to record a new record with the current date and priority level.
    std::ofstream logFile(logFilePath, std::ios::app);
    if (logFile.is_open()) {
        logFile << "[" << CurrentDateTime() << "] [" << LogLevelToString(level) << "] " << message << std::endl;
        logFile.close();
    }
    else {
        Console::Error(GCTV_NAME, GCTV::Language::GetString("FailedOpenLogFile"));
    }
}

std::string Logger::CurrentDateTime() {
    std::time_t now = std::time(nullptr);
    char buf[100];
    std::strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", std::localtime(&now));
    return buf;
}

std::string Logger::LogLevelToString(LogLevel level) {
    switch (level) {
    case LogLevel::DEBUG: return "DEBUG";
    case LogLevel::INFO: return "INFO";
    case LogLevel::WARNING: return "WARNING";
    case LogLevel::CRITICAL_ERROR: return "ERROR";
    default: return "UNKNOWN";
    }
}