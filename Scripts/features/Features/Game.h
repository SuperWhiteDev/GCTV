#pragma once
#include "NativeFunctions.h"

int ShowNotification(const char* title, const char* text);

void RequestControlOf(Entity entity);

void RegisterAsNetwork(Entity entity);