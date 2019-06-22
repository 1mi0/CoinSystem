#if defined _csysrank_sql_included
	#endinput
#endif
#define _csysrank_sql_included

#include <sqlx>
#include <csysrank_const>

new Handle:g_iSqlTuple
new g_szError[512]

/*
Sql structure

The ranks

rank_id, rank_name, rank_color, rank_info, rank_type, type_addoninfo
rank_id - custom id
rank_name - the name used to identify the rank in the menus
rank_color - the version that contains all the colors and "[]" in it
rank_info - describing the rank
rank_type:
1 - normal buyable rank
2 - in a specified order
3 - one person rank
type_addoninfo - info used with the type

The players

savedata, rank_string
savedata - used to identify the user
rank_string - used to specify which ranks the user has
*/

public MySql_Init()
{
	new iErrorCode
	g_iSqlTuple = SQL_MakeDbTuple(szHost, szUser, szPass, szDB)

	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	if (iSqlConnection == Empty_Handle)
	{
		set_fail_state(g_szError)
	}

	new Handle:iQueries = SQL_PrepareQuery(iSqlConnection, "CREATE TABLE IF NOT EXISTS `%s`\
	(`rank_id` INT(10) NOT NULL,\
	`rank_name` VARCHAR(64) NOT NULL,\
	`rank_color` VARCHAR(128) NOT NULL,\
	`rank_info` VARCHAR(128) NOT NULL,\
	`rank_type` INT(10) NOT NULL,\
	`type_addoninfo` VARCHAR(128),\
	PRIMARY KEY (`id`) );", g_szRanksDB)

	if (!SQL_Execute(iQueries))
	{
		SQL_QueryError(iQueries, g_szError, charsmax(g_szError))
		set_fail_state(g_szError)
	}

	iQueries = SQL_PrepareQuery(iSqlConnection, "CREATE TABLE IF NOT EXISTS `%s`\
	(`savedata` VARCHAR(80) NOT NULL,\
	`rank_string` VARCHAR(512) NOT NULL,\
	PRIMARY KEY (`savedata`) );", g_szUsersDB)

	if (!SQL_Execute(iQueries))
	{
		SQL_QueryError(iQueries, g_szError, charsmax(g_szError))
		set_fail_state(g_szError)
	}

	SQL_FreeHandle(iQueries)
	SQL_FreeHandle(iSqlConnection)
}

public LoadRanks()
{
	new iErrorCode
	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, "SELECT * FROM `%s`;", g_szRanksDB, szTarSteam)
	if (!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		set_fail_state(g_szError)
		return
	}

	new iRow = SQL_NumResults(iQuery)
	new eTempArray[RankInfo]

	if(SQL_MoreResults(iQuery))
	{
		for(new i = 0; i < iRow; i++)
		{
			eTempArray[RankID] = SQL_ReadResult(iQuery, 0)
			SQL_ReadResult(iQuery, 1, eTempArray[RankName], charsmax(eTempArray[RankName]))
			SQL_ReadResult(iQuery, 2, eTempArray[RankColor], charsmax(eTempArray[RankColor]))
			SQL_ReadResult(iQuery, 3, eTempArray[RankAddonInfo], charsmax(eTempArray[RankAddonInfo]))
			eTempArray[RankType] = SQL_ReadResult(iQuery, 4)
			SQL_ReadResult(iQuery, 5, eTempArray[RankAddonInfo], charsmax(eTempArray[RankAddonInfo]))
			ArrayPushArray(g_aRankArray, eTempArray)
			g_iRankIDCount++
			SQL_NextRow(iQuery)
		}
	}

	log_amx("[Coins] >> Rank >> %i ranks successfully loaded", iRow)

	SQL_FreeHandle(iQuery)
	SQL_FreeHandle(iSqlConnection)
}

SqlAddRank(eTempArray[RankInfo])
{
	new iErrorCode
	new Handle:iSqlConnection = SQL_Connect(g_iSqlTuple, iErrorCode, g_szError, charsmax(g_szError))

	new szTemp[256]
	formatex(szTemp, charsmax(szTemp), "INSERT INTO `%s` \
		(`rank_id`, `rank_name`, `rank_color`, `rank_info`, `rank_type`, `type_addoninfo`) \
		VALUES ('%i', '%s', '%s', '%s', '%i', '%s');", g_szRanksDB, 
		eTempArray[RankID], eTempArray[RankName], eTempArray[RankColor], 
		eTempArray[RankAddonInfo], eTempArray[RankType], eTempArray[RankAddonInfo])

	new Handle:iQuery = SQL_PrepareQuery(iSqlConnection, szTemp)

	if (!SQL_Execute(iQuery))
	{
		SQL_QueryError(iQuery, g_szSqlError, charsmax(g_szSqlError))
		log_amx(g_szError)
		return false
	}

	SQL_FreeHandle(iQuery)
	SQL_FreeHandle(iSqlConnection)
	return true
}