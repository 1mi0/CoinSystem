#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <coinsystem>

#define PLUGIN "Coin System: Shop"
#define VERSION "1.0"
#define AUTHOR "mi0"
#define PREFIX "^x03[Coins] ^x01"

//Cmds
new g_szShopCommands[][] =
{
	"/shop",
	"/coinshop"
}

//Forwards
new g_iFwdItemSelected
//Items
enum AliveStates
{
	ALIVE_NO = -1,
	ALIVE_DEAD,
	ALIVE_ALIVE
}
enum _:ItemData
{
	Index,
	Name[33],
	Info[124],
	Cost,
	Limit[33],
	AliveStates:Alive,
	bool:AdminsOnly,
	AdminFlag
}

new Array:g_aItems, g_iItemCount

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterCmds()

	g_aItems = ArrayCreate(ItemData)

	g_iFwdItemSelected = CreateMultiForward("CoinShopItemSelected", ET_STOP, FP_CELL, FP_CELL)

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer__Spawn")
}

public plugin_end()
{
	DestroyForward(g_iFwdItemSelected)
}

RegisterCmds()
{
	for(new i, szCmd[32]; i < sizeof(g_szShopCommands); i++)
	{
		formatex(szCmd, charsmax(szCmd), "say %s", g_szShopCommands[i])
		register_clcmd(szCmd, "CmdShop")
		formatex(szCmd, charsmax(szCmd), "say_team %s", g_szShopCommands[i])
		register_clcmd(szCmd, "CmdShop")
	}
}

public CmdShop(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	OpenShop(id)

	return PLUGIN_HANDLED
}

OpenShop(id)
{
	new szTemp[128], iMenu, iMenuCallback
	formatex(szTemp, charsmax(szTemp), "\rCoins Shop^n\rYour Coins: \w%i", csys_get_user_coins(id))
	iMenu = menu_create(szTemp, "ShopHandler")

	iMenuCallback = menu_makecallback("ShopCallback")

	for(new i, eTempArray[ItemData]; i < g_iItemCount; i++)
	{
		ArrayGetArray(g_aItems, i, eTempArray)

		if(eTempArray[AdminsOnly] && ~get_user_flags(id) & eTempArray[AdminFlag])
			formatex(szTemp, charsmax(szTemp), "\d%s \r[ADMINS ONLY]", eTempArray[Name])
		else if(eTempArray[Alive] != ALIVE_NO && _:eTempArray[Alive] != is_user_alive(id))
			formatex(szTemp, charsmax(szTemp), "\d%s \r[%s ONLY]", eTempArray[Name], eTempArray[Alive] == ALIVE_ALIVE ? "ALIVES" : "DEADS")
		else if(eTempArray[Limit][0] && eTempArray[Limit][id] >= eTempArray[Limit][0])
			formatex(szTemp, charsmax(szTemp), "\d%s \r[Limit Reached]", eTempArray[Name], eTempArray[Cost])
		else if(eTempArray[Limit][0])
			formatex(szTemp, charsmax(szTemp), "%s \r[Cost: %i] [%i/%i]", eTempArray[Name], eTempArray[Cost], eTempArray[Limit][id], eTempArray[Limit][0])
		else
			formatex(szTemp, charsmax(szTemp), "%s \r[Cost: %i]", eTempArray[Name], eTempArray[Cost])

		menu_additem(iMenu, szTemp, .callback = iMenuCallback)
	}

	menu_display(id, iMenu)
}

public ShopCallback(id, iMenu, iItem)
{
	new eTempArray[ItemData]
	ArrayGetArray(g_aItems, iItem, eTempArray)

	if
	(
		(
			eTempArray[AdminsOnly] && 
			~get_user_flags(id) & eTempArray[AdminFlag]
		) || (
			eTempArray[Alive] != ALIVE_NO && 
			_:eTempArray[Alive] != is_user_alive(id)
		) || (
			eTempArray[Limit][0] &&
			eTempArray[Limit][id] >= eTempArray[Limit][0]
		)
	)
		return ITEM_DISABLED
	else
		return ITEM_ENABLED

	return ITEM_IGNORE
}

