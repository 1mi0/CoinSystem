#include <amxmodx>
#include <amxmisc>
#include <sqlx>

new g_szBuffer[4096]
new g_szStyle[] = "<meta charset=UTF-8><style>body{font-family:Arial;}img{margin-bottom:10px;}th{background:#57b9ff;color:#FFF;padding:5px;border-bottom:2px #24a4ff solid;text-align:left}td{padding:3px;border-bottom:1px #8aceff dashed}table{color:#2c75ff;background:#FFF;font-size:12px}h2,h3{color:#333;font-family:Verdana}#c{background:#F0F7E2}#r{height:10px;background:#717171}#clr{background:none;color:#575757;font-size:20px}</style>"

new const szHost[32] =	"185.148.145.64"
new const szUser[32] =	"csnation"
new const szPass[32] =	"I5AxPeEoH1SwUWq9"
new const szDB[32] =	"csnation"

new Handle:g_iSqlTuple
new g_szSqlError[512]

#define TABLENAME "CoinsSystem"
#define SAVEINFO "savedata"
#define COINS "coins"
#define PASSWORD "password"

public plugin_init()
{
	register_plugin("Sql Manager", "1.0", "mi0")

	register_concmd("amx_sqlexec", "cmd_exec", ADMIN_RCON)
	register_concmd("amx_sqlcheck", "cmd_check", ADMIN_RCON)

	set_task(1.0, "MySql_Init")
}

public MySql_Init()
{
	g_iSqlTuple = SQL_MakeDbTuple(szHost, szUser, szPass, szDB)
}

public plugin_end()
{
	SQL_FreeHandle(g_iSqlTuple)
}

public cmd_exec(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new Handle:iSqlConnection, iErrorCode
	iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szSqlError, charsmax(g_szSqlError))
	if (iSqlConnection == Empty_Handle)
	{
		client_print(id, print_console, "[SQL Manager] FAILED: The connection to the sql db failed")
		client_print(id, print_console, "[SQL Manager] ERROR: %s", g_szSqlError)
		log_amx(g_szSqlError)
		return PLUGIN_HANDLED
	}

	new szArgs[256]
	read_args(szArgs, charsmax(szArgs))
	formatsm(szArgs, charsmax(szArgs))

	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, szArgs)
	if (!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		client_print(id, print_console, "[SQL Manager] FAILED: The execution failed be happy you won't die xD")
		client_print(id, print_console, "[SQL Manager] WARNING: If you don't know how to use this command DON'T USE IT!")
		client_print(id, print_console, "[SQL Manager] WARNING: You may break the hole sql system")
		client_print(id, print_console, "[SQL Manager] WARNING: which may break the coin system or even the servers!")
		client_print(id, print_console, "[SQL Manager] ERROR: %s", g_szSqlError)
		client_print(id, print_console, "[SQL Manager] %s", szArgs)
	}
	else
	{
		client_print(id, print_console, "[SQL Manager] You successfully executed the command:")
		client_print(id, print_console, "[SQL Manager] %s", szArgs)
		client_print(id, print_console, "[SQL Manager] Affected Rolls: %d", SQL_AffectedRows(iQuery))
		client_print(id, print_console, "[SQL Manager] Num Resaults: %d", SQL_NumResults(iQuery))
	}

	log_sm(id, szArgs)

	SQL_FreeHandle(iSqlConnection)
	SQL_FreeHandle(iQuery)

	return PLUGIN_HANDLED
}

public cmd_check(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	new szArgs[33]
	read_args(szArgs, charsmax(szArgs))

	if(!szArgs[0])
	{
		OpenCheckMenu(id)
		return PLUGIN_HANDLED
	}

	new iTarget = cmd_target(id, szArgs, CMDTARGET_ALLOW_SELF)

	if(!iTarget)
		return PLUGIN_HANDLED

	CheckUser(id, iTarget)

	return PLUGIN_HANDLED
}

