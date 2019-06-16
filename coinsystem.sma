#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <coinsys_sql>
//test
#define PLUGIN "Coin System: Main"
#define VERSION "0.1.6"
#define AUTHOR "SmirnoffBG & mi0"
#define MODEL "models/mario_coin.mdl"
#define ADMIN_VIPA ADMIN_LEVEL_A
#define COINSNUM 1561
#define PREFIX "^x03[Coins] ^x01"

#define GOLDENS


#if defined GOLDENS
native gold_has(id, wepid = 0)
new g_iGoldSpam[33]
#endif

/*#if defined client_disconnected
	#define client_disconnect client_disconnected
#endif*/

new g_iModel, g_iDropMenu, g_iMenuto, g_iSpamCvar

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	CreateMenus()

	register_clcmd("say /coins", "CmdMenu")
	register_clcmd("amx_coinwtd", "cmdWTD")
	register_clcmd("amx_coindep", "cmdDep")
	register_clcmd("amx_coindon", "cmdDon")
	register_clcmd("amx_coingive", "cmdGive")
	register_clcmd("say /reg", "cmdReg")
	register_clcmd("amx_coinpass", "cmdSetPass")

	g_iSpamCvar = register_cvar("coins_spam", "1")
	
	RegisterHam(Ham_Killed, "player", "Ham_Pogrebal", 1)
	RegisterHam(Ham_Touch, "info_target", "Ham_Dokosvaneto")
	RegisterHam(Ham_Think, "info_target", "Ham_IvanskoMislene")
	RegisterHam(Ham_Spawn, "player", "Ham_Rajdane", 1)

	set_task(1.0, "MySql_Init")
}

////////////////////////////////////////////////////////////
// 					    Debug Stuff    					  //
////////////////////////////////////////////////////////////
public cmdGive(id)
{
	if (equal(g_eUserInfo[id][Name], "SmirnoffBG") || equal(g_eUserInfo[id][Name], "mi0"))
		g_eUserInfo[id][Coins] += 500
	else if (equal(g_eUserInfo[id][Name], "*3aEk*King*"))
		client_print(0, print_chat, "BOJKO GEQ OPITA DA IZMAMI SISTEMATA MA NE MU SE POLUCHI!!!")
}

////////////////////////////////////////////////////////////
// 					  Some Connecions  					  //
////////////////////////////////////////////////////////////
public plugin_precache()
{
	g_iModel = precache_model(MODEL)
}

public plugin_end()
{
	if(g_iSqlTuple != Empty_Handle)
		SQL_FreeHandle(g_iSqlTuple)
}

public client_authorized(id)
{
	get_user_name(id, g_eUserInfo[id][Name], charsmax(g_eUserInfo[][Name]))
	set_task(2.5, "check_user", id)
	g_eUserInfo[id][FirstSpawn] = true
}

public check_user(id)
{
	CheckUser(id)
}

public client_disconnect(id)
{
	if(!SaveCoins(g_eUserInfo[id][SaveInfo], g_eUserInfo[id][Coins], 0))
		log_amx("[COIN SYSTEM] ERROR: User - %s, Coins - %i", g_eUserInfo[id][SaveInfo], g_eUserInfo[id][Coins])
	g_eUserInfo[id][Coins] = 0
}

public client_infochanged(id)
{
	if (!is_user_connected(id))
		return
	
	new szName[32], szNewName[32]
	get_user_name(id, szName, charsmax(szName))
	get_user_info(id, "name", szNewName, charsmax(szNewName))
	
	if (!equal(szName, szNewName))
	{
		SaveCoins(g_eUserInfo[id][SaveInfo], g_eUserInfo[id][Coins], 0)
		g_eUserInfo[id][Coins] = 0
		copy(g_eUserInfo[id][Name], charsmax(g_eUserInfo[][Name]), szNewName)
		CheckUser(id)
	}
}

////////////////////////////////////////////////////////////
// 					       MENUS    					  //
////////////////////////////////////////////////////////////

