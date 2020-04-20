#if defined _coinsys_sql_included
	#endinput
#endif
#define _coinsys_sql_included

new const szHost[32] =	"185.148.145.64"
new const szUser[32] =	"csnation"
new const szPass[32] =	"************"
new const szDB[32] =	"csnation"

new const g_szSqlDB[] = "CoinsSystem"

#include <sqlx>
#include <coinsys_const>

new Handle:g_iSqlTuple
new g_szError[512]

////////////////////////////////////////////////////////////
// 			         MySql Prepareing  					  //
////////////////////////////////////////////////////////////
public MySql_Init()
{
	new iErrorCode
	g_iSqlTuple = SQL_MakeDbTuple(szHost, szUser, szPass, szDB)

	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	if (iSqlConnection == Empty_Handle)
		set_fail_state(g_szError)

	new Handle:iQueries = SQL_PrepareQuery(iSqlConnection, "CREATE TABLE IF NOT EXISTS `%s`\
	(`savedata` VARCHAR(80) NOT NULL,\
	`coins` INT(10) NOT NULL,\
	`password` VARCHAR(32),\
	PRIMARY KEY (`savedata`) );", g_szSqlDB)

	if (!SQL_Execute(iQueries))
	{
		SQL_QueryError(iQueries, g_szError, charsmax(g_szError))
		set_fail_state(g_szError)
	}

	SQL_FreeHandle(iQueries)
	SQL_FreeHandle(iSqlConnection)
}

////////////////////////////////////////////////////////////
// 		        Check if User Is Registered				  //
////////////////////////////////////////////////////////////
CheckUser(id)
{
	new iErrorCode
	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	if (iSqlConnection == Empty_Handle)
	{
		log_amx(g_szError)
		return
	}

	new szIp[64], szSteam[64], szName[80] 
	get_user_ip(id, szIp, charsmax(szIp), 1)
	get_user_authid(id, szSteam, charsmax(szSteam))
	SQL_QuoteString(iSqlConnection, szName, charsmax(szName), g_eUserInfo[id][Name])
	format(szSteam, charsmax(szSteam), "1S_%s", szSteam)
	format(szIp, charsmax(szIp), "2I_%s", szIp)
	format(szName, charsmax(szName), "3N_%s", szName)

	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, "SELECT `savedata`, `password` FROM `%s` WHERE savedata IN('%s', '%s', '%s');", g_szSqlDB, szSteam, szIp, szName)

	if (!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szError, charsmax(g_szError))
		log_amx(g_szError)
		return
	}

	if (SQL_NumResults(iQuery) < 1)
	{
		g_eUserInfo[id][Registered] = false
	}
	else
	{
		SQL_ReadResult(iQuery, 0, g_eUserInfo[id][SaveInfo], charsmax(g_eUserInfo[][SaveInfo]))
		new szPass[28]
		SQL_ReadResult(iQuery, 1, szPass, charsmax(szPass))
		if(szPass[0] == EOS)
			g_eUserInfo[id][Logged] = true
		g_eUserInfo[id][Registered] = true
	} 

	SQL_FreeHandle(iQuery)
	SQL_FreeHandle(iSqlConnection)
}

////////////////////////////////////////////////////////////
// 		            Get Coins From Bank      			  //
////////////////////////////////////////////////////////////
Get_Coins_From_Bank(szName[])
{
	new iErrorCode
	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	if (iSqlConnection == Empty_Handle)
	{
		log_amx(g_szError)
		return 0
	}
	
	new szTemp[256]
	
	formatex(szTemp, charsmax(szTemp), "SELECT coins FROM `%s` WHERE savedata = '%s'", g_szSqlDB, szName)
	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, szTemp)
	SQL_Execute(iQuery)	
	
	new iCoins = SQL_NumResults(iQuery) > 0 ? SQL_ReadResult(iQuery, 0) : 0
	SQL_FreeHandle(iSqlConnection)
	SQL_FreeHandle(iQuery)
	
	return iCoins
}

