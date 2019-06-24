#if defined _coin_system_included
	#endinput
#endif
#define _coin_system_included

native csys_get_user_coins(id)
native csys_set_user_coins(id, coins)

native csys_get_user_svdata(id, szBuff[], iLen)
native bool:csys_user_check_logged(id)