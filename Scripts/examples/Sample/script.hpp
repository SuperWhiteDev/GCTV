#pragma once
#include <string>
#include "Gamepad.hpp"

void main();

void mainUI();

enum KeyPressed
{
	NONE,
	KEYBOARD,
	GAMEPAD
};

KeyPressed IsPressed(std::string keyboardKey, std::string gamepadKey);
void UpdatePresses(Gamepad& gamepad);