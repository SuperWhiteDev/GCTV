#pragma once
#include "Functions.hpp"

class Gamepad
{
public:
	struct StickPos
	{
		bool active;
		float x, y;
	};
	struct Triggers
	{
		bool active;
		float LT, RT;
	};

	Gamepad();
	~Gamepad();

	void SelectController(GCTV::Input::ControllerId id);

	GCTV::Input::ControllerId GetController();

	std::string GetPressedKey();

	std::vector<std::string> GetPressedKeys();

	StickPos GetLeftStickState();

	StickPos GetRightStickState();

	Triggers GetTriggersState();

	void SendVibration(float strength, bool useLeftMotor = true, bool useRightMotor = true);
private:
	int id;
};