CreateMenus()
{
	g_iDropMenu = menu_create("\rChoose \yamount^n\yCoins in Pocket:", "DropAmount")
	new iItemCallBack = menu_makecallback("DropCallb")
	
	menu_additem(g_iDropMenu, "1 coin", .callback = iItemCallBack)
	menu_additem(g_iDropMenu, "5 coin", .callback = iItemCallBack)
	menu_additem(g_iDropMenu, "10 coin", .callback = iItemCallBack)
	menu_additem(g_iDropMenu, "15 coin", .callback = iItemCallBack)
	menu_additem(g_iDropMenu, "20 coin", .callback = iItemCallBack)
	menu_additem(g_iDropMenu, "25 coin", .callback = iItemCallBack)
	
	g_iMenuto = menu_create("Coins Menu^nCoins in Pocket:", "Menu_Hfa6ta4")
	
	menu_additem(g_iMenuto, "Shop / Magazin")
	#if defined GOLDENS
	menu_additem(g_iMenuto, "Gold Weps / Zlatni uryjiq")
	#endif
	menu_additem(g_iMenuto, "View Vault / Vij v Seifa")
	menu_additem(g_iMenuto, "Witdraw Coins / Izteglene Pari")
	menu_additem(g_iMenuto, "Deposit Coins / Depozirai Pari")
	menu_additem(g_iMenuto, "Donate / Podari Monetka")
	menu_additem(g_iMenuto, "Drop Coin / Metni Monetka")
	menu_additem(g_iMenuto, "Dice(You can win 100 coins) / Hazard")
	menu_additem(g_iMenuto, "Help yourself / POMOSHT")
}

public DropCallb(id, menu, item)
{
	return g_eUserInfo[id][Coins] >= max(item * 5, 1) ? ITEM_ENABLED : ITEM_DISABLED
}

////////////////////////////////////////////////////////////
// 					         CMDS			    		  //
////////////////////////////////////////////////////////////
//CmdMenu
public CmdMenu(id)
{
	if (!is_user_connected(id) || !CheckLogged(id))
		return PLUGIN_HANDLED

	new szHeader[50]
	formatex(szHeader, charsmax(szHeader), "\yCoins \rMenu^n\yCoins in Pocket: %d", g_eUserInfo[id][Coins])
	
	menu_setprop(g_iMenuto, MPROP_TITLE, szHeader)
	menu_display(id, g_iMenuto)

	return PLUGIN_HANDLED
}

public Menu_Hfa6ta4(id, iMenu, iItem)
{
	switch(iItem)
	{
		case 0: client_cmd(id, "say /shop")
		#if defined GOLDENS
		case 1: client_cmd(id, "say /gold")
		case 2:
		{
			if(CheckTimer(id))
				client_print_kolor(id, id, "^x04>> Vault >> ^x01You have ^x03%i^x01 Coins!", Get_Coins_From_Bank(g_eUserInfo[id][SaveInfo]))
			CmdMenu(id)
		}
		case 3: client_cmd(id, "messagemode amx_coinwtd")
		case 4: client_cmd(id, "messagemode amx_coindep")
		case 5: Menu_Donate(id)
		case 6: Drop_Coin(id)
		case 7: Dice(id)
		case 8: Prebori_demenciqta(id)
		#else
		case 1:
		{
			if(CheckTimer(id))
				client_print_kolor(id, id, "^x04>> Vault >> ^x01You have ^x03%i^x01 Coins!", Get_Coins_From_Bank(g_eUserInfo[id][SaveInfo]))
			CmdMenu(id)
		}
		case 2: client_cmd(id, "messagemode amx_coinwtd")
		case 3: client_cmd(id, "messagemode amx_coindep")
		case 4: Menu_Donate(id)
		case 5: Drop_Coin(id)
		case 6: Dice(id)
		case 7: Prebori_demenciqta(id)
		#endif
	}
}