////////////////////////////////////////////////////////////
// 		   Putting And Pulling Coins From Vault			  //
////////////////////////////////////////////////////////////
SaveCoins(szName[], iCoins, iMinus)
{
	if (iCoins < 1) return 0
	
	new iErrorCode, Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))
	if (iSqlConnection == Empty_Handle)
	{
		log_amx(g_szError)
		return 0
	}
	
	new Handle:iQuery
	if (iMinus == 0)
		iQuery = SQL_PrepareQuery(iSqlConnection, "UPDATE %s SET coins = coins + %i WHERE savedata = '%s';", g_szSqlDB, iCoins, szName)
	else
		iQuery = SQL_PrepareQuery(iSqlConnection, "UPDATE %s SET coins = coins - %i WHERE savedata = '%s' AND coins >= '%i';", g_szSqlDB, iCoins, szName, iCoins)

	SQL_Execute(iQuery)
	iMinus = SQL_AffectedRows(iQuery)
	
	SQL_FreeHandle(iSqlConnection)
	SQL_FreeHandle(iQuery)
	return iMinus
}

////////////////////////////////////////////////////////////
// 		                 Regging User          			  //
////////////////////////////////////////////////////////////
RegUser(id, iType, bool:bPass)
{
	new iErrorCode, Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))
	if (iSqlConnection == Empty_Handle)
	{
		log_amx(g_szError)
		return
	}

	new szSaveInfo[80]

	switch(iType)
	{
		case 1:
		{
			SQL_QuoteString(iSqlConnection, szSaveInfo, charsmax(szSaveInfo), g_eUserInfo[id][Name])
			format(szSaveInfo, charsmax(szSaveInfo), "3N_%s", szSaveInfo)
		}
		case 2:
		{
			get_user_ip(id, szSaveInfo, charsmax(szSaveInfo), 1)
			format(szSaveInfo, charsmax(szSaveInfo), "2I_%s", szSaveInfo)
		}
		case 3:
		{
			get_user_authid(id, szSaveInfo, charsmax(szSaveInfo))
			format(szSaveInfo, charsmax(szSaveInfo), "1S_%s", szSaveInfo)
		}
	}

	new szPassword[32]
	SQL_QuoteString(iSqlConnection, szPassword, charsmax(szPassword), g_eUserInfo[id][Pass])

	new szTemp[256]
	formatex(szTemp, charsmax(szTemp), "INSERT INTO `%s` (`savedata`, `coins`, `password`) VALUES ('%s', '0', '%s');", g_szSqlDB, szSaveInfo, bPass ? szPassword : "")

	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, szTemp)
	SQL_Execute(iQuery)

	g_eUserInfo[id][Registered] = true
	g_eUserInfo[id][Logged] = true
	copy(g_eUserInfo[id][SaveInfo], charsmax(g_eUserInfo[][SaveInfo]), szSaveInfo)

	SQL_FreeHandle(iSqlConnection)
	SQL_FreeHandle(iQuery)
}

////////////////////////////////////////////////////////////
//               Checking User's Password     			  //
////////////////////////////////////////////////////////////
CheckPass(id)
{
	new iErrorCode
	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	if (iSqlConnection == Empty_Handle)
	{
		log_amx(g_szError)
		return
	}
	
	new szTemp[256], szPassInSql[32], szPassword[32]
	SQL_QuoteString(iSqlConnection, szPassword, charsmax(szPassword), g_eUserInfo[id][Pass])
	
	formatex(szTemp, charsmax(szTemp), "SELECT password FROM `%s` WHERE savedata = '%s'", g_szSqlDB, g_eUserInfo[id][SaveInfo])
	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, szTemp)
	SQL_Execute(iQuery)
	
	SQL_ReadResult(iQuery, 0, szPassInSql, charsmax(szPassInSql))

	if (equal(szPassInSql, szPassword))
		g_eUserInfo[id][Logged] = true
	else
		g_eUserInfo[id][Logged] = false

	SQL_FreeHandle(iSqlConnection)
	SQL_FreeHandle(iQuery)
}

////////////////////////////////////////////////////////////
//              Ignore Handler Not in use rn 			  //
////////////////////////////////////////////////////////////
/*public IgnoreHandler(iFailState, Handle:iQuery, szError[], iErrorCode)
{
	return PLUGIN_HANDLED
}*/
