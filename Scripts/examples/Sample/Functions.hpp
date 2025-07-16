#pragma once
#include <string>
#include <vector>
#include <mutex>
#include <Windows.h>

typedef signed long long INT64;

namespace GCTV
{
    // Typedef for a command callback function that receives a string argument.
    typedef void (*CommandCallBack)(const std::string&);

    /* GCT Functions */

    int GetGCTVersion();
    const char* GetGCTStringVersion();
    int64_t ConvertStringToKeyCode(const char* Key);
    bool IsPressedKey(int64_t Key);
    bool IsScriptsStillWorking();
    bool RestartScripts();
    void GCTDisplayError(const std::string& message);
    bool RunScript(const std::string& scriptPath);
    const char* GetDLLScriptName(HMODULE hHandle);

    /* Language Packet */
    namespace Language {
        std::string GetString(const std::string& key);
    }

    /* Communication */
    namespace Global
    {
        // Enumeration for the type of a global variable.
        enum Type
        {
            UNDEFINED = -1,
            NUMBER,
            DOUBLE_NUMBER,
            STRING,
            LIST_OF_NUMBERS,
            LIST_OF_DOUBLES,
            LIST_OF_STRINGS
        };

        bool Register(const std::string& name, INT64 value);
        bool Register(const std::string& name, double value);
        bool Register(const std::string& name, std::string value);
        bool Register(const std::string& name, std::vector<INT64> value);
        bool Register(const std::string& name, std::vector<double> value);
        bool Register(const std::string& name, std::vector<std::string> value);

        // Function to get the type of a global variable
        Type GetVariableType(const std::string& name);

        // Function to get global variable
        template<typename T>
        T Get(const std::string& name);

        template INT64 Get(const std::string& name);
        template double Get(const std::string& name);
        template std::string Get(const std::string& name);
        template std::vector<INT64> Get(const std::string& name);
        template std::vector<double> Get(const std::string& name);
        template std::vector<std::string> Get(const std::string& name);

        // Function to set the value of a global variable
        void Set(const std::string& name, INT64 value);
        void Set(const std::string& name, double value);
        void Set(const std::string& name, std::string value);
        void Set(const std::string& name, std::vector<INT64> value);
        void Set(const std::string& name, std::vector<double> value);
        void Set(const std::string& name, std::vector<std::string> value);

        // Function to check existence of global variable
        bool Exists(const std::string& name);

        // Function to clear global variable storage
        void Clear();
    }

    /* Terminal */

    // Returns a reference to the console mutex, ensuring thread-safe operations.
    std::mutex& GetConsoleMutex();

    std::mutex& GetLogsMutex();

    std::mutex& GetExternalConsoleOutMutex();
    std::mutex& GetExternalConsoleInMutex();

    bool IsConsoleActive();

    bool IsExternalConsoleActive();

    bool BindCommand(const char* Command, CommandCallBack callback);
    bool UnBindCommand(const char* Command);
    bool IsCommandExist(const char* Command);

    const char* GetDLLScriptName(HMODULE hHandle);

    /* Input */
    namespace Input
    {
        // Enumeration for the controller identifier.
        enum ControllerId
        {
            UNKNOWN = -1,
            FIRST = 0,
            SECOND = 1,
            THIRD = 2,
            FOURTH = 3
        };

        // Structure representing the state of a controller's analog stick.
        struct StickState
        {
            float ThumbX;
            float ThumbY;
        };

        // Structure representing the state of a controller's triggers.
        struct TriggersState
        {
            float LT;
            float RT;
        };
        struct Object
        {
            ControllerId controllerId;
            uint64_t lastInput;
        };

        int GetNextGamepadObjectId();

        const char* GamepadKeyToString(int key);
        int ControllersCount();

        int GetSelectedController(int objectId);

        bool SelectController(int objectId, ControllerId controllerId);

        const char* GetPressedKey(int objectId);
        const char** GetPressedKeys(int objectId, size_t* keysCount);

        bool GetLeftStickState(int objectId, StickState* state);
        bool GetRightStickState(int objectId, StickState* state);

        bool GetTriggersState(int objectId, TriggersState* state);

        void SendVibration(int objectId, float strength, bool useLeftMotor, bool useRightMotor);
    }



    bool InitFunctions();

    void SetScriptName(std::string scriptName);
    std::string& GetScriptName();
}