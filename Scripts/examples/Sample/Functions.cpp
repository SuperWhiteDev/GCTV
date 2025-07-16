#include "Functions.hpp"
#include "Terminal.hpp"

namespace GCTV
{
    typedef int(__cdecl* _GetGCTVersion)();
    _GetGCTVersion GetGCTVersionF;
    typedef const char* (__cdecl* _GetGCTStringVersion)();
    _GetGCTStringVersion GetGCTStringVersionF;
    typedef int64_t(__cdecl* _ConvertStringToKeyCode)(const char* Key);
    _ConvertStringToKeyCode ConvertStringToKeyCodeF;
    typedef bool(__cdecl* _IsPressedKey)(int64_t Key);
    _IsPressedKey IsPressedKeyF;
    typedef bool(__cdecl* _IsScriptsStillWorking)();
    _IsScriptsStillWorking IsScriptsStillWorkingF;
    typedef bool(__cdecl* _RestartScripts)();
    _RestartScripts RestartScriptsF;
    typedef std::string(__cdecl* _GCTVGetString)(const std::string& key);
    _GCTVGetString GCTVGetStringF;
    typedef void(__cdecl* _GCTDisplayError)(const std::string& message);
    _GCTDisplayError GCTDisplayErrorF;
    typedef bool(__cdecl* _RunDLLScript)(const std::string& scriptPath);
    _RunDLLScript RunDLLScriptF;
    typedef const char* (__cdecl* _GetDLLScriptName)(HMODULE hModule);
    _GetDLLScriptName GetDLLScriptNameF;
    typedef std::mutex& (__cdecl* _GetConsoleMutex)();
    _GetConsoleMutex GetConsoleMutexF;
    typedef std::mutex& (__cdecl* _GetLogsMutex)();
    _GetLogsMutex GetLogsMutexF;
    typedef std::mutex& (__cdecl* _GetExternalConsoleOutMutex)();
    _GetExternalConsoleOutMutex GetExternalConsoleOutMutexF;
    typedef std::mutex& (__cdecl* _GetExternalConsoleInMutex)();
    _GetExternalConsoleInMutex GetExternalConsoleInMutexF;

    typedef bool(__cdecl* _IsTerminalConsoleActive)();
    _IsTerminalConsoleActive IsTerminalConsoleActiveF;
    typedef bool(__cdecl* _IsTerminalExternalConsoleActive)();
    _IsTerminalExternalConsoleActive IsTerminalExternalConsoleActiveF;
    typedef bool(__cdecl* _BindCommand)(const char* Command, CommandCallBack callback);
    _BindCommand BindCommandF;
    typedef bool(__cdecl* _UnBindCommand)(const char* Command);
    _UnBindCommand UnBindCommandF;
    typedef bool(__cdecl* _IsCommandExist)(const char* Command);
    _IsCommandExist IsCommandExistF;

