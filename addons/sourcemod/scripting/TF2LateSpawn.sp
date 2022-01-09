#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf2_stocks>

#define NAME    "[TF2] Late Spawn Control"
#define VERSION "1.0"

bool   g_bCanLateSpawn[MAXPLAYERS+1];
bool   g_bRoundStarted;
float  g_fRoundStartTime;
Handle g_hLateSpawnTimer;

ConVar g_hLateSpawnEnable;
ConVar g_hLateSpawnBlockTime;
ConVar g_hLateSpawnAllowBlue;
ConVar g_hLateSpawnAllowRed;
ConVar g_hBlockLateSpawns;

public Plugin myinfo =
{
	name        = NAME,
	author      = "meng, edited by x07x08",
	version     = VERSION,
	description = "Controls late spawning in TF2",
	url         = ""
};

public void OnPluginStart()
{
	CreateConVar("sm_latespawncontrol_version", VERSION, NAME, FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	g_hLateSpawnEnable    = CreateConVar("sm_latespawn_enabled", "1", "Enable / disable the plugin.", _, true, 0.0, true, 1.0);
	g_hLateSpawnBlockTime = CreateConVar("sm_latespawn_block_time", "10.0", "Time until latespawning is blocked.");
	g_hLateSpawnAllowBlue = CreateConVar("sm_latespawn_allow_blue", "0", "Allow blue team to latespawn?", _, true, 0.0, true, 1.0);
	g_hLateSpawnAllowRed  = CreateConVar("sm_latespawn_allow_red", "1", "Allow red team to latespawn?", _, true, 0.0, true, 1.0);
	g_hBlockLateSpawns    = CreateConVar("sm_latespawn_block", "1", "Block latespawning if the time limit has passed?", _, true, 0.0, true, 1.0);
	
	AddCommandListener(CmdJoinClass, "joinclass");
	AddCommandListener(CmdJoinClass, "join_class");
	
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_win_panel", OnRoundEnd, EventHookMode_PostNoCopy);
}

public void OnClientConnected(int iClient)
{
	g_bCanLateSpawn[iClient] = true;
}

public void OnClientDisconnect(int iClient)
{
	g_bCanLateSpawn[iClient] = false;
}

public Action CmdJoinClass(int iClient, const char[] strCommand, int iArgs)
{
	// https://github.com/Mikusch/arena-latespawn-fix
	
	if (IsClientInGame(iClient))
	{
		if (GetClientTeam(iClient) == 0)
		{
			PrintToChat(iClient, "\x01[\05Latespawn Control\01] You can't select a class unless you choose a team.");
			return Plugin_Handled;
		}
	}
	
	if (g_hLateSpawnEnable.BoolValue && g_bRoundStarted && (iClient >= 1) && (iClient <= MaxClients))
	{
		char strClass[20]; GetCmdArg(1, strClass, sizeof(strClass));
		
		if (GetGameTime() - g_fRoundStartTime < g_hLateSpawnBlockTime.FloatValue)
		{
			if (g_bCanLateSpawn[iClient])
			{
				LateSpawnClient(iClient, strClass);
			}
		}
		else
		{
			if(g_hBlockLateSpawns.BoolValue && GetClientTeam(iClient) > 1 && TF2_GetPlayerClass(iClient) == TFClass_Unknown)
			{
				TFClassType iClass = TF2_GetClass(strClass);
				
				PrintToChat(iClient, "\x01[\05Latespawn Control\01] Late spawn blocked.");
				SetEntProp(iClient, Prop_Send, "m_iDesiredPlayerClass", iClass);
				
				return Plugin_Handled;
			}
		}
		
		g_bCanLateSpawn[iClient] = false;
	}
	
	return Plugin_Continue;
}

public void OnRoundEnd(Event hEvent, const char[] strName, bool bDontBroadcast)
{
	if(g_hLateSpawnTimer != null)
	{
		KillTimer(g_hLateSpawnTimer);
		g_hLateSpawnTimer = null;
	}
	
	g_bRoundStarted = false;
}

public void OnRoundStart(Event hEvent, const char[] strName, bool bDontBroadcast)
{
	if(g_hLateSpawnTimer != null)
	{
		KillTimer(g_hLateSpawnTimer);
		g_hLateSpawnTimer = null;
	}
	
	g_bRoundStarted   = true;
	g_fRoundStartTime = GetGameTime();
	
	if (g_hLateSpawnEnable.BoolValue)
	{
		float fRespawnTime = g_hLateSpawnBlockTime.FloatValue;
		
		if (fRespawnTime > 0.0)
		{
			g_hLateSpawnTimer = CreateTimer(fRespawnTime, TimeUpMessage);
		}
	}
}  

public void OnMapEnd() 
{
	if(g_hLateSpawnTimer != null)
	{
		KillTimer(g_hLateSpawnTimer);
		g_hLateSpawnTimer = null;
	}
	
	g_bRoundStarted = false;
}

public Action TimeUpMessage(Handle hTimer)
{
	g_hLateSpawnTimer = null;
	
	if (g_hLateSpawnEnable.BoolValue && (g_hLateSpawnBlockTime.FloatValue > 0.0))
	{
		PrintToChatAll("\x01[\05Latespawn Control\01] Late spawn time is up!");
	}
	
	return Plugin_Continue;
}

void LateSpawnClient(int iClient, const char[] strClassType)
{
	if (IsClientInGame(iClient) && !IsPlayerAlive(iClient) && !IsFakeClient(iClient))
	{
		TFClassType iClass = TF2_GetClass(strClassType);
		
		if (iClass == TFClass_Unknown)
		{
			SetEntProp(iClient, Prop_Send, "m_iDesiredPlayerClass", TFClass_Scout);
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iDesiredPlayerClass", iClass);
		}
		
		if (GetClientTeam(iClient) == 2)
		{
			if (g_hLateSpawnAllowRed.BoolValue)
			{
				TF2_RespawnPlayer(iClient);
				PrintToChat(iClient, "\x01[\05Latespawn Control\01] You've been late spawned!");
			}
		}
		else if (GetClientTeam(iClient) == 3)
		{
			if (g_hLateSpawnAllowBlue.BoolValue)
			{
				TF2_RespawnPlayer(iClient);
				PrintToChat(iClient, "\x01[\05Latespawn Control\01] You've been late spawned!");
			}
		}
	}
}