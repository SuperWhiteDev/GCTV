#include "script.hpp"
#include "Game.h"
#include "Terminal.hpp"
#include "Functions.hpp"
#include "Graphics++.hpp"
#include "UI.hpp"
#include "Gamepad.hpp"
#include "enums.h"
#include <thread>
#include <vector>
#include <chrono>

#define GET_TIME() std::chrono::steady_clock::now()

/* Toggle menu keys */
const std::string OPEN_MENU_KEY = "H";
const std::string CLOSE_MENU_KEY = "H";
const std::string GAMEPAD_OPEN_MENU_KEY = "DpadDown";
const std::string GAMEPAD_CLOSE_MENU_KEY = "B";

/* Navigation menu keys */
const std::string MOVE_MENU_DOWN_KEY = "Down Arrow";
const std::string MOVE_MENU_UP_KEY = "Up Arrow";
const std::string GAMEPAD_MOVE_MENU_DOWN_KEY = "DpadDown";
const std::string GAMEPAD_MOVE_MENU_UP_KEY = "DpadUp";

bool disableControls = false;

std::vector<std::string> optionNames = {
			"Option 1",
			"Option 2",
			"Option 3",
			"Option 4",
			"Option 5",
			"Option 6"
			"Option 7",
			"Option 8",
			"Option 9"
};

void main()
{
	Terminal::Print("Starting");
	Terminal::PrintColoured(Terminal::Color::DARK_AQUA, "Player ID: " + std::to_string(PLAYER::PLAYER_ID()));
	Terminal::PrintColoured(Terminal::Color::DARK_AQUA, "Player Name: " + std::string(PLAYER::GET_PLAYER_NAME_f(PLAYER::PLAYER_ID())));
	Terminal::PrintColoured(Terminal::Color::DARK_AQUA, "Player Ped ID: " + std::to_string(PLAYER::PLAYER_PED_ID()));

	GCTV::Global::Register("Sample.dll_state", "active");
	GCTV::Global::Register("Sample.dll_version", 1.0);

	Terminal::Write("Processing...\r");
	Sleep(500);
	Terminal::Write("Done.\n");

	mainUI();

	while (GCTV::IsScriptsStillWorking())
	{
		if (disableControls)
		{
			PAD::DISABLE_ALL_CONTROL_ACTIONS_f(ePadType::CAMERA_CONTROL); // Disables all camara bindings.
			//PAD::DISABLE_ALL_CONTROL_ACTIONS_f(ePadType::FRONTEND_CONTRO);

			Sleep(0);
		}
		else Sleep(100);
	}

	GCTV::Global::Set("Sample.dll_state", "deactive");

	ShowNotification("Sample", "Bye!");
}



