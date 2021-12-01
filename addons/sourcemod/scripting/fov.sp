#include <sourcemod>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "FOV", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

Cookie fov = null;

ConVar max = null, min = null;

#define LoopClients(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsValidClient(%1))

public void OnPluginStart()
{
	RegConsoleCmd("sm_fov", Command_Fov, "");
	
	RegConsoleCmd("sm_fov0", Command_FovReset, "");
	RegConsoleCmd("sm_resetfov", Command_FovReset, "");
	RegConsoleCmd("sm_fovreset", Command_FovReset, "");
	
	fov = new Cookie("dex-fov", "", CookieAccess_Protected);
	
	HookEvent("player_spawn", OnClientSpawn);
	
	max = CreateConVar("sm_fov_max_value", "120", "Max fov değeri", 0, true, 91.0, true, 360.0);
	min = CreateConVar("sm_fov_min_value", "20", "Min fov değeri", 0, true, 0.0, true, 89.0);
	AutoExecConfig(true, "Fov", "ByDexter");
	
	LoopClients(i)
	{
		OnClientPostAdminCheck(i);
	}
}

public void OnClientPostAdminCheck(int client)
{
	char sBuffer[8];
	fov.Get(client, sBuffer, 8);
	if (strcmp(sBuffer, "") == 0 || strcmp(sBuffer, " ") == 0)
	{
		fov.Set(client, "90");
	}
	else
	{
		GiveFov(client, StringToInt(sBuffer));
	}
}

public Action OnClientSpawn(Event event, const char[] name, bool dB)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client))
	{
		char sBuffer[8];
		fov.Get(client, sBuffer, 8);
		GiveFov(client, StringToInt(sBuffer));
	}
}

public Action Command_Fov(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_fov <%d-%d>", min.IntValue, max.IntValue);
		return Plugin_Handled;
	}
	
	char arg[8];
	GetCmdArg(1, arg, 8);
	int argfov = StringToInt(arg);
	if (argfov > max.IntValue || argfov < min.IntValue)
	{
		ReplyToCommand(client, "[SM] Usage: sm_fov <%d-%d>", min.IntValue, max.IntValue);
		return Plugin_Handled;
	}
	
	fov.Set(client, arg);
	GiveFov(client, argfov);
	return Plugin_Handled;
}

public Action Command_FovReset(int client, int args)
{
	if (args != 0)
	{
		ReplyToCommand(client, "[SM] Usage: sm_resetfov");
		return Plugin_Handled;
	}
	
	fov.Set(client, "90");
	ResetFov(client);
	return Plugin_Handled;
}

void GiveFov(int client, int clientfov)
{
	SetEntProp(client, Prop_Send, "m_iFOV", clientfov);
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", clientfov);
}

void ResetFov(int client)
{
	SetEntProp(client, Prop_Send, "m_iFOV", 90);
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
}

bool IsValidClient(int client, bool nobots = true)
{
	return client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsClientSourceTV(client) && IsClientConnected(client) && (nobots && !IsFakeClient(client));
} 