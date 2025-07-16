#include "NativeCaller.h"
#include "Console.hpp"

typedef HASH(__cdecl* _HashString)(const std::string& functionName);
_HashString HashStringF;

typedef uint64_t(__cdecl* _FindFunctionAddress)(const HASH functionHash);
_FindFunctionAddress FindFunctionAddressF;

typedef Vector3* (__cdecl* _GetVector)();
_GetVector GetVectorF;

typedef void(__cdecl* _DeleteVector)(Vector3* vector);
_DeleteVector DeleteVectorF;

typedef float(__cdecl* _ToFloat)(UINT32 value);
_ToFloat ToFloatF;

typedef Ped(__cdecl* _Call_PLAYER_PED_ID)();
_Call_PLAYER_PED_ID Call_PLAYER_PED_IDF;

typedef uintptr_t* (__cdecl* _GetEntityStruct)(Entity entity);
_GetEntityStruct GetEntityStructF;

typedef size_t(__cdecl* _GetAllEntities)(Entity* arrayOfEntities, size_t size);
_GetAllEntities GetAllEntitiesF;

typedef size_t(__cdecl* _GetAllPeds)(Ped* arrayOfPeds, size_t size);
_GetAllPeds GetAllPedsF;

typedef size_t(__cdecl* _GetAllVehicles)(Vehicle* arrayOfVehicles, size_t size);
_GetAllVehicles GetAllVehiclesF;

typedef size_t(__cdecl* _GetAllObjects)(Object* arrayOfObjects, size_t size);
_GetAllObjects GetAllObjectsF;

typedef void(__cdecl* _NativeReset)();
_NativeReset NativeResetF;

typedef void(__cdecl* _NativePush)(void* arg);
_NativePush NativePushF;

typedef void* (__cdecl* _NativeCall)(UINT64 FunctionAddress);
_NativeCall NativeCallF;

typedef std::mutex& (__cdecl* _GetCallMutex)();
_GetCallMutex GetCallMutexF;

HASH HashString(const std::string& functionName) { return HashStringF(functionName); }
uint64_t FindFunctionAddress(const HASH functionHash) { return FindFunctionAddressF(functionHash); }

Vector3* GetVector() { return GetVectorF(); }
void DeleteVector(Vector3* vector) { return DeleteVectorF(vector); }
float ToFloat(UINT32 value) { return ToFloatF(value); }

void InitContext(rage::scrNativeCallContext* context, void* ArgsStack)
{
    context->m_ReturnValue = ArgsStack;
    context->m_Args = ArgsStack;
    context->m_ArgCount = 0;
    context->m_DataCount = 0;
}

Ped Call_PLAYER_PED_ID() { return Call_PLAYER_PED_IDF(); }
uintptr_t* GetEntityStruct(Entity entity) { return GetEntityStructF(entity); }
size_t GetAllEntities(Entity* arrayOfEntities, size_t size) { return GetAllEntitiesF(arrayOfEntities, size); }
size_t GetAllPeds(Ped* arrayOfPeds, size_t size) { return GetAllPedsF(arrayOfPeds, size); }
size_t GetAllVehicles(Vehicle* arrayOfVehicles, size_t size) { return GetAllVehiclesF(arrayOfVehicles, size); }
size_t GetAllObjects(Object* arrayOfObjects, size_t size) { return GetAllObjectsF(arrayOfObjects, size); }

void NativeReset(){ return NativeResetF(); }
void NativePush(void* arg) { return NativePushF(arg); }
void* NativeCall(UINT64 FunctionAddress) { return NativeCallF(FunctionAddress); }
std::mutex& GetCallMutex() { return GetCallMutexF(); }

void* FastNativeCall(Address address, rage::scrNativeCallContext context)
{
    ((RageFunction)address)(&context);
    return (void*)*(UINT64*)context.m_ReturnValue;
}

bool InitNativeCaller()
{
	HMODULE hModule = GetModuleHandleA("GameCommandTerminalV.dll");

    if (!hModule) { Console::Error("DLL", "The GameCommandTerminalV.dll library was not founded. The GameCommandTerminalV.dll library is required for this script to work."); return false; }

    // Getting addresses of functions
    HashStringF = (_HashString)GetProcAddress(hModule, "HashString");
    if (!HashStringF) { Console::Error("DLL", "Failed to get the address of the HashString function."); return false; }

    FindFunctionAddressF = (_FindFunctionAddress)GetProcAddress(hModule, "FindFunctionAddress");
    if (!FindFunctionAddressF) { Console::Error("DLL", "Failed to get the address of the FindFunctionAddress function."); return false; }

    GetVectorF = (_GetVector)GetProcAddress(hModule, "GetVector");
    if (!GetVectorF) { Console::Error("DLL", "Failed to get the address of the GetVector function."); return false; }

    DeleteVectorF = (_DeleteVector)GetProcAddress(hModule, "DeleteVector");
    if (!DeleteVectorF) { Console::Error("DLL", "Failed to get the address of the DeleteVector function."); return false; }

    ToFloatF = (_ToFloat)GetProcAddress(hModule, "ToFloat");
    if (!ToFloatF) { Console::Error("DLL", "Failed to get the address of the ToFloat function."); return false; }

    Call_PLAYER_PED_IDF = (_Call_PLAYER_PED_ID)GetProcAddress(hModule, "Call_PLAYER_PED_ID");
    if (!Call_PLAYER_PED_IDF) { Console::Error("DLL", "Failed to get the address of the Call_PLAYER_PED_ID function."); return false; }

    GetEntityStructF = (_GetEntityStruct)GetProcAddress(hModule, "GetEntityStruct");
    if (!GetEntityStructF) { Console::Error("DLL", "Failed to get the address of the GetEntityStruct function."); return false; }

    GetAllEntitiesF = (_GetAllEntities)GetProcAddress(hModule, "GetAllEntities");
    if (!GetAllEntitiesF) { Console::Error("DLL", "Failed to get the address of the GetAllEntities function."); return false; }

    GetAllPedsF = (_GetAllPeds)GetProcAddress(hModule, "GetAllPeds");
    if (!GetAllPedsF) { Console::Error("DLL", "Failed to get the address of the GetAllPeds function."); return false; }

    GetAllVehiclesF = (_GetAllVehicles)GetProcAddress(hModule, "GetAllVehicles");
    if (!GetAllVehiclesF) { Console::Error("DLL", "Failed to get the address of the GetAllVehicles function."); return false; }

    GetAllObjectsF = (_GetAllObjects)GetProcAddress(hModule, "GetAllObjects");
    if (!GetAllObjectsF) { Console::Error("DLL", "Failed to get the address of the GetAllObjects function."); return false; }

    NativeResetF = (_NativeReset)GetProcAddress(hModule, "NativeReset");
    if (!NativeResetF) { Console::Error("DLL", "Failed to get the address of the NativeReset function."); return false; }

    NativePushF = (_NativePush)GetProcAddress(hModule, "NativePush");
    if (!NativePushF) { Console::Error("DLL", "Failed to get the address of the NativePush function."); return false; }

    NativeCallF = (_NativeCall)GetProcAddress(hModule, "NativeCall");
    if (!NativeCallF) { Console::Error("DLL", "Failed to get the address of the NativeCall function."); return false; }

    GetCallMutexF = (_GetCallMutex)GetProcAddress(hModule, "GetCallMutex");
    if (!GetCallMutexF) { Console::Error("DLL", "Failed to get the address of the GetCallMutex function."); return false; }

	return true;
}