    namespace Global
    {
        typedef bool(__cdecl* _RegisterGlobalVariableNumber)(const std::string& name, INT64 value);
        _RegisterGlobalVariableNumber RegisterGlobalVariableNumberF;
        typedef bool(__cdecl* _RegisterGlobalVariableDouble)(const std::string& name, double value);
        _RegisterGlobalVariableDouble RegisterGlobalVariableDoubleF;
        typedef bool(__cdecl* _RegisterGlobalVariableString)(const std::string& name, std::string value);
        _RegisterGlobalVariableString RegisterGlobalVariableStringF;
        typedef bool(__cdecl* _RegisterGlobalVariableVectorOfNumbers)(const std::string& name, const std::vector<INT64> value);
        _RegisterGlobalVariableVectorOfNumbers RegisterGlobalVariableVectorOfNumbersF;
        typedef bool(__cdecl* _RegisterGlobalVariableVectorOfDoubles)(const std::string& name, const std::vector<double> value);
        _RegisterGlobalVariableVectorOfDoubles RegisterGlobalVariableVectorOfDoublesF;
        typedef bool(__cdecl* _RegisterGlobalVariableVectorOfStrings)(const std::string& name, const std::vector<std::string> value);
        _RegisterGlobalVariableVectorOfStrings RegisterGlobalVariableVectorOfStringsF;
        typedef INT64(__cdecl* _GetGlobalVariableAsNumber)(const std::string& name);
        _GetGlobalVariableAsNumber GetGlobalVariableAsNumberF;
        typedef double(__cdecl* _GetGlobalVariableAsDouble)(const std::string& name);
        _GetGlobalVariableAsDouble GetGlobalVariableAsDoubleF;
        typedef std::string(__cdecl* _GetGlobalVariableAsString)(const std::string& name);
        _GetGlobalVariableAsString GetGlobalVariableAsStringF;
        typedef std::vector<INT64>(__cdecl* _GetGlobalVariableAsVectorOfNumbers)(const std::string& name);
        _GetGlobalVariableAsVectorOfNumbers GetGlobalVariableAsVectorOfNumbersF;
        typedef std::vector<double>(__cdecl* _GetGlobalVariableAsVectorOfDoubles)(const std::string& name);
        _GetGlobalVariableAsVectorOfDoubles GetGlobalVariableAsVectorOfDoublesF;
        typedef std::vector<std::string>(__cdecl* _GetGlobalVariableAsVectorOfStrings)(const std::string& name);
        _GetGlobalVariableAsVectorOfStrings GetGlobalVariableAsVectorOfStringsF;
        typedef void(__cdecl* _SetGlobalVariableValueNumber)(const std::string& name, INT64 value);
        _SetGlobalVariableValueNumber SetGlobalVariableValueNumberF;
        typedef void(__cdecl* _SetGlobalVariableValueDouble)(const std::string& name, double value);
        _SetGlobalVariableValueDouble SetGlobalVariableValueDoubleF;
        typedef void(__cdecl* _SetGlobalVariableValueString)(const std::string& name, std::string value);
        _SetGlobalVariableValueString SetGlobalVariableValueStringF;
        typedef void(__cdecl* _SetGlobalVariableValueVectorOfNumbers)(const std::string& name, std::vector<INT64> value);
        _SetGlobalVariableValueVectorOfNumbers SetGlobalVariableValueVectorOfNumbersF;
        typedef void(__cdecl* _SetGlobalVariableValueVectorOfDoubles)(const std::string& name, std::vector<double> value);
        _SetGlobalVariableValueVectorOfDoubles SetGlobalVariableValueVectorOfDoublesF;
        typedef void(__cdecl* _SetGlobalVariableValueVectorOfStrings)(const std::string& name, std::vector<std::string> value);
        _SetGlobalVariableValueVectorOfStrings SetGlobalVariableValueVectorOfStringsF;
        typedef Global::Type(__cdecl* __GetGlobalVariableType)(const std::string& name);
        __GetGlobalVariableType _GetGlobalVariableTypeF;
        typedef bool(__cdecl* __IsGlobalVariableExist)(const std::string& name);
        __IsGlobalVariableExist _IsGlobalVariableExistF;
        typedef void(__cdecl* __ClearGlobalVariablesStore)();
        __ClearGlobalVariablesStore _ClearGlobalVariablesStoreF;
    }

    /* Input functions */

    namespace Input
    {
        typedef int(__cdecl* _GetNextGamepadObjectId)();
        _GetNextGamepadObjectId GetNextGamepadObjectIdF;

        typedef const char* (__cdecl* _GamepadKeyToString)(int key);
        _GamepadKeyToString GamepadKeyToStringF;

        typedef int(__cdecl* _ControllersCount)();
        _ControllersCount ControllersCountF;

        typedef int(__cdecl* _GetSelectedController)(int objectId);
        _GetSelectedController GetSelectedControllerF;

        typedef bool(__cdecl* _SelectController)(int objectId, ControllerId controllerId);
        _SelectController SelectControllerF;

        typedef const char* (__cdecl* _GetPressedKey)(int objectId);
        _GetPressedKey GetPressedKeyF;

        typedef const char** (__cdecl* _GetPressedKeys)(int objectId, size_t* keysCount);
        _GetPressedKeys GetPressedKeysF;

        typedef bool(__cdecl* _GetLeftStickState)(int objectId, StickState* state);
        _GetLeftStickState GetLeftStickStateF;

        typedef bool(__cdecl* _GetRightStickState)(int objectId, StickState* state);
        _GetRightStickState GetRightStickStateF;

        typedef bool(__cdecl* _GetTriggersState)(int objectId, TriggersState* state);
        _GetTriggersState GetTriggersStateF;

        typedef bool(__cdecl* _SendVibration)(int objectId, float strength, bool useLeftMotor, bool useRightMotor);
        _SendVibration SendVibrationF;
    }