//Donate
public cmdDon(id)
{
	new iTarget = g_eUserInfo[id][DonateID]
	if (!iTarget || !is_user_connected(iTarget))
	{
		Menu_Donate(id)
		return PLUGIN_HANDLED
	}
	g_eUserInfo[id][DonateID] = 0

	new szOutput[20]
	read_argv(1, szOutput, charsmax(szOutput))

	new iSum = str_to_num(szOutput)

	if (iSum < 0)
		iSum *= -1

	if (iSum > g_eUserInfo[id][Coins])
		iSum = g_eUserInfo[id][Coins]

	g_eUserInfo[iTarget][Coins] += iSum
	g_eUserInfo[id][Coins] -= iSum

	client_print_kolor(id, id, "You successfully donated %i coins to %s!", iSum, g_eUserInfo[iTarget][Name])
	client_print_kolor(iTarget, iTarget, "You recieved %i coins from %s!", iSum, g_eUserInfo[id][Name])

	return PLUGIN_HANDLED
}

Menu_Donate(id)
{
	new iDonMenu =  menu_create("Players", "hndlDonate")
	
	new iPL[32], iNum
	get_players(iPL, iNum)
	for(new i, tid, szInfo[1]; i < iNum; i++)
	{
		tid = iPL[i]
		szInfo[0] = tid
		menu_additem(iDonMenu, g_eUserInfo[tid][Name], szInfo)
	}
	menu_display(id, iDonMenu)
}

