#include <amxmodx>
#include <reapi>
#include <hamsandwich>
#include <csysshop>

#define PLUGIN "Coin Shop: Speed"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId, Float:g_iPlayerSpeed[33]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG__CBasePlayer_Spawn")
	register_event("CurWeapon", "OnKnifeSelect", "be", "1=1", "2=29")

	g_iItemId = coinsys_shop_register_item("+50% Speed", "Speedy Gonzalez", 20, 1, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		g_iPlayerSpeed[id] = get_entvar(id, var_maxspeed)
		g_iPlayerSpeed[id] *= 1.5
		set_entvar(id, var_maxspeed, g_iPlayerSpeed[id])
	}
}

public RG__CBasePlayer_Spawn(id)
{
	g_iPlayerSpeed[id] = 0.0
}

public OnKnifeSelect(id)
{
	if(g_iPlayerSpeed[id] > 0.0)
    	set_entvar(id, var_maxspeed, g_iPlayerSpeed[id])
}
