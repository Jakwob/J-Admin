/*
		Jakwobs Admin System (J-admin)
		
	Features:
	* To set yourself admin use /adminlevel
	* To use any admin commands you will need to be in /duty to prevent abuse.
*/

#include <a_samp>
#include <izcmd>
#include <sscanf2>

#define ACMD CMD
#define PCMD CMD
#define SCM SendClientMessage

#define MAX_ADMIN_LEVEL 5

#define COLOR_RED 0xFF0000FF
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_YELLOW 0xFFFF00AA

enum PlayerInformation
{
	Color,
	AdminLevel,
	Duty,
	AMessages,
	Float:DutyPosX,
	Float:DutyPosY,
	Float:DutyPosZ,
}
new pInfo[MAX_PLAYERS][PlayerInformation];
new PlayerText:DutyTD[MAX_PLAYERS];

public OnPlayerConnect(playerid)
{
    pInfo[playerid][Duty] = 0;
    pInfo[playerid][AMessages] = 0;
    SetPlayerColor(playerid, COLOR_GREY);
    
    // Textdraws
    DutyTD[playerid] = CreatePlayerTextDraw(playerid,580.000000, 100.000000, "Off Duty");
	PlayerTextDrawAlignment(playerid,DutyTD[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,DutyTD[playerid], 255);
	PlayerTextDrawFont(playerid,DutyTD[playerid], 1);
	PlayerTextDrawLetterSize(playerid,DutyTD[playerid], 0.370000, 1.200000);
	PlayerTextDrawColor(playerid,DutyTD[playerid], 16711935);
	PlayerTextDrawSetOutline(playerid,DutyTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid,DutyTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid,DutyTD[playerid], 0);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    pInfo[playerid][Duty] = 0;
    PlayerTextDrawDestroy(playerid, DutyTD[playerid]);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(pInfo[playerid][AdminLevel] > 0)
	{
    	PlayerTextDrawShow(playerid, DutyTD[playerid]);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(pInfo[playerid][AdminLevel] > 0)
	{
    	PlayerTextDrawHide(playerid, DutyTD[playerid]);
	}
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
		pInfo[playerid][Color] = GetPlayerColor(playerid);
		PlayerTextDrawSetString(playerid, DutyTD[playerid], "On Duty");
  		for(new i = 0; i < MAX_PLAYERS; i++)
  		{
  		    SetPlayerMarkerForPlayer(i, playerid, (GetPlayerColor(playerid) & 0xFFFFFF00));
    		ShowPlayerNameTagForPlayer(playerid, i, false);
  		}
		pInfo[playerid][Duty] = 1;
		new astr[128+MAX_PLAYER_NAME];
		format(astr, sizeof astr, "[CMD] %s used /duty", GetName(playerid));
		SendToAdmins(astr);
	}
	else // Off Duty
	{
		SetPlayerPos(playerid, pInfo[playerid][DutyPosX], pInfo[playerid][DutyPosY], pInfo[playerid][DutyPosZ]);
		PlayerTextDrawSetString(playerid, DutyTD[playerid], "Off Duty");
		for(new i = 0; i < MAX_PLAYERS; i++)
  		{
  		    SetPlayerMarkerForPlayer(i, playerid, pInfo[playerid][Color]);
    		ShowPlayerNameTagForPlayer(playerid, i, true);
  		}
		pInfo[playerid][Duty] = 0;
		new astr[128+MAX_PLAYER_NAME];
		format(astr, sizeof astr, "[CMD] %s used /duty", GetName(playerid));
		SendToAdmins(astr);
	}
	return 1;
}

ACMD:goto(playerid, params[])
{
	new Reason, ID, str[128+MAX_PLAYER_NAME];
	new Float:x, Float:y, Float:z;
	if(pInfo[playerid][AdminLevel] > 0) return SCM(playerid, COLOR_RED, "You can not use this command!");
	if(pInfo[playerid][Duty] == 0) return SCM(playerid, COLOR_RED, "You need to be on duty to use this command!");
	if(sscanf(params, "us", ID, Reason)) return SCM(playerid, COLOR_ORANGE, "Usage: /goto <ID> <Reason>");
	if(ID == playerid) return SCM(playerid, COLOR_RED, "You can not teleport to yourself!");
	if(pInfo[ID][AdminLevel] > 0 && pInfo[ID][Duty] == 0) return SCM(playerid, COLOR_RED, "You can not teleport to an admin that is off duty!");
	GetPlayerPos(ID, x, y, z);
	SetPlayerPos(playerid, x, y, z);
	format(str, sizeof str, "Admin %s has teleported to you.", GetName(playerid));
	SCM(ID, COLOR_ORANGE, str);
	format(str, sizeof str, "You have teleported to %s.", GetName(ID));
	SCM(playerid, COLOR_ORANGE, str);
	new astr[128+MAX_PLAYER_NAME];
	format(astr, sizeof astr, "[CMD] %s used /goto and teleported to %s. Reason %s", GetName(playerid), GetName(ID), Reason);
	SendToAdmins(astr);
	return 1;
}

ACMD:amsgs(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid, COLOR_RED, "You can not use this command!");
	if(pInfo[playerid][AMessages] == 0)
	{
	    pInfo[playerid][AMessages] = 1;
	    SCM(playerid, COLOR_ORANGE, "You have enabled admin messages");
	 	new astr[128+MAX_PLAYER_NAME];
		format(astr, sizeof astr, "[CMD] %s used /amsgs to enable their admin messages", GetName(playerid));
		SendToAdmins(astr);
	}
	else
	{
	    pInfo[playerid][AMessages] = 0;
	    SCM(playerid, COLOR_ORANGE, "You have disabled admin messages");
 		new astr[128+MAX_PLAYER_NAME];
		format(astr, sizeof astr, "[CMD] %s used /amsgs to disable their admin messages", GetName(playerid));
		SendToAdmins(astr);
	}
	return 1;
}

SendToAdmins(message[])
{
    new string[128];
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
    	if(pInfo[i][AdminLevel] == MAX_ADMIN_LEVEL)
     	{
     	    if(pInfo[i][AMessages] == 1)
     	    {
        		SCM(i,COLOR_YELLOW,message);
			}
    	}
	}
    return 0;
}

GetName(playerid)
{
    new szName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, szName, sizeof(szName));
    return szName;
}
