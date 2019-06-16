#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: 20 Grens"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId, g_iPlayerGrens[33]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_Killed, "RG__CBasePlayer_Killed")
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG__CBasePlayer_Spawn")

	g_iItemId = coinsys_shop_register_item("20 Grens", "Grenade Hell Storm", 20, 1, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		rg_give_item(id, "weapon_hegrenade")
		rg_set_user_bpammo(id, WEAPON_HEGRENADE, 20)
	}
}

public RG__CBasePlayer_Killed(id)
{
	g_iPlayerGrens[id] = rg_get_user_bpammo(id, WEAPON_HEGRENADE)
}
public RG__CBasePlayer_Spawn(id)
{
	if(g_iPlayerGrens[id] > 1)
		set_task(3.0, "TaskGiveGrens", id)
}

public TaskGiveGrens(id)
{
	rg_set_user_bpammo(id, WEAPON_HEGRENADE, g_iPlayerGrens[id])
}