void mainUI()
{
	std::thread([]() {
		bool menuOpened = false;
		auto menuToggleTime = GET_TIME();

		Gamepad gamepad;

		std::string openCloseMenuKey = OPEN_MENU_KEY;
		std::string gamepadOpenCloseMenuKey = GAMEPAD_OPEN_MENU_KEY;

		std::vector<std::vector<Graphics::Rect*>> objects; // Array of all graphical elements of all used. Rect = 0
		objects.resize(1);

		size_t optionCurrentIndex = 0; // Selected option.
		size_t cursorIndex = -1;
			
		// Main graphics loop
		while (GCTV::IsScriptsStillWorking())
		{
			UpdatePresses(gamepad);

			KeyPressed menuTogglePressed = IsPressed(openCloseMenuKey, gamepadOpenCloseMenuKey); // If 'H' key pressed or gamepad key '↓' pressed.
			if (
				menuTogglePressed
				&& 
				std::chrono::duration_cast<std::chrono::milliseconds>(GET_TIME() - menuToggleTime) > std::chrono::milliseconds(2000) // And Time between presses more than 2 second.
			) {
				menuToggleTime = GET_TIME();

				if (menuOpened) {
					openCloseMenuKey = OPEN_MENU_KEY;
					gamepadOpenCloseMenuKey = GAMEPAD_OPEN_MENU_KEY;

					for (auto object : objects[0]) delete object; //Graphics::DeleteElement(object->getID());
					objects[0].clear();
				}
				if (!menuOpened) {
					openCloseMenuKey = CLOSE_MENU_KEY;
					gamepadOpenCloseMenuKey = GAMEPAD_CLOSE_MENU_KEY;

					disableControls = true;

					if (menuTogglePressed == GAMEPAD) {
						gamepad.SendVibration(0.5);
						Sleep(200);
						gamepad.SendVibration(0.0);
					}

					/* Backround rect */
					auto background = new Graphics::Rect(
						UI::Background::Default.pos.x, UI::Background::Default.pos.y, UI::Background::Default.size.width, UI::Background::Default.size.height,
						UI::Background::Default.color.r, UI::Background::Default.color.g, UI::Background::Default.color.b, UI::Background::Default.color.a,
						UI::Background::Default.rounding);
					objects[0].push_back(background);

					/* Option background rects */
					for (size_t i = 0; i < optionNames.size(); ++i)
					{
						// each option's position is shifted down by i * (height + padding)
						int x = UI::Option::Default.pos.x;
						int y = UI::Option::Default.pos.y + int(i * (UI::Option::Default.size.height + UI::Option::spacingY));

						objects[0].push_back(
							new Graphics::Rect(
								x, y, UI::Option::Default.size.width, UI::Option::Default.size.height,
								UI::Option::Default.color.r, UI::Option::Default.color.g, UI::Option::Default.color.b, UI::Option::Default.color.a,
								UI::Option::Default.rounding
							)
						);
					}

					/* Cursor rect */
					int cx = UI::Cursor::Default.pos.x;
					int cy = UI::Cursor::Default.pos.y + int(optionCurrentIndex * (UI::Option::Default.size.height + UI::Option::spacingY));

					objects[0].push_back(
						new Graphics::Rect(
							cx, cy,
							UI::Cursor::Default.size.width, UI::Cursor::Default.size.height,
							UI::Cursor::Default.color.r, UI::Cursor::Default.color.g, UI::Cursor::Default.color.b, UI::Cursor::Default.color.a,
							UI::Cursor::Default.rounding
						)
					);
					cursorIndex = objects[0].size() - 1;
				}
				menuOpened = !menuOpened;
			}

			if (!menuOpened
				&&
				disableControls
				&&
				std::chrono::duration_cast<std::chrono::milliseconds>(GET_TIME() - menuToggleTime) >= std::chrono::microseconds(1000)
			) disableControls = false;

			if (menuOpened)
			{
				if (IsPressed(MOVE_MENU_DOWN_KEY, GAMEPAD_MOVE_MENU_DOWN_KEY))
				{
					if (optionCurrentIndex + 1 < optionNames.size()) ++optionCurrentIndex;
					else optionCurrentIndex = 0;

					int cy = UI::Cursor::Default.pos.y + int(optionCurrentIndex * (UI::Option::Default.size.height + UI::Option::spacingY));

					objects[0][cursorIndex]->SetPosition(UI::Cursor::Default.pos.x, cy);
				}
					
				else if (IsPressed(MOVE_MENU_UP_KEY, GAMEPAD_MOVE_MENU_UP_KEY))
				{
					if (optionCurrentIndex > 0)--optionCurrentIndex;
					else optionCurrentIndex = optionNames.size() - 1;

					int cy = UI::Cursor::Default.pos.y + int(optionCurrentIndex * (UI::Option::Default.size.height + UI::Option::spacingY));

					objects[0][cursorIndex]->SetPosition(UI::Cursor::Default.pos.x, cy);
				}
			}
			
			Sleep(50);
		}
	}).detach();
}

std::vector<std::string> gamepadPressedKeys;

KeyPressed IsPressed(std::string keyboardKey, std::string gamepadKey)
{
	if (GCTV::IsPressedKey(GCTV::ConvertStringToKeyCode(keyboardKey.c_str()))) return KEYBOARD;

	for (std::string key : gamepadPressedKeys) if (gamepadKey == key) return GAMEPAD;

	return NONE;
}

void UpdatePresses(Gamepad& gamepad)
{
	gamepadPressedKeys = gamepad.GetPressedKeys();
}

/*
bool IsPressed(std::string keyboardKey, std::pair<Gamepad&, std::string> gamepadKey)
{
	return
		GCTV::IsPressedKey(GCTV::ConvertStringToKeyCode(keyboardKey.c_str()))	// Return true if keyboard key is pressed.
		||																		// or
		(gamepadKey.first.GetPressedKey() == gamepadKey.second);				// Return true if gamepad key has been pressed.
}
*/