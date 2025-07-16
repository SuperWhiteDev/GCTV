#include "Gamepad.hpp"

Gamepad::Gamepad()
{
	id = GCTV::Input::GetNextGamepadObjectId();
}

Gamepad::~Gamepad()
{
}

void Gamepad::SelectController(GCTV::Input::ControllerId controllerId)
{
	GCTV::Input::SelectController(id, controllerId);
}

GCTV::Input::ControllerId Gamepad::GetController() { return static_cast<GCTV::Input::ControllerId>(GCTV::Input::GetSelectedController(id)); }

std::string Gamepad::GetPressedKey()
{
	return GCTV::Input::GetPressedKey(id);
}

std::vector<std::string> Gamepad::GetPressedKeys()
{
	size_t keysCount;
	auto pressedKeys = GCTV::Input::GetPressedKeys(id, &keysCount);

	if (!pressedKeys || keysCount == 0) {
		return {};
	}

	std::vector<std::string> keys(keysCount);

	for (size_t i = 0; i < keysCount; ++i) keys[i] = pressedKeys[i];

	return keys;
}

Gamepad::StickPos Gamepad::GetLeftStickState()
{
	GCTV::Input::StickState state;
	
	if (GCTV::Input::GetLeftStickState(id, &state))
	{
		return { true, state.ThumbX, state.ThumbY };
	}
	else {
		return { false, 0.0, 0.0 };
	}
}

Gamepad::StickPos Gamepad::GetRightStickState()
{
	GCTV::Input::StickState state;

	if (GCTV::Input::GetRightStickState(id, &state))
	{
		return { true, state.ThumbX, state.ThumbY };
	}
	else {
		return { false, 0.0, 0.0 };
	}
}

Gamepad::Triggers Gamepad::GetTriggersState()
{
	GCTV::Input::TriggersState state;

	if (GCTV::Input::GetTriggersState(id, &state))
	{
		return { true, state.LT, state.RT };
	}
	else {
		return { false, 0.0, 0.0 };
	}
}

void Gamepad::SendVibration(float strength, bool useLeftMotor, bool useRightMotor)
{
	GCTV::Input::SendVibration(id, strength, useLeftMotor, useRightMotor);
}