CheckUser(id, iTarget)
{
	new Handle:iSqlConnection, iErrorCode
	iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szSqlError, charsmax(g_szSqlError))
	if (iSqlConnection == Empty_Handle)
	{
		client_print(id, print_console, "[SQL Manager] FAILED: The connection to the sql db failed")
		client_print(id, print_console, "[SQL Manager] ERROR: %s", g_szSqlError)
		log_amx(g_szSqlError)
		return
	}

	new szTarIp[64], szTarSteam[64], szTarName[80] 
	get_user_ip(iTarget, szTarIp, charsmax(szTarIp), 1)
	get_user_authid(iTarget, szTarSteam, charsmax(szTarSteam))
	get_user_name(iTarget, szTarName, charsmax(szTarName))
	SQL_QuoteString(iSqlConnection, szTarName, charsmax(szTarName), szTarName)
	format(szTarSteam, charsmax(szTarSteam), "1S_%s", szTarSteam)
	format(szTarIp, charsmax(szTarIp), "2I_%s", szTarIp)
	format(szTarName, charsmax(szTarName), "3N_%s", szTarName)

	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, "SELECT * FROM `%s` WHERE savedata IN('%s', '%s', '%s');", TABLENAME, szTarSteam, szTarIp, szTarName)
	if (!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		client_print(id, print_console, "[SQL Manager] FAILED: The connection to the sql db failed")
		client_print(id, print_console, "[SQL Manager] ERROR: %s", g_szSqlError)
		log_amx(g_szSqlError)
		return
	}

	new iRow = SQL_NumResults(iQuery)

	new szSavedata[4][64], iCoins[4], szPassword[4][14]

	if(SQL_MoreResults(iQuery))
	{
		for(new i = 0; i < iRow; i++)
		{
			SQL_ReadResult(iQuery, 0, szSavedata[i], charsmax(szSavedata[]))
			iCoins[i] = SQL_ReadResult(iQuery, 1)
			SQL_ReadResult(iQuery, 2, szPassword[i], charsmax(szPassword[]))
			SQL_NextRow(iQuery)
		}
	}

	if(iRow > 0)
	{
		new iLen=0
		iLen = format(g_szBuffer[iLen], charsmax(g_szBuffer), g_szStyle)
		iLen += format(g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "<body><table width=100%% border=0 align=center cellpadding=0 cellspacing=1>")
		iLen += format(g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "<tr><th>%s<th>%s<th>%s<th>%s</tr>", "#", "SaveData", "Coins", "Password")
		
		
		for(new i = 0; i < iRow; i++)
		{
			replace_all(szSavedata[i], charsmax(szSavedata[]), "&", "&amp;")
			replace_all(szSavedata[i], charsmax(szSavedata[]), "<", "&lt;")
			replace_all(szSavedata[i], charsmax(szSavedata[]), ">", "&gt;")

			replace_all(szPassword[i], charsmax(szPassword[]), "&", "&amp;")
			replace_all(szPassword[i], charsmax(szPassword[]), "<", "&lt;")
			replace_all(szPassword[i], charsmax(szPassword[]), ">", "&gt;")
			
			iLen += format(g_szBuffer[iLen], 4095 - iLen, "<tr><td>%i<td><b>%s</b><td>%i<td>%s", i + 1, szSavedata[i], iCoins[i], szPassword[i])
		}
		show_motd(id, g_szBuffer, "User Checker")
	}
	else
		client_print(id, print_console, "[SQL Manager] ERROR: We couldn't find that person in the sql.")

	SQL_FreeHandle(iSqlConnection)
	SQL_FreeHandle(iQuery)
}

OpenCheckMenu(id)
{
	new iMenu, iPlayers[32], iPlayersNum
	iMenu = menu_create("\rSql Check \yMenu", "CheckMenuHandler")
	get_players(iPlayers, iPlayersNum)

	for(new i, szInfo[1], szTemp[33]; i < iPlayersNum; i++)
	{
		szInfo[0] = iPlayers[i]
		get_user_name(szInfo[0], szTemp, charsmax(szTemp))
		menu_additem(iMenu, szTemp, szInfo)
	}

	menu_display(id, iMenu)
}

public CheckMenuHandler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}

	new szInfo[1]
	menu_item_getinfo(iMenu, iItem, iItem, szInfo, 1, _, _, iItem)

	CheckUser(id, szInfo[0])

	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

log_sm(id, szCommand[])
{
	new szName[33], szSteam[33]
	get_user_name(id, szName, charsmax(szName))
	get_user_authid(id, szSteam, charsmax(szSteam))

	log_amx("[SQL Manager] Admin: %s(%s) executed:", szName, szSteam)
	log_amx("[SQL Manager] %s", szCommand)
}

formatsm(szCommand[], iLen)
{
	replace_all(szCommand, iLen, "&tb&", TABLENAME)
	replace_all(szCommand, iLen, "&sd&", SAVEINFO)
	replace_all(szCommand, iLen, "&coins&", COINS)
	replace_all(szCommand, iLen, "&password&", PASSWORD)
}

/*public QueryHandler(iFailState, Handle:iQuery, szError[], iErrcode, szData[], iDataSize)
{
	switch(iFailState)
	{
		case -2: log_amx("[SQL Error] Failed to connect (%d):%s", iErrcode, szError)
		case -1: log_amx("[SQL Error] (%d):%s", iErrcode, szError)
	}

	return PLUGIN_HANDLED
}*/