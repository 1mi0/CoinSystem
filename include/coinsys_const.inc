#if defined _coinsys_const_included
	#endinput
#endif
#define _coinsys_const_included


//sql const
#if SQLVER < 1
new const szHost[32] =	"54.37.177.228"
new const szUser[32] =	"csnation_coins"
new const szPass[32] =	"x1x2x3"
new const szDB[32] =	"csnation_coins"
#else
new const szHost[32] =	"185.148.145.64"
new const szUser[32] =	"csnation"
new const szPass[32] =	"I5AxPeEoH1SwUWq9"
new const szDB[32] =	"csnation"
#endif

new const g_szSqlDB[] = "CoinsSystem"

enum _:UserInfo
{
	SaveInfo[64],
	Name[32],
	Pass[13],
	bool:Registered,
	bool:Logged,
	Coins,
	DonateID,
	Float:SqlCooldown,
	bool:FirstSpawn
}

new g_eUserInfo[33][UserInfo]

enum _:CoinSequences
{
	CoinIdle = 0,
	CoinFloat,
	CoinSpin
}