public ShopHandler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}

	BuyItem(id, iItem)
	OpenShop(id)

	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

BuyItem(id, iItem)
{
	if(!is_user_connected(id))
		return

	new eTempArray[ItemData]
	ArrayGetArray(g_aItems, iItem, eTempArray)

	if(eTempArray[AdminsOnly] && ~get_user_flags(id) & eTempArray[AdminFlag])
	{
		client_print_kolor(id, id, "^x04>> Shop >> ^x01Admins Only Item!!!")
		return
	}

	if(eTempArray[Alive] != ALIVE_NO && _:eTempArray[Alive] != is_user_alive(id))
	{
		client_print_kolor(id, id, "^x04>> Shop >> ^x01You must be ^x03%s^x01 to buy that item!!!", eTempArray[Alive] == ALIVE_ALIVE ? "Alive" : "Dead")
		return
	}

	if(eTempArray[Limit][0] && eTempArray[Limit][id] >= eTempArray[Limit][0])
	{
		client_print_kolor(id, id, "^x04>> Shop >> ^x01You have already used that item Max times!!!")
		return
	}

	new iUserCoins = csys_get_user_coins(id)
	if(iUserCoins < eTempArray[Cost])
	{
		client_print_kolor(id, id, "^x04>> Shop >> ^x01You don't have enough coins!!!")
		return
	}

	GiveItem(id, iItem)

	if(~get_user_flags(id) & ADMIN_RCON)
		csys_set_user_coins(id, iUserCoins - eTempArray[Cost])
}

GiveItem(id, iItem)
{
	new iReturn, eTempArray[ItemData]
	ArrayGetArray(g_aItems, iItem, eTempArray)

	ExecuteForward(g_iFwdItemSelected, iReturn, id, iItem)

	eTempArray[Limit][id]++

	client_print_kolor(id, id, "^x04>> Shop >> ^x01You successfully bought %s!!!", eTempArray[Name])
	client_print_kolor(id, id, "^x04>> Shop >> ^x01INFO: ^x04%s", eTempArray[Info])

	ArraySetArray(g_aItems, iItem, eTempArray)

	return iReturn
}

public plugin_natives()
{
	register_native("coinsys_shop_register_item", "_register_shop_item")
}

public _register_shop_item()
{
	new eTempArray[ItemData]
	eTempArray[Index] = g_iItemCount++
	get_string(1, eTempArray[Name], charsmax(eTempArray[Name]))
	get_string(2, eTempArray[Info], charsmax(eTempArray[Info]))
	eTempArray[Cost] = get_param(3)
	eTempArray[Limit][0] = get_param(4)
	eTempArray[Alive] = get_param(5)
	eTempArray[AdminsOnly] = bool:get_param(6)
	if(eTempArray[AdminsOnly])
		eTempArray[AdminFlag] = get_param(7)

	ArrayPushArray(g_aItems, eTempArray)

	return g_iItemCount - 1
}

client_print_kolor(id, iSender, szMsg[], any:...)
{
	if(!is_user_connected(id))
		return

	new szNewMsg[192]
	vformat(szNewMsg, charsmax(szNewMsg), szMsg, 4)

	#if defined PREFIX
	format(szNewMsg, charsmax(szNewMsg), "%s%s", PREFIX, szNewMsg)
	#endif

	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("SayText"), _, id)
	write_byte(iSender)
	write_string(szNewMsg)
	message_end()
}

public RG_CBasePlayer__Spawn(id)
{
	if(!is_user_connected(id))
		return

	new eTempArray[ItemData]
	for(new i; i < g_iItemCount; i++)
	{
		ArrayGetArray(g_aItems, i, eTempArray)
		eTempArray[Limit][id] = 0
		ArraySetArray(g_aItems, i, eTempArray)
	}
}