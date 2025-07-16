#pragma once
#include <string>
#include <iostream>
#include <vector>
#include <mutex>

typedef void (*CommandCallBack)(const std::string&);
typedef signed long long INT64;

enum GlobalVariableType
{
	UNDEFINED = -1,
	NUMBER,
	DOUBLE_NUMBER,
	STRING,
	LIST_OF_NUMBERS,
	LIST_OF_DOUBLES,
	LIST_OF_STRINGS
};


/* GCT Functions */

int GetGCTVersion();
const char* GetGCTStringVersion();
int64_t ConvertStringToKeyCode(char* Key);
bool IsPressedKey(int64_t Key);
bool IsScriptsStillWorking();
bool RestartScripts();
void GCTDisplayError(const std::string& message);


/* Communication */

bool RegisterGlobalVariable(const std::string& name, INT64 value);
bool RegisterGlobalVariable(const std::string& name, double value);
bool RegisterGlobalVariable(const std::string& name, std::string value);
bool RegisterGlobalVariable(const std::string& name, std::vector<INT64> value);
bool RegisterGlobalVariable(const std::string& name, std::vector<double> value);
bool RegisterGlobalVariable(const std::string& name, std::vector<std::string> value);

// Функция для получения типа глобальной переменной
GlobalVariableType GetGlobalVariableType(const std::string& name);

// Функция для получения глобальной переменной
int64_t GetGlobalVariableAsNumber(const std::string& name);
double GetGlobalVariableAsDouble(const std::string& name);
std::string GetGlobalVariableAsString(const std::string& name);
std::vector<INT64> GetGlobalVariableAsVectorOfNumbers(const std::string& name);
std::vector<double> GetGlobalVariableAsVectorOfDoubles(const std::string& name);
std::vector<std::string> GetGlobalVariableAsVectorOfStrings(const std::string& name);

// Функция для установки значения глобальной переменной
void SetGlobalVariableValue(const std::string& name, INT64 value);
void SetGlobalVariableValue(const std::string& name, double value);
void SetGlobalVariableValue(const std::string& name, std::string value);
void SetGlobalVariableValue(const std::string& name, std::vector<INT64> value);
void SetGlobalVariableValue(const std::string& name, std::vector<double> value);
void SetGlobalVariableValue(const std::string& name, std::vector<std::string> value);

// Функция для проверки существования глобальной переменной
bool IsGlobalVariableExist(const std::string& name);

// Функция для очистки хранилищя глобальных переменных
void ClearGlobalVariablesStore();


/* Terminal */

std::mutex& GetConsoleMutex();
bool BindCommand(const char* Command, CommandCallBack callback);
bool UnBindCommand(const char* Command);
bool IsCommandExist(const char* Command);


bool InitFunctions();