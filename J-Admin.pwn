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
	return 1;
}
