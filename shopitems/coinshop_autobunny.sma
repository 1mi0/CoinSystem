#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: AutoBunnyHop"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId, bool:g_bHasItem[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_Killed, "RG__CBasePlayer_Killed")
	RegisterHookChain(RG_CBasePlayer_Jump, "RG__CBasePlayer_Jump")

	g_iItemId = coinsys_shop_register_item("Auto BunnyHop", "Become a rabbit, Jump-Jump", 35, 1, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		g_bHasItem[id] = true
	}
}

public RG__CBasePlayer_Killed(id)
{
	g_bHasItem[id] = false
}

public RG__CBasePlayer_Jump(id) 
{
	if(get_entvar(id, var_flags) & FL_ONGROUND && g_bHasItem[id])
	{
		new Float:fVel[3]
		get_entvar(id, var_velocity, fVel)
		fVel[2] += random_float(265.0, 285.0)
		set_entvar(id, var_velocity, fVel)
		set_entvar(id, var_gaitsequence, 6)
		set_entvar(id, var_frame, 0.0)
	}
}