    // Name of this DLL script
    std::string g_scriptName;

    /* GCT Functions */

    int GetGCTVersion() { return GetGCTVersionF(); }
    const char* GetGCTStringVersion() { return GetGCTStringVersionF(); }
    int64_t ConvertStringToKeyCode(const char* Key) { return ConvertStringToKeyCodeF(Key); }
    bool IsPressedKey(int64_t Key) { return IsPressedKeyF(Key); }
    bool IsScriptsStillWorking() { return IsScriptsStillWorkingF(); }
    bool RestartScripts() { return RestartScriptsF(); }
    bool RunScript(const std::string& scriptPath) { return RunDLLScriptF(scriptPath); }
    void GCTDisplayError(const std::string& message) { return GCTDisplayErrorF(message); }

    const char* GetDLLScriptName(HMODULE hHandle) { return GetDLLScriptNameF(hHandle); }

    namespace Language {
        std::string GetString(const std::string& key) { return GCTVGetStringF(key); }
    }

    /* Communication */
    namespace Global
    {
        bool Register(const std::string& name, INT64 value) { return RegisterGlobalVariableNumberF(name, value); }
        bool Register(const std::string& name, double value) { return RegisterGlobalVariableDoubleF(name, value); }
        bool Register(const std::string& name, std::string value) { return RegisterGlobalVariableStringF(name, value); }
        bool Register(const std::string& name, std::vector<INT64> value) { return RegisterGlobalVariableVectorOfNumbersF(name, value); }
        bool Register(const std::string& name, std::vector<double> value) { return RegisterGlobalVariableVectorOfDoublesF(name, value); }
        bool Register(const std::string& name, std::vector<std::string> value) { return RegisterGlobalVariableVectorOfStringsF(name, value); }

        Type GetVariableType(const std::string& name) { return _GetGlobalVariableTypeF(name); }

        template<typename T>
        T Get(const std::string& name)
        {
            if constexpr (std::is_same_v<T, INT64>) { return GetGlobalVariableAsNumberF(name); }
            else if constexpr (std::is_same_v<T, double>) { return GetGlobalVariableAsDoubleF(name); }
            else if constexpr (std::is_same_v<T, std::string>) { return GetGlobalVariableAsStringF(name); }
            else if constexpr (std::is_same_v<T, std::vector<INT64>>) { return GetGlobalVariableAsVectorOfNumbersF(name); }
            else if constexpr (std::is_same_v<T, std::vector<double>>) { return GetGlobalVariableAsVectorOfDoublesF(name); }
            else if constexpr (std::is_same_v<T, std::vector<std::string>>) { return GetGlobalVariableAsVectorOfStringsF(name); }
            else {
                static_assert("Global::Get is no support this type!");
            }
        }

        void Set(const std::string& name, INT64 value) { SetGlobalVariableValueNumberF(name, value); }
        void Set(const std::string& name, double value) { SetGlobalVariableValueDoubleF(name, value); }
        void Set(const std::string& name, std::string value) { SetGlobalVariableValueStringF(name, value); }
        void Set(const std::string& name, std::vector<INT64> value) { SetGlobalVariableValueVectorOfNumbersF(name, value); }
        void Set(const std::string& name, std::vector<double> value) { SetGlobalVariableValueVectorOfDoublesF(name, value); }
        void Set(const std::string& name, std::vector<std::string> value) { SetGlobalVariableValueVectorOfStringsF(name, value); }

        bool Exists(const std::string& name) { return _IsGlobalVariableExistF(name); }

        void Clear() { _ClearGlobalVariablesStoreF(); }
    }

    /* Terminal */

    std::mutex& GetConsoleMutex() { return GetConsoleMutexF(); }
    std::mutex& GetLogsMutex() { return GetLogsMutexF(); }
    std::mutex& GetExternalConsoleOutMutex() { return GetExternalConsoleOutMutexF(); }
    std::mutex& GetExternalConsoleInMutex() { return GetExternalConsoleInMutexF(); }

    bool IsConsoleActive() { return IsTerminalConsoleActiveF(); }
    bool IsExternalConsoleActive() { return IsTerminalExternalConsoleActiveF(); }

