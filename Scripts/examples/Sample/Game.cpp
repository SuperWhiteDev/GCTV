#include "Game.h"
#include "scrNativeHandler.h"

int ShowNotification(const char* title, const char* text)
{
	HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("STRING");
	HUD::ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text);
	HUD::END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT_WITH_CREW_TAG_AND_ADDITIONAL_ICON("CHAR_SOCIAL_CLUB", "CHAR_SOCIAL_CLUB", 1, 7, title, "", 1, "", false, true);
	HUD::END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false);
	return 0;
}

void RequestControlOf(Entity entity)
{
	NETWORK::NETWORK_REQUEST_CONTROL_OF_ENTITY(entity);
	int iters = 0;
	while (iters <= 50)
	{
		if (NETWORK::NETWORK_HAS_CONTROL_OF_ENTITY(entity)) return;

		NETWORK::NETWORK_REQUEST_CONTROL_OF_ENTITY(entity);
		++iters;
	}
}

void RegisterAsNetwork(Entity entity)
{
	NETWORK::NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity);
	Sleep(1);
	RequestControlOf(entity);
	NetID netid = NETWORK::NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity);
	NETWORK::SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netid, 1);
}