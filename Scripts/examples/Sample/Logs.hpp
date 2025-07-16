#pragma once
#include <string>
#include <mutex>

class Logger {
public:
    enum class LogLevel {
        DEBUG,
        INFO,
        WARNING,
        CRITICAL_ERROR
    };

    // Logging the message with the specified level and specifying the current time and date
    static void Log(LogLevel level, const std::string& message);

private:
    // Support functions
    static std::string CurrentDateTime();
    static std::string LogLevelToString(LogLevel level);
};