    bool BindCommand(const char* Command, CommandCallBack callback) { return BindCommandF(Command, callback); }
    bool UnBindCommand(const char* Command) { return UnBindCommandF(Command); }
    bool IsCommandExist(const char* Command) { return IsCommandExistF(Command); }

    /* Input functions */

    int Input::GetNextGamepadObjectId() { return GetNextGamepadObjectIdF(); }
    const char* Input::GamepadKeyToString(int key) { return GamepadKeyToStringF(key); }
    int Input::ControllersCount() { return ControllersCountF(); }
    int Input::GetSelectedController(int objectId) { return GetSelectedControllerF(objectId); }
    bool Input::SelectController(int objectId, ControllerId controllerId) { return SelectControllerF(objectId, controllerId); }
    const char* Input::GetPressedKey(int objectId) { return GetPressedKeyF(objectId); }
    const char** Input::GetPressedKeys(int objectId, size_t* keysCount) { return GetPressedKeysF(objectId, keysCount); }
    bool Input::GetLeftStickState(int objectId, StickState* state) { return GetLeftStickStateF(objectId, state); }
    bool Input::GetRightStickState(int objectId, StickState* state) { return GetRightStickStateF(objectId, state); }
    bool Input::GetTriggersState(int objectId, TriggersState* state) { return GetTriggersStateF(objectId, state); }
    void Input::SendVibration(int objectId, float strength, bool useLeftMotor, bool useRightMotor) { SendVibrationF(objectId, strength, useLeftMotor, useRightMotor); }

    void SetScriptName(std::string scriptName) { g_scriptName = scriptName; }
    std::string& GetScriptName() { return g_scriptName; }

