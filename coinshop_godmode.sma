#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: GodMode"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId, bool:g_bHasItem[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHookChain(RG_CBasePlayer_TraceAttack, "RG__CBasePlayer_TraceAttack")

	g_iItemId = coinsys_shop_register_item("5 Sec GodMode", "No more bleeding", 50, 1, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		g_bHasItem[id] = true
		set_task(5.0, "RemoveGodMode", id)
	}
}

public RemoveGodMode(id)
{
	g_bHasItem[id] = false
}

public RG__CBasePlayer_TraceAttack(id)
{
	if(g_bHasItem[id])
		return HC_SUPERCEDE
	return HC_CONTINUE
}