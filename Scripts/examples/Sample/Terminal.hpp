#pragma once
#include "Console.hpp"
#include "ExternalConsole.hpp"
#include "Logs.hpp"
#include <string>
#include <unordered_map>
#include <mutex>
#include <cstdio>

class Terminal
{
	static bool isInitialized;
public:
	using Color = Console::Color;

	typedef void (*CommandCallBack)(const std::string&);
public:
	typedef int ID;

	static void Init();

	static bool IsConsoleActive();
	static bool IsExternalConsoleActive();

	static Color StringToColor(std::string string);

	/* Out methods */
	template<typename ...Args>
	static void Print(Args ...args)
	{
		if (IsConsoleActive())
			Console::Print(args...);
		if (IsExternalConsoleActive() && isInitialized)
			ExternalConsole::Print(args...);
	}

	template<typename ...Args>
	static void Error(Args ...args)
	{
		// Convert all arguments to one string
		std::ostringstream oss;
		((oss << args << " "), ...);
		Logger::Log(Logger::LogLevel::CRITICAL_ERROR, oss.str());

		if (IsConsoleActive())
			Console::Error(args...);
		if (IsExternalConsoleActive() && isInitialized)
			ExternalConsole::Error(args...);
	}

	template <typename... Args>
	static void PrintColoured(Color color, Args... args)
	{
		if (IsConsoleActive())
			Console::PrintColoured(color, args...);
		if (IsExternalConsoleActive())
			ExternalConsole::Print(args...);
	}

	// Like Print(), but writes raw data without appending newline
	template<typename ...Args>
	static void Write(Args ...args)
	{
		if (IsConsoleActive())
			Console::Write(args...);
		if (IsExternalConsoleActive() && isInitialized)
			ExternalConsole::Write(args...);

	}

	// Clear both files and reset read offset
	static void Clear();

	static void SetColor(Color textColor);

	static void ResetColor();

	/* In methods */

	static std::string Input(const std::string& prompt);
	static std::string Input(const std::string& prompt, bool toLower);
	static ID InputFromList(const std::string& prompt, const std::vector<std::string>& options);

	// Command registry API
	class Commands
	{
	public:
		// Function for binding a command to a handler function
		static void Bind(const std::string& command, CommandCallBack callback);
		static void UnBind(const std::string& command);
		static bool IsBinded(const std::string& command);
		static void Clear();
	};
};