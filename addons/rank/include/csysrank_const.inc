#if defined _csysrank_const_included
	#endinput
#endif
#define _csysrank_const_included

enum _:RankInfo
{
	RankID,
	RankName[64],
	RankColor[128],
	RankCustomInfo[128],
	RankType,
	RankAddonInfo[128]
}

new const szHost[32] =	"185.148.145.64"
new const szUser[32] =	"csnation"
new const szPass[32] =	"I5AxPeEoH1SwUWq9"
new const szDB[32] =	"csnation"

new const g_szRanksDB[] = "rank_ranks"
new const g_szUsersDB[] = "rank_users"

new Array:g_aRankArray
new g_iRankIDCount