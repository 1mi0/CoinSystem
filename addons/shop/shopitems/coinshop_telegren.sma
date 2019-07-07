#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: TeleGren"
#define VERSION "1.0"
#define AUTHOR "SmirnoffBG & mi0"

new g_iItemId, g_iHasItem[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_Killed, "RG__CBasePlayer_Killed")
	RegisterHookChain(RG_CGrenade_ExplodeSmokeGrenade, "RG__CGrenade_ExplodeSmoke")
	RegisterHookChain(RG_CBasePlayer_ThrowGrenade, "RG__CBasePlayer_ThrowGrenade")

	g_iItemId = coinsys_shop_register_item("Teleport Granade", "Your smoke granade is now a blink device", 25, 3, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		if(!g_iHasItem[id])
			rg_give_item(id, "weapon_smokegrenade")
		g_iHasItem[id]++
	}
}

public RG__CBasePlayer_ThrowGrenade(id, iEnt)
{
	if(!g_iHasItem[id]) 
		return HC_CONTINUE

	new szClass[32]
	get_entvar(iEnt, var_classname, szClass)

	if(!equal(szClass, "weapon_smoke"))
		return HC_CONTINUE
	
	new Float:fMin[3], Float:fMax[3], Float:fOrigin[3]
	
	fMin[0] = -16.0
	fMin[1] = -16.0
	fMin[2] = -36.0
	fMax[0] = 16.0
	fMax[1] = 16.0
	fMax[2] = 32.0
	get_entvar(id, var_origin, fOrigin)

	set_entvar(iEnt, var_mins, fMin)
	set_entvar(iEnt, var_maxs, fMax)
	set_entvar(iEnt, var_solid, SOLID_BBOX)
	set_entvar(iEnt, var_origin, fOrigin)

	SetTouch(iEnt, "GrenTouch")
}

public GrenTouch(iEnt, iTouchedSurf)
{	
	new id = get_entvar(iEnt, var_owner)
	
	if(id == iTouchedSurf)
	{
		set_entvar(iEnt, var_flags, get_entvar(id, var_flags) | FL_KILLME)
		return
	}

	TeleportUser(id, iEnt)
	SetTouch(iEnt, "")

	return
}

public RG__CGrenade_ExplodeSmoke(iEnt)
{
	new id = get_entvar(iEnt, var_owner)

	if(g_iHasItem[id])
		TeleportUser(id, iEnt)

	return HC_SUPERCEDE
}

TeleportUser(id, iEnt)
{
	if(is_user_alive(id))
	{
		new Float:iOrigin[3]
		get_entvar(iEnt, var_origin, iOrigin)
		set_entvar(id, var_origin, iOrigin)
	}

	g_iHasItem[id]--

	if(g_iHasItem[id] > 0)
		set_task(0.3, "TaskGiveGren", id)

	set_entvar(iEnt, var_flags, get_entvar(id, var_flags) | FL_KILLME)
}

public TaskGiveGren(id)
{
	if(is_user_alive(id))
		rg_give_item(id, "weapon_smokegrenade")
}

public RG__CBasePlayer_Killed(id)
{
	g_iHasItem[id] = 0
}