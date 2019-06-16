#if defined _coinsys_shop_included
	#endinput
#endif
#define _coinsys_shop_included

forward CoinShopItemSelected(id, iItem)
native coinsys_shop_register_item(szName[33], szInfo[128], iCost, iLimit = 0, iAlive = -1, bool:bAdminsOnly = false, AdminFlag = 0)