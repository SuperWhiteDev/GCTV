#include "script.hpp"
#include "Game.h"
#include "Gamepad.hpp"
#include "Functions.hpp"
#include "Graphics++.hpp"
#include "Console.hpp"
#include <thread>
#include <vector>

static rage::scrNativeCallContext  g_ctx = {};
static uint64_t g_argsStack[32] = { 0 };

static bool g_thermalVisionEnabled = false;


void main()
{
	InitContext(&g_ctx, &g_argsStack);

	//GCTV::RunScript("examples\\Sample.dll");

	while (GCTV::IsScriptsStillWorking())
	{
		if (g_thermalVisionEnabled) {
			GRAPHICS::SET_SEETHROUGH_f(true);
			Sleep(0);
		}
		else Sleep(300);
	}
}

void SetThermalVision(bool Toggle)
{
	g_thermalVisionEnabled = Toggle;
	if (!g_thermalVisionEnabled) GRAPHICS::SET_SEETHROUGH_f(false);
}