#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: Health"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_iItemId = coinsys_shop_register_item("+100 Helath", "Drink a Health potion", 20, 1, 1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		new Float:fHealth
		get_entvar(id, var_health, fHealth)
		set_entvar(id, var_health, fHealth + 100.0)
	}
}