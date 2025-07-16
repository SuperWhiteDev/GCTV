#pragma once
#include <string>

#define EXPORT __declspec(dllexport)

void main();

EXPORT void SetThermalVision(bool Toggle);