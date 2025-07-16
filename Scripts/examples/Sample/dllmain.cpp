#include "dllmain.h"
#include "NativeCaller.h"
#include "Functions.hpp"
#include "Terminal.hpp"
#include "script.hpp"
#include <string>

HMODULE g_hModule = nullptr;

BOOL APIENTRY DllMain( HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        g_hModule = hModule;
        if (InitNativeCaller() && GCTV::InitFunctions()) _beginthread((_beginthread_proc_type)ScriptMain, 0, hModule);
        DisableThreadLibraryCalls(hModule);
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        UnloadScript(hModule);
        break;
    }
    return TRUE;
}

void ScriptMain(HMODULE hModule)
{
    const char* scriptName = GCTV::GetDLLScriptName(g_hModule);
    if (scriptName) GCTV::SetScriptName(scriptName);
    else GCTV::SetScriptName("");

    Terminal::Init();

    try
    {
        main();
    }
    catch (const std::exception& e)
    {
        if (strcmp(e.what(), "AUTOMATIC_TERMINATION") != 0) 
            Terminal::Error("An error occurred: " + std::string(e.what()));
    }
    UnloadScript(hModule);
}

void UnloadScript(HMODULE hModule)
{
    FreeLibraryAndExitThread(hModule, 0);
}