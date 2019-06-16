#include <amxmodx>
#include <reapi>
#include <coinsystem>

#define PLUGIN "Coin System: Money"
#define VERSION "1.0"
#define AUTHOR "SmirnoffBG"

new g_iEntId

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_AddAccount, "RG__CBasePlayer_AddAccount")

	g_iEntId = rg_create_entity("info_target")
	set_entvar(g_iEntId, var_classname, "UpdateCoinsTask")
	set_entvar(g_iEntId, var_nextthink, get_gametime() + 5.0)
	SetThink(g_iEntId, "EntityThink")
}

public RG__CBasePlayer_AddAccount(id, iAmount, RewardType:iRewType)
{
	if(iRewType != RT_NONE)
	{
		return HC_SUPERCEDE
	}
	return HC_CONTINUE
}

public EntityThink(id)
{
	new iPlayers[32], iPlayersNum
	get_players(iPlayers, iPlayersNum)

	for(new i, tid; i < iPlayersNum; i++)
	{
		tid = iPlayers[i]

		if(!is_user_alive(tid))
		{
			continue
		}

		rg_add_account(tid, csys_get_user_coins(tid), AS_SET)
	}

	set_entvar(id, var_nextthink, get_gametime() + 1.0)
}