public hndlDonate(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new szInfo[1]
	menu_item_getinfo(menu, item, item, szInfo, 1, _, _, item)

	if(!is_user_connected(szInfo[0]))
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	g_eUserInfo[id][DonateID] = szInfo[0]
	client_print_kolor(id, print_chat, "Type the amount you want to donate!")
	client_cmd(id, "messagemode amx_coindon")
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

//Withdraw
public cmdWTD(id)
{
	if (!is_user_connected(id) || !CheckTimer(id) || !CheckLogged(id))
		return PLUGIN_HANDLED
		
	new szOutput[20]
	read_argv(1, szOutput, charsmax(szOutput))
	
	new iSum = abs(str_to_num(szOutput))

	if (iSum <= 0)
	{
		client_print_kolor(id, id, "Try with bigger amount.")
		return PLUGIN_HANDLED
	}

	if (SaveCoins(g_eUserInfo[id][SaveInfo], iSum, 1) == 0)
	{
		client_print_kolor(id, id, "You don't have enough Coins in your bank.")
		return PLUGIN_HANDLED
	}

	g_eUserInfo[id][Coins] += iSum
	
	client_print_kolor(id, id, "You now have^x04 %i^x01 Coins in You.", g_eUserInfo[id][Coins])
	
	return PLUGIN_HANDLED
}

//Deposit
public cmdDep(id)
{
	if (!is_user_connected(id) || !CheckTimer(id) || !CheckLogged(id))
		return PLUGIN_HANDLED
	
	new szOutput[20]
	read_argv(1, szOutput, charsmax(szOutput))
	
	new iSum = abs(str_to_num(szOutput))
	
	if (g_eUserInfo[id][Coins] < iSum)
		iSum = g_eUserInfo[id][Coins]

	if(!SaveCoins(g_eUserInfo[id][SaveInfo], iSum, 0))
		return PLUGIN_HANDLED

	g_eUserInfo[id][Coins] -=  iSum
	
	client_print_kolor(id, id, "^x04>> Vault >>^x01 You successfully deposited^x04 %i^x01 coins!", iSum)
	
	return PLUGIN_HANDLED
}

//Reg
public cmdReg(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED
	
	CheckLogged(id)

	return PLUGIN_HANDLED
}

RegMenu(id, bool:bPass)
{
	new iMenu = menu_create("\rChoose Your Type of Reg:^n", "Reg_Handler")

	new szLine[64], iMenuCallback = menu_makecallback("RegCallBack")

	menu_additem(iMenu, "\yBy \rName")
	menu_additem(iMenu, "\yBy \rIp")
	menu_additem(iMenu, "\yBy \rSteam", .callback = iMenuCallback)
	formatex(szLine, charsmax(szLine), "\yUsing Password: %s", bPass ? "\rYes" : "\dNo")
	menu_additem(iMenu, szLine)

	menu_display(id, iMenu)
}

public RegCallBack(id)
{
	new szSteam[40]
	get_user_authid(id, szSteam, charsmax(szSteam))
	if(equal(szSteam, "STEAM_ID_LAN"))
		return ITEM_DISABLED
	return ITEM_ENABLED
}

public Reg_Handler(id, iMenu, iItem)
{
	new _iAccess, iItemCallBack, szName[128], bool:bPass
	menu_item_getinfo(iMenu, 3, _iAccess, szName, charsmax(szName), szName, charsmax(szName), iItemCallBack)
	bPass = szName[20] == 'Y'

	switch(iItem)
	{
		case 0:
			RegUser(id, 1, bPass)
		case 1:
			RegUser(id, 2, bPass)
		case 2:
			RegUser(id, 3, bPass)
		case 3:
		{
			if (bPass)
				RegMenu(id, false)
			else
				client_cmd(id, "messagemode amx_coinpass")
		}
	}

	if(0 <= iItem <= 2)
	{
		g_eUserInfo[id][Coins] += 100
		client_print_kolor(id, id, "^x04>> Reg >>^x01 You successfully registered yourself!")
		client_print_kolor(id, id, "^x04>> Reg >>^x01 We added 100 coins in your pocket as a reward!")
	}

	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

//SetPass
public cmdSetPass(id)
{
	if (!is_user_connected(id) || !CheckTimer(id))
		return PLUGIN_HANDLED

	read_args(g_eUserInfo[id][Pass], charsmax(g_eUserInfo[][Pass]))

	remove_quotes(g_eUserInfo[id][Pass])
	
	if (!g_eUserInfo[id][Pass][0])
		return PLUGIN_HANDLED
	else if (strlen(g_eUserInfo[id][Pass]) <= 3)
	{
		client_cmd(id, "messagemode amx_coinpass")
		client_print_kolor(id, id, "^x04>> Reg >>^x01 Your Password must be atleast 3 symbols")
		return PLUGIN_HANDLED
	}
	else if (strlen(g_eUserInfo[id][Pass]) > 12)
	{
		client_cmd(id, "messagemode amx_coinpass")
		client_print_kolor(id, id, "^x04>> Reg >>^x01 Your Password cannot be longer than 12 symbols")
		return PLUGIN_HANDLED
	}

	if (g_eUserInfo[id][Registered])
		CheckPass(id)
	else
		RegMenu(id, true)
		
	client_print_kolor(id, id, "^x04>> Reg >>^x01 You successfully set your password to !!!HIDDEN!!!")

	return PLUGIN_HANDLED
}

////////////////////////////////////////////////////////////
// 					    	MENU						  //
////////////////////////////////////////////////////////////
//Help
Prebori_demenciqta(id)
{
	show_motd(id, "HelpYourself.txt", "Info About The Coins")
}

//Dice
Dice(id)
{
	if (!g_eUserInfo[id][Coins])
	{
		client_print_kolor(id, id, "^x04>> Dice >>^x01 You don't have enough coins!")
		return
	}

	g_eUserInfo[id][Coins]--
	new rand = random_num(0, 100)

	if (rand == 0)
	{
		client_print_kolor(id, id, "^x04>> Dice >>^x01 Congratulation you won 100 coins from the Dice!")
		client_print_kolor(id, id, "^x04>> Dice >>^x01 But we are keeping one for ourselves, cuz we can :*")
		g_eUserInfo[id][Coins] += 99
	}
	else 
	{
		client_print_kolor(id, id, "^x04>> Dice >>^x01 Sorry you rolled %i and not 0", rand)
	}
	CmdMenu(id)
}

//Drop
Drop_Coin(id)
{
	new szHeader[50]
	formatex(szHeader, charsmax(szHeader), "\rChoose \yamount^n\yCoins in Pocket: %d", g_eUserInfo[id][Coins])
	
	menu_setprop(g_iDropMenu, MPROP_TITLE, szHeader)
	
	menu_display(id, g_iDropMenu)
} 

public DropAmount(id, menu, item)
{
	if (item == MENU_EXIT)
		return
	
	new iAmount = max(item * 5, 1)
	
	if (g_eUserInfo[id][Coins] >= iAmount) 
	{
		new Float:fOrig[3]
		get_entvar(id, var_origin, fOrig)
		SpawnCoins(0, fOrig, iAmount)
		g_eUserInfo[id][Coins] -= iAmount
	} 
	else
		client_print_kolor(id, id, "^x04You^x01 don't have enough^x04 coins^x01!")
	
	Drop_Coin(id)
}

////////////////////////////////////////////////////////////
// 					    	HAMS						  //
////////////////////////////////////////////////////////////
public Ham_Pogrebal(iVictim, iKiller)
{
	if (!is_user_connected(iVictim) || !is_user_connected(iKiller) || iVictim == iKiller)
		return HAM_IGNORED

	new Float:fOrigin[3], Float:fTempOrigin[3]
	get_entvar(iVictim, var_origin, fOrigin)
	fTempOrigin[0] = g_eUserInfo[iVictim][SpawnOrigin][0]
	fTempOrigin[1] = g_eUserInfo[iVictim][SpawnOrigin][1]
	fTempOrigin[2] = g_eUserInfo[iVictim][SpawnOrigin][2]

	if(get_distance_f(fTempOrigin, fOrigin) < 10.0)
		return HAM_IGNORED
	
	if (random(100) < 5) 
	{
		SpawnCoins(iKiller, fOrigin, 10)
		return HAM_IGNORED
	}
	
	new iCoinsAdd = 1
	
	iCoinsAdd += get_member(iVictim, m_bHeadshotKilled) ? 1 : 0
	iCoinsAdd += get_user_flags(iKiller) & ADMIN_VIPA ? 1 : 0
	iCoinsAdd += get_entvar(iKiller, var_flags) & FL_ONGROUND ? 0 : 1
		
	SpawnCoins(iKiller, fOrigin, iCoinsAdd)
	
	return HAM_IGNORED
}

public Ham_Dokosvaneto(id, tid)
{	
	static Float:flTime, Float:flOldTime
	flTime = get_gametime()
	get_entvar(id, var_fuser1, flOldTime)
	
	if (get_entvar(id, var_iuser1) == COINSNUM && is_user_connected(tid) && flOldTime + 1.0 < flTime)
	{
		#if defined GOLDENS
		if(!gold_has(tid))
		{
		#endif
			new iCoins = get_entvar(id, var_iuser2)
			g_eUserInfo[tid][Coins] += iCoins
			set_entvar(id, var_flags, get_entvar(id, var_flags) | FL_KILLME)
			client_print(tid, print_center, "You recieved %i(%i) coin%s", iCoins, g_eUserInfo[tid][Coins], iCoins != 1 ? "s" : "")
			if(!g_eUserInfo[tid][Registered])
				RegMenu(tid, false)
		#if defined GOLDENS
		}
		else if(g_iGoldSpam[tid] == 20)
		{
			client_print(tid, print_center, "You can't collect coins when you have gold")
			g_iGoldSpam[tid] = 0
		}
		else
		{
			g_iGoldSpam[tid]++
		}
		#endif
	}
	return HAM_IGNORED
}

public Ham_IvanskoMislene(id)
{
	if (get_entvar(id, var_iuser1) == COINSNUM)
	{
		new Float:fGmTime, Float:fEntTime
	 	fGmTime = get_gametime()
	 	fEntTime = get_entvar(id, var_fuser1)
	 	if(fEntTime + 19.0 < fGmTime)
	 	{
			set_entvar(id, var_flags, get_entvar(id, var_flags) | FL_KILLME)
	 	}
	}
}

public Ham_Rajdane(id)
{
	if(g_eUserInfo[id][FirstSpawn] && is_user_alive(id))
	{
		set_task(3.0, "TaskRajdane", id + 100)
		g_eUserInfo[id][FirstSpawn] = false
	}
	set_task(1.0, "TaskAfkRajdane", id + 200)
}

public TaskAfkRajdane(id)
{
	id -= 200
	new Float:test[3]
	get_entvar(id, var_origin, g_eUserInfo[id][SpawnOrigin])
}

public TaskRajdane(id)
{
	id -= 100

	if(g_eUserInfo[id][Logged] && g_eUserInfo[id][Registered])
	{
		if(SaveCoins(g_eUserInfo[id][SaveInfo], 100, 1) == 1)
		{
			g_eUserInfo[id][Coins] += 100
			client_print_kolor(id, id, "^x04>> Vault >>^x01 We withdrew^x03 100 Coins^x01 for^x04 You!")
		}
		else
		{
			client_print_kolor(id, id, "^x04>> Vault >>^x01 We tried to withdraw^x03 100 Coins^x01 for^x04 You^x01 don't have enough in your vault!")
		}
	}
}

////////////////////////////////////////////////////////////
// 						SOME NATIVES					  //
////////////////////////////////////////////////////////////
SpawnCoins(iOwner, Float:fOrigin[3], iCoinsAdd)
{
	new iNewEnt = rg_create_entity("info_target")
	
	set_entvar(iNewEnt, var_origin, fOrigin)
	set_entvar(iNewEnt, var_classname, "coin")
	set_entvar(iNewEnt, var_modelindex, g_iModel)
	set_entvar(iNewEnt, var_solid, SOLID_TRIGGER)
	set_entvar(iNewEnt, var_movetype, MOVETYPE_TOSS)
	set_entvar(iNewEnt, var_framerate, 0.6)
	set_entvar(iNewEnt, var_sequence, CoinFloat) 
	set_entvar(iNewEnt, var_mins, Float:{ -10.0, -10.0, -10.0 })
	set_entvar(iNewEnt, var_maxs, Float:{ 10.0, 10.0, 10.0 })
	set_entvar(iNewEnt, var_iuser2, iCoinsAdd)
	set_entvar(iNewEnt, var_nextthink, get_gametime() + 60.0)
	
	
	set_entvar(iNewEnt, var_owner, iOwner)
	set_entvar(iNewEnt, var_iuser1, COINSNUM)
	set_entvar(iNewEnt, var_fuser1, get_gametime())
}

CheckLogged(id)
{
	if (!g_eUserInfo[id][Registered])
	{
		RegMenu(id, false)
		return false
	}
	else if (!g_eUserInfo[id][Logged])
	{
		client_cmd(id, "messagemode amx_coinpass")
		return false
	}

	return true
}

CheckTimer(id)
{
	new Float:fGmTime = get_gametime()

	if (g_eUserInfo[id][SqlCooldown] > fGmTime)
	{
		client_print_kolor(id, id, "^x04>> Vault >>^x01 You have to wait^x03 %i^x01 more seconds!", floatround(g_eUserInfo[id][SqlCooldown] - fGmTime))
		return 0
	}
	
	g_eUserInfo[id][SqlCooldown] = _:(fGmTime + 3.0)
	return 1
}

client_print_kolor(id, iSender, szMsg[], any:...)
{
	if(!is_user_connected(id) && get_pcvar_num(g_iSpamCvar) != 1)
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

////////////////////////////////////////////////////////////
// 				          Natives    					  //
////////////////////////////////////////////////////////////

public plugin_natives()
{
	register_native("csys_get_user_coins", "_native_get_user_coins")
	register_native("csys_set_user_coins", "_native_set_user_coins")
}

public _native_get_user_coins()
	return g_eUserInfo[get_param(1)][Coins]

public _native_set_user_coins()
	g_eUserInfo[get_param(1)][Coins] = get_param(2)

////////////////////////////////////////////////////////////
// 				   Things That May Help					  //
////////////////////////////////////////////////////////////
/*WithDrawCoins(id, iCoins)
{	
	if (iCoins <= 0)
	{
		client_print(id, print_chat, "Try with bigger amount.")
		return
	}

	new iSaveRet = SaveCoins(g_eUserInfo[id][SaveInfo], iCoins, 1)

	if (iSaveRet == 0)
	{
		client_print(id, print_chat, "You now have enough Coins in your bank.")
		return
	}

	g_eUserInfo[id][Coins] += iCoins
	
	client_print(id, print_chat, "You now have %i Coins in You.", g_eUserInfo[id][Coins])
}*/
