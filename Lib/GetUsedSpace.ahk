;获取硬盘总使用量单位：MB
GetUsedSpace(mod:="")
{	
	DriveGet, DriveList, List, FIXED		;获取硬盘所有盘符
	UsedSpace:=0
	Loop % StrLen(DriveList)	;搜索
	{	
		DriveGet, Cap, Capacity, % SubStr(DriveList,A_Index,1) ":\"		;总容量
		DriveSpaceFree, FreeSpace, % SubStr(DriveList,A_Index,1) ":\"		;空闲量
		UsedSpace+=Cap-FreeSpace
	}
	return (mod="KB")?UsedSpace*1024
			:(mod="MB")?UsedSpace
			:(mod="GB")?Round(UsedSpace/1024)
			:UsedSpace*1024**2
}