    // Function to initialize the functions by retrieving their addresses from the DLL.
    bool InitFunctions()
    {
        HMODULE hModule = GetModuleHandleA("GameCommandTerminalV.dll");

        if (!hModule) {
            Terminal::Error("The GameCommandTerminalV.dll library was not founded. The GameCommandTerminalV.dll library is required for this script to work.");
            return false;
        }

        // Getting function addresses:
        GetGCTVersionF = (_GetGCTVersion)GetProcAddress(hModule, "GetGCTVersion");
        if (!GetGCTVersionF) { Terminal::Error("Failed to get the address of the GetGCTVersion function\n"); return false; }

        GetGCTStringVersionF = (_GetGCTStringVersion)GetProcAddress(hModule, "GetGCTStringVersion");
        if (!GetGCTStringVersionF) { Terminal::Error("Failed to get the address of the GetGCTStringVersion function\n"); return false; }

        ConvertStringToKeyCodeF = (_ConvertStringToKeyCode)GetProcAddress(hModule, "ConvertStringToKeyCodeF");
        if (!ConvertStringToKeyCodeF) { Terminal::Error("Failed to get the address of the ConvertStringToKeyCodeF function\n"); return false; }

        IsPressedKeyF = (_IsPressedKey)GetProcAddress(hModule, "IsPressedKey");
        if (!IsPressedKeyF) { Terminal::Error("Failed to get the address of the IsPressedKey function\n"); return false; }

        IsScriptsStillWorkingF = (_IsScriptsStillWorking)GetProcAddress(hModule, "IsScriptsStillWorking");
        if (!IsScriptsStillWorkingF) { Terminal::Error("Failed to get the address of the IsScriptsStillWorking function\n"); return false; }

        RestartScriptsF = (_RestartScripts)GetProcAddress(hModule, "RestartScripts");
        if (!RestartScriptsF) { Terminal::Error("Failed to get the address of the RestartScripts function\n"); return false; }

        GCTDisplayErrorF = (_GCTDisplayError)GetProcAddress(hModule, "GCTDisplayError");
        if (!GCTDisplayErrorF) { Terminal::Error("Failed to get the address of the GCTDisplayError function\n"); return false; }

        GetDLLScriptNameF = (_GetDLLScriptName)GetProcAddress(hModule, "GetDLLScriptName");
        if (!GetDLLScriptNameF) { Console::Error("DLL", "Failed to get the address of the GetDLLScriptName function"); return false; }

        RunDLLScriptF = (_RunDLLScript)GetProcAddress(hModule, "RunDLLScript");
        if (!RunDLLScriptF) { Console::Error("DLL", "Failed to get the address of the RunDLLScript function"); return false; }

        GetConsoleMutexF = (_GetConsoleMutex)GetProcAddress(hModule, "GetConsoleMutex");
        if (!GetConsoleMutexF) { Terminal::Error("Failed to get the address of the GetConsoleMutex function\n"); return false; }

        GetLogsMutexF = (_GetLogsMutex)GetProcAddress(hModule, "GetLogsMutex");
        if (!GetLogsMutexF) { Terminal::Error("Failed to get the address of the GetLogsMutex function\n"); return false; }

        GetExternalConsoleOutMutexF = (_GetExternalConsoleOutMutex)GetProcAddress(hModule, "GetExternalConsoleOutMutex");
        if (!GetExternalConsoleOutMutexF) { Terminal::Error("Failed to get the address of the GetExternalConsoleOutMutex function\n"); return false; }

        GetExternalConsoleInMutexF = (_GetExternalConsoleInMutex)GetProcAddress(hModule, "GetExternalConsoleInMutex");
        if (!GetExternalConsoleInMutexF) { Terminal::Error("Failed to get the address of the GetExternalConsoleInMutex function\n"); return false; }  

        GCTVGetStringF = (_GCTVGetString)GetProcAddress(hModule, "GCTVGetString");
        if (!GCTVGetStringF) { Terminal::Error("Failed to get the address of the GCTVGetString function\n"); return false; }

        IsTerminalConsoleActiveF = (_IsTerminalConsoleActive)GetProcAddress(hModule, "IsTerminalConsoleActive");
        if (!IsTerminalConsoleActiveF) { Terminal::Error("Failed to get the address of the IsTerminalConsoleActive function\n"); return false; }

        IsTerminalExternalConsoleActiveF = (_IsTerminalExternalConsoleActive)GetProcAddress(hModule, "IsTerminalExternalConsoleActive");
        if (!IsTerminalExternalConsoleActiveF) { Terminal::Error("Failed to get the address of the IsTerminalExternalConsoleActive function\n"); return false; }
        
        BindCommandF = (_BindCommand)GetProcAddress(hModule, "BindCommand");
        if (!BindCommandF) { Terminal::Error("Failed to get the address of the BindCommand function\n"); return false; }

        UnBindCommandF = (_UnBindCommand)GetProcAddress(hModule, "UnBindCommand");
        if (!UnBindCommandF) { Terminal::Error("Failed to get the address of the UnBindCommand function\n"); return false; }

        IsCommandExistF = (_IsCommandExist)GetProcAddress(hModule, "IsCommandExist");
        if (!IsCommandExistF) { Terminal::Error("Failed to get the address of the IsCommandExist function\n"); return false; }

        Global::RegisterGlobalVariableNumberF = (Global::_RegisterGlobalVariableNumber)GetProcAddress(hModule, "RegisterGlobalVariableNumber");
        if (!Global::RegisterGlobalVariableNumberF) { Terminal::Error("Failed to get the address of the RegisterGlobalVariableNumber function\n"); return false; }

        Global::RegisterGlobalVariableDoubleF = (Global::_RegisterGlobalVariableDouble)GetProcAddress(hModule, "RegisterGlobalVariableDouble");
        if (!Global::RegisterGlobalVariableDoubleF) { Terminal::Error("Failed to get the address of the RegisterGlobalVariableDouble function\n"); return false; }

        Global::RegisterGlobalVariableStringF = (Global::_RegisterGlobalVariableString)GetProcAddress(hModule, "RegisterGlobalVariableString");
        if (!Global::RegisterGlobalVariableStringF) { Terminal::Error("Failed to get the address of the RegisterGlobalVariableString function\n"); return false; }

        Global::RegisterGlobalVariableVectorOfNumbersF = (Global::_RegisterGlobalVariableVectorOfNumbers)GetProcAddress(hModule, "RegisterGlobalVariableVectorOfNumbers");
        if (!Global::RegisterGlobalVariableVectorOfNumbersF) { Terminal::Error("Failed to get the address of the RegisterGlobalVariableVectorOfNumbers function\n"); return false; }

        Global::RegisterGlobalVariableVectorOfDoublesF = (Global::_RegisterGlobalVariableVectorOfDoubles)GetProcAddress(hModule, "RegisterGlobalVariableVectorOfDoubles");
        if (!Global::RegisterGlobalVariableVectorOfDoublesF) { Terminal::Error("Failed to get the address of the RegisterGlobalVariableVectorOfDoubles function\n"); return false; }

        Global::RegisterGlobalVariableVectorOfStringsF = (Global::_RegisterGlobalVariableVectorOfStrings)GetProcAddress(hModule, "RegisterGlobalVariableVectorOfStrings");
        if (!Global::RegisterGlobalVariableVectorOfStringsF) { Terminal::Error("Failed to get the address of the RegisterGlobalVariableVectorOfStrings function\n"); return false; }

        Global::GetGlobalVariableAsNumberF = (Global::_GetGlobalVariableAsNumber)GetProcAddress(hModule, "GetGlobalVariableAsNumber");
        if (!Global::GetGlobalVariableAsNumberF) { Terminal::Error("Failed to get the address of the GetGlobalVariableAsNumber function\n"); return false; }

        Global::GetGlobalVariableAsDoubleF = (Global::_GetGlobalVariableAsDouble)GetProcAddress(hModule, "GetGlobalVariableAsDouble");
        if (!Global::GetGlobalVariableAsDoubleF) { Terminal::Error("Failed to get the address of the GetGlobalVariableAsDouble function\n"); return false; }

        Global::GetGlobalVariableAsStringF = (Global::_GetGlobalVariableAsString)GetProcAddress(hModule, "GetGlobalVariableAsString");
        if (!Global::GetGlobalVariableAsStringF) { Terminal::Error("Failed to get the address of the GetGlobalVariableAsString function\n"); return false; }

        Global::GetGlobalVariableAsVectorOfNumbersF = (Global::_GetGlobalVariableAsVectorOfNumbers)GetProcAddress(hModule, "GetGlobalVariableAsVectorOfNumbers");
        if (!Global::GetGlobalVariableAsVectorOfNumbersF) { Terminal::Error("Failed to get the address of the GetGlobalVariableAsVectorOfNumbers function\n"); return false; }

        Global::GetGlobalVariableAsVectorOfDoublesF = (Global::_GetGlobalVariableAsVectorOfDoubles)GetProcAddress(hModule, "GetGlobalVariableAsVectorOfDoubles");
        if (!Global::GetGlobalVariableAsVectorOfDoublesF) { Terminal::Error("Failed to get the address of the GetGlobalVariableAsVectorOfDoubles function\n"); return false; }

        Global::GetGlobalVariableAsVectorOfStringsF = (Global::_GetGlobalVariableAsVectorOfStrings)GetProcAddress(hModule, "GetGlobalVariableAsVectorOfStrings");
        if (!Global::GetGlobalVariableAsVectorOfStringsF) { Terminal::Error("Failed to get the address of the GetGlobalVariableAsVectorOfStrings function\n"); return false; }

        Global::SetGlobalVariableValueNumberF = (Global::_SetGlobalVariableValueNumber)GetProcAddress(hModule, "SetGlobalVariableValueNumber");
        if (!Global::SetGlobalVariableValueNumberF) { Terminal::Error("Failed to get the address of the SetGlobalVariableValueNumber function\n"); return false; }

        Global::SetGlobalVariableValueDoubleF = (Global::_SetGlobalVariableValueDouble)GetProcAddress(hModule, "SetGlobalVariableValueDouble");
        if (!Global::SetGlobalVariableValueDoubleF) { Terminal::Error("Failed to get the address of the SetGlobalVariableValueDouble function\n"); return false; }

        Global::SetGlobalVariableValueStringF = (Global::_SetGlobalVariableValueString)GetProcAddress(hModule, "SetGlobalVariableValueString");
        if (!Global::SetGlobalVariableValueStringF) { Terminal::Error("Failed to get the address of the SetGlobalVariableValueString function\n"); return false; }

        Global::SetGlobalVariableValueVectorOfNumbersF = (Global::_SetGlobalVariableValueVectorOfNumbers)GetProcAddress(hModule, "SetGlobalVariableValueVectorOfNumbers");
        if (!Global::SetGlobalVariableValueVectorOfNumbersF) { Terminal::Error("Failed to get the address of the SetGlobalVariableValueVectorOfNumbers function\n"); return false; }

        Global::SetGlobalVariableValueVectorOfDoublesF = (Global::_SetGlobalVariableValueVectorOfDoubles)GetProcAddress(hModule, "SetGlobalVariableValueVectorOfDoubles");
        if (!Global::SetGlobalVariableValueVectorOfDoublesF) { Terminal::Error("Failed to get the address of the SetGlobalVariableValueVectorOfDoubles function\n"); return false; }

        Global::SetGlobalVariableValueVectorOfStringsF = (Global::_SetGlobalVariableValueVectorOfStrings)GetProcAddress(hModule, "SetGlobalVariableValueVectorOfStrings");
        if (!Global::SetGlobalVariableValueVectorOfStringsF) { Terminal::Error("Failed to get the address of the SetGlobalVariableValueVectorOfStrings function\n"); return false; }

        Global::_GetGlobalVariableTypeF = (Global::__GetGlobalVariableType)GetProcAddress(hModule, "_GetGlobalVariableType");
        if (!Global::_GetGlobalVariableTypeF) { Terminal::Error("Failed to get the address of the _GetGlobalVariableType function\n"); return false; }

        Global::_IsGlobalVariableExistF = (Global::__IsGlobalVariableExist)GetProcAddress(hModule, "_IsGlobalVariableExist");
        if (!Global::_IsGlobalVariableExistF) { Terminal::Error("Failed to get the address of the _IsGlobalVariableExist function\n"); return false; }

        Global::_ClearGlobalVariablesStoreF = (Global::__ClearGlobalVariablesStore)GetProcAddress(hModule, "_ClearGlobalVariablesStore");
        if (!Global::_ClearGlobalVariablesStoreF) { Terminal::Error("Failed to get the address of the _ClearGlobalVariablesStore function\n"); return false; }

        Input::GetNextGamepadObjectIdF = (Input::_GetNextGamepadObjectId)GetProcAddress(hModule, "GetNextGamepadObjectId");
        if (!Input::GetNextGamepadObjectIdF) { Terminal::Error("Failed to get the address of the GetNextGamepadObjectId function\n"); return false; }

        Input::GamepadKeyToStringF = (Input::_GamepadKeyToString)GetProcAddress(hModule, "GamepadKeyToString");
        if (!Input::GamepadKeyToStringF) { Terminal::Error("Failed to get the address of the GamepadKeyToString function\n"); return false; }

        Input::ControllersCountF = (Input::_ControllersCount)GetProcAddress(hModule, "ControllersCount");
        if (!Input::ControllersCountF) { Terminal::Error("Failed to get the address of the ControllersCount function\n"); return false; }

        Input::GetSelectedControllerF = (Input::_GetSelectedController)GetProcAddress(hModule, "GetSelectedController");
        if (!Input::GetSelectedControllerF) { Terminal::Error("Failed to get the address of the GetSelectedController function\n"); return false; }

        Input::SelectControllerF = (Input::_SelectController)GetProcAddress(hModule, "SelectController");
        if (!Input::SelectControllerF) { Terminal::Error("Failed to get the address of the SelectController function\n"); return false; }

        Input::GetPressedKeyF = (Input::_GetPressedKey)GetProcAddress(hModule, "GetPressedKey");
        if (!Input::GetPressedKeyF) { Terminal::Error("Failed to get the address of the GetPressedKey function\n"); return false; }

        Input::GetPressedKeysF = (Input::_GetPressedKeys)GetProcAddress(hModule, "GetPressedKeys");
        if (!Input::GetPressedKeysF) { Terminal::Error("Failed to get the address of the GetPressedKeys function\n"); return false; }

        Input::GetLeftStickStateF = (Input::_GetLeftStickState)GetProcAddress(hModule, "GetLeftStickState");
        if (!Input::GetLeftStickStateF) { Terminal::Error("Failed to get the address of the GetLeftStickState function\n"); return false; }

        Input::GetRightStickStateF = (Input::_GetRightStickState)GetProcAddress(hModule, "GetRightStickState");
        if (!Input::GetRightStickStateF) { Terminal::Error("Failed to get the address of the GetRightStickState function\n"); return false; }

        Input::GetTriggersStateF = (Input::_GetTriggersState)GetProcAddress(hModule, "GetTriggersState");
        if (!Input::GetTriggersStateF) { Terminal::Error("Failed to get the address of the GetTriggersState function\n"); return false; }

        Input::SendVibrationF = (Input::_SendVibration)GetProcAddress(hModule, "SendVibration");
        if (!Input::SendVibrationF) { Terminal::Error("Failed to get the address of the SendVibration function\n"); return false; }

        return true;
    }
}