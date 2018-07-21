
;获取lv的列宽，参数为空时返回数组，有参数时返回某行值
LV_GetColWidth(LVHwnd,ColNum:="")
{
	LVwidth:=[]
	Loop % LV_GetCount("Column")
	{
		SendMessage, 4125, ColNum-1, 0,, ahk_id %LVHwnd%  ; 4125 为 LVM_GETCOLUMNWIDTH.
		if (ColNum=A_Index)
			return ErrorLevel
		else
			LVwidth.push(ErrorLevel)
	}
	return LVwidth
}

;限制lv的到最大列宽，默认 列1 无限制
LV_LimitColWidth(LVHwnd,ColNum:=1,MaxWidth:="")
{
	LV_ModifyCol(ColNum)
	SendMessage, 4125, ColNum-1, 0,, ahk_id %LVHwnd%  ; 4125 为 LVM_GETCOLUMNWIDTH.
	if (MaxWidth and ErrorLevel!="FAIL" and ErrorLevel>MaxWidth)
		LV_ModifyCol(ColNum,MaxWidth)
}