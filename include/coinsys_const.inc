#if defined _coinsys_const_included
	#endinput
#endif
#define _coinsys_const_included

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