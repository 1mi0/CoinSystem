#include <amxmodx>
#include <csysrank_sql>

#define PLUGIN "Coin System: Rank System"
#define VERSION "0.1"
#define AUTHOR "mi0 & SmirnoffBG"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public plugin_cfg()
{
	g_aRankArray = ArrayCreate(RankInfo)

	set_task(1.0, "MySql_Init")
	set_task(2.0, "LoadRanks")
}

AddRank(szRankName[64], szRankColor[128], szRankInfo[128], iRankType, szAddonInfo[128])
{
	new eTempArray[RankInfo]
	eTempArray[RankID] = g_iRankIDCount++
	copy(eTempArray[RankName], charsmax(eTempArray[RankName]), szRankName)
	copy(eTempArray[RankColor], charsmax(eTempArray[RankColor]), szRankColor)
	copy(eTempArray[RankCustomInfo], charsmax(eTempArray[RankCustomInfo]), szRankInfo)
	eTempArray[RankType] = iRankType
	copy(eTempArray[RankAddonInfo], charsmax(eTempArray[RankAddonInfo]), szAddonInfo)
	
	if(!SqlAddRank(eTempArray))
	{
		return false
	}

	ArrayPushArray(g_aRankArray, eTempArray)
	return true
}

AddUser(id)
{
	if(!is_user_connected(id))
	{
		return false
	}

	if(csys_user_check_logged(id) && !g_eUserInfo[id][HasAccount])
	{
		new szSaveData[64]
		csys_get_user_svdata(id, szSaveData, charsmax(szSaveData))
		if(!SqlAddUser(szSaveData))
		{
			return false
		}
	}

	g_eUserInfo[id][HasAccount] = true
	g_eUserInfo[id][Logged] = true

	return true
}

CheckUser(id)
{
	new szSaveData[64], bool:bHasAccount

	csys_get_user_svdata(id, szSaveData, charsmax(szSaveData))
	g_eUserInfo[id][HasAccount] = SqlCheckUser(szSaveData)
	CheckLogged(id)

	return g_eUserInfo[id][HasAccount]
}

CheckLogged(id)
{
	g_eUserInfo[id][Logged] = csys_user_check_logged(id)

	return g_eUserInfo[id][Logged]
}