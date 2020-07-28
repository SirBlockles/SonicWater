/*
	Sonic Water
	
	Makes water behave as it does in the Sonic The Hedgehog games.
	That's about it. Specific timing based off Sonic 2 for genesis.
	
	Uncomment sm_sonic registry and manualCmd() to allow sm_sonic to manually hook the caller.
	Only useful for reloading the plugin in a development environment.
*/

#pragma semicolon 1

#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <sdkhooks>

bool plyUnderwater[MAXPLAYERS + 1];
int plyBreath[MAXPLAYERS + 1];
bool plyTiming[MAXPLAYERS + 1];
Handle plyTimers[MAXPLAYERS + 1];

public Plugin myinfo =  {
	name = "Sonic Water",
	author = "muddy",
	description = "Recreates the sonic water and drowning system",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnClientPutInServer(int ply) {
	SDKHook(ply, SDKHook_PreThink, thinkHook);
	plyUnderwater[ply] = false;
	plyBreath[ply] = -1;
}

public void OnPluginStart() {
	//RegConsoleCmd("sm_sonic", manualCmd, "manually initiate sonic water, for when plugin is reloaded");
	HookEvent("teamplay_round_start", roundStart);
	HookEvent("post_inventory_application", resupEvent);
}

public void OnMapStart() {
	PrecacheSound("sonicwater/splash.wav");
	PrecacheSound("sonicwater/timer.wav");
	PrecacheSound("sonicwater/drowning.wav");
	PrecacheSound("sonicwater/drowned.wav");
	PrecacheSound("sonicwater/breathe.wav");
	for(int i = 0; i > MAXPLAYERS; i++) {
		if(plyTimers[i] != INVALID_HANDLE) { CloseHandle(plyTimers[i]); }
	}
}

//where the magic happens
public void thinkHook(int ply) {
	int curWaterLvl = GetEntProp(ply, Prop_Send, "m_nWaterLevel");
	
	if(curWaterLvl == 3)
	
	//if we're at water level 1 or 2, do nothing. this lets us swim at the surface, as well as exit when we've surfaced.
	//unless we're blast jumping, so you can jump out of water without snagging yourself against the surface.
	if(curWaterLvl >= 3) {
		SetEntProp(ply, Prop_Send, "m_nWaterLevel", 0);
		
		//block crouching since crouch-jumping underwater makes things way fucky
		SetEntProp(ply, Prop_Send, "m_bDucking", 0);
		
		//submerging, as opposed to having been in water already
		if(!plyUnderwater[ply]) {
			plyUnderwater[ply] = true;
			plyBreath[ply] = 30;
			SetEntityGravity(ply, 0.3);
			EmitSoundToAll("sonicwater/splash.wav", ply, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
		}
	}
	
	if(curWaterLvl < 3 && plyUnderwater[ply]) {
		if(IsPlayerAlive(ply)) {
			EmitSoundToAll("sonicwater/splash.wav", ply, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
		}
		StopSound(ply, SNDCHAN_ITEM, "sonicwater/drowning.wav");
		SetEntityGravity(ply, 1.0);
		plyUnderwater[ply] = false;
		plyTiming[ply] = false;
		plyBreath[ply] = -1;
		if(plyTimers[ply] != INVALID_HANDLE) { CloseHandle(plyTimers[ply]); }
	}
	
	if(!plyTiming[ply] && curWaterLvl != 0) {
		plyTimers[ply] = CreateTimer(1.0, breathCountdown, ply);
		plyTiming[ply] = true;
	}
}

public Action breathCountdown(Handle timer, int ply) {
	if(plyBreath[ply] < 0 || !IsClientInGame(ply)) { plyTiming[ply] = false; return Plugin_Stop; }
	plyBreath[ply]--;
	if(plyBreath[ply] > 12 && plyBreath[ply] % 5 == 0) {
		EmitSoundToClient(ply, "sonicwater/timer.wav", ply, SNDCHAN_ITEM, SNDLEVEL_NORMAL);
	}
	plyTiming[ply] = false;
	
	if(plyBreath[ply] == 12) {
		EmitSoundToClient(ply, "sonicwater/drowning.wav", ply, SNDCHAN_ITEM, SNDLEVEL_NORMAL);
	}
	
	if(plyBreath[ply] == 0) {
		SDKHooks_TakeDamage(ply, 0, 0, 9999999999999999.0);
		EmitSoundToAll("sonicwater/drowned.wav", ply, SNDCHAN_ITEM, SNDLEVEL_NORMAL);
	}
	
	return Plugin_Stop;
}

public void roundStart(Handle event, const char[] name, bool dontBroadcast) {
	int ply = GetClientOfUserId(GetEventInt(event, "userid"));
	if(plyUnderwater[ply]) {
		plyBreath[ply] = -1;
		plyTiming[ply] = false;
		plyUnderwater[ply] = false;
	}
}

public void resupEvent(Handle event, const char[] name, bool dontBroadcast) {
	int ply = GetClientOfUserId(GetEventInt(event, "userid"));
	if(plyUnderwater[ply]) {
		plyBreath[ply] = 30;
		plyTiming[ply] = false;
		//plyUnderwater[ply] = false;
		if(plyTimers[ply] != INVALID_HANDLE) { CloseHandle(plyTimers[ply]); }
		StopSound(ply, SNDCHAN_ITEM, "sonicwater/drowning.wav");
		EmitSoundToAll("sonicwater/breathe.wav", ply, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	}
}

/*
public Action manualCmd(int ply, int args) {
	SDKHook(ply, SDKHook_PreThink, thinkHook);
	plyUnderwater[ply] = false;
	plyBreath[ply] = -1;
	plyTiming[ply] = false;
	PrintToChat(ply, "called manual SDK hook");
	return Plugin_Handled;
}
*/