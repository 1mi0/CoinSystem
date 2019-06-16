#include <amxmodx>
#include <reapi>
#include <csx>
#include <csysshop>

#define PLUGIN "Coin Shop: PunchGren"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId, g_iHasItem[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG__CBasePlayer_TakeDamage")
	RegisterHookChain(RG_CGrenade_ExplodeHeGrenade, "RG__CGrenade_ExplodeHeGrenade")

	g_iItemId = coinsys_shop_register_item("Punch Granade", "Punch your enemies(no fists used)", 25, 3, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		if(!g_iHasItem[id])
			rg_give_item(id, "weapon_hegrenade")
		g_iHasItem[id]++
	}
}

public RG__CBasePlayer_TakeDamage(iVictim, iInflictor, iAttacker, Float:fDmg)
{
	if(!is_user_alive(iVictim) || !is_user_alive(iAttacker))
		return HC_CONTINUE

	new szInflictorClass[32]
	get_entvar(iInflictor, var_classname, szInflictorClass)

	if(!equal(szInflictorClass, "weapon_hegrenade") ||  !g_iHasItem[iAttacker])
		return HC_CONTINUE

	new Float:fOrigin[3]
	get_entvar(iInflictor, var_origin, fOrigin)
	PunchUser(iVictim, fOrigin, 7.0 * fDmg)

	return HC_CONTINUE
}

public RG__CGrenade_ExplodeHeGrenade(iEnt)
{
	new id = get_entvar(iEnt, var_owner)

	if(g_iHasItem[id])
	{
		set_task(0.1, "RemoveGren", id)
	}
}

public RemoveGren(id)
{
	g_iHasItem[id]--
	if(g_iHasItem[id] > 0 && is_user_alive(id))
		rg_give_item(id, "weapon_hegrenade")
}

PunchUser(iEnt, Float:fOrigin[3], Float:fSpeed)
{
	new Float:fVelocity[3], Float:fEntOrigin[3], Float:fDistance[3], Float:fTime

	get_entvar(iEnt, var_origin, fEntOrigin)
	fEntOrigin[2] += 30.0
	
	fDistance[0] = fEntOrigin[0] - fOrigin[0]
	fDistance[1] = fEntOrigin[1] - fOrigin[1]
	fDistance[2] = fEntOrigin[2] - fOrigin[2]
	
	fTime = vector_distance(fEntOrigin, fOrigin) / fSpeed
	
	fVelocity[0] = fDistance[0] / fTime
	fVelocity[1] = fDistance[1] / fTime
	fVelocity[2] = fDistance[2] / fTime

	set_entvar(iEnt, var_velocity, fVelocity)
}

public RG__CBasePlayer_Killed(id)
{
	g_iHasItem[id] = 0
}