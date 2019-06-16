#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: Destroy"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_iItemId = coinsys_shop_register_item("Destroy a Player", "DESTROY THE SERVERRRR", 500, 0, -1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		set_task(0.3, "OpenDestroyMenu", id)
	}
}

public OpenDestroyMenu(id)
{
	if(!is_user_connected(id))
		return

	new iMenu =  menu_create("\rDestroy Player Menu", "DestroyMenuHandler")
	
	new iPlayers[32], iNum
	get_players(iPlayers, iNum)
	for(new i, tid, szName[33]; i < iNum; i++)
	{
		tid = iPlayers[i]
		get_user_name(tid, szName, charsmax(szName))

		menu_additem(iMenu, szName)
	}

	menu_display(id, iMenu)
}

public DestroyMenuHandler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		client_print(0, print_chat, "Phahahahahaha, did you just really ruined your 500 coins xDDD")
		return PLUGIN_HANDLED
	}

	new szName[33]
	get_user_name(id, szName, charsmax(szName))
	client_print(0, print_chat, "PAHAHHAHAHHAHAHAHHA, %s SI POMISLI CHE CHESNO SHE MU DADEME DESTROY, NUUUB", szName)
	
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}