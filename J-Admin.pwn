/*
		Jakwobs Admin System (J-admin)
		
	Features:
	* To set yourself admin use /adminlevel
	* To use any admin commands you will need to be in /duty to prevent abuse.
*/

#include <a_samp>
#include <izcmd>

#define ACMD CMD
#define PCMD CMD
#define SCM SendClientMessage

#define MAX_ADMIN_LEVEL 5

#define COLOR_RED 0xFF0000FF
#define COLOR_ORANGE 0xFF9900AA

enum PlayerInformation
{
	AdminLevel,
	Duty
}
new pInfo[MAX_PLAYERS][PlayerInformation];

public OnPlayerConnect(playerid)
{
    pInfo[playerid][Duty] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    pInfo[playerid][Duty] = 0;
	return 1;
}

ACMD:adminlevel(playerid, params[])  // Set Yourself Admin.
{
	new str[128+MAX_PLAYER_NAME];
	if(!IsPlayerAdmin(playerid)) return SCM(playerid, COLOR_RED, "You can not use this command!");
	if(pInfo[playerid][AdminLevel] == MAX_ADMIN_LEVEL) return SCM(playerid, COLOR_RED, "You are already this level!");
	pInfo[playerid][AdminLevel] = MAX_ADMIN_LEVEL;
	format(str, sizeof str, "You are now admin level %d [Head Admin]", pInfo[playerid][AdminLevel]);
	SCM(playerid, COLOR_ORANGE, str);
	return 1;
}

ACMD:duty(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] == 0) return SCM(playerid, COLOR_RED, "You can not use this command!");
	if(pInfo[playerid][Duty] == 0) // On Duty
	{
		GetPlayerPos(playerid, pInfo[playerid][DutyPosX], pInfo[playerid][DutyPosY], pInfo[playerid][DutyPosZ]);
		SCM(playerid, COLOR_ORANGE, "You are now in duty mode");
		pInfo[playerid][Duty] = 1;
	}
	if(pInfo[playerid][Duty] == 1) // Off Duty
	{
		SetPlayerPos(playerid, pInfo[playerid][DutyPosX], pInfo[playerid][DutyPosY], pInfo[playerid][DutyPosZ]);
		SCM(playerid, COLOR_ORANGE, "You are now out of duty mode");
		pInfo[playerid][Duty] = 0;
	}
	return 1;
}
