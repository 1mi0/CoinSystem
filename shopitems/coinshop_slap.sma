#include <amxmodx>
#include <reapi>
#include <csysshop>

#define PLUGIN "Coin Shop: Slap"
#define VERSION "1.0"
#define AUTHOR "mi0"

new g_iItemId

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_iItemId = coinsys_shop_register_item("Slap a Player", "Slap these bi4eZ", 500, 0, -1)
}

public CoinShopItemSelected(id, iItem)
{
	if(iItem == g_iItemId)
	{
		set_task(0.3, "OpenSlapMenu", id)
	}
}

public OpenSlapMenu(id)
{
	if(!is_user_connected(id))
		return

	new iMenu =  menu_create("\rSlap Player Menu", "SlapMenuHandler")
	
	new iPlayers[32], iNum
	get_players(iPlayers, iNum)
	for(new i, tid, szInfo[1], szName[33]; i < iNum; i++)
	{
		tid = iPlayers[i]

		szInfo[0] = tid
		get_user_name(tid, szName, charsmax(szName))

		menu_additem(iMenu, szName, szInfo)
	}

	menu_display(id, iMenu)
}

public SlapMenuHandler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		client_print(0, print_chat, "Phahahahahaha, did you just really ruined your 500 coins xDDD")
		return PLUGIN_HANDLED
	}

	new szInfo[1]
	menu_item_getinfo(iMenu, iItem, iItem, szInfo, 1, _, _, iItem)

	if(!is_user_alive(szInfo[0]))
		client_print(0, print_chat, "Buuuu, He's ded xD")
	else if(get_user_flags(szInfo[0]) & ADMIN_IMMUNITY)
		client_print(0, print_chat, "Nub, you can't slap player with immunity xD")
	else
	{
		new iUserid
		iUserid = get_user_userid(szInfo[0])
		server_cmd("amx_slap #%i", iUserid)
	}
	
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}