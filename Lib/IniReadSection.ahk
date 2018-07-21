;读取ini中的某一节信息   返回为 key:=value 的关联数组   （暂时不能屏蔽注解）
IniReadSection(IniPath,Section) 
{ 
	Keys:=[]
	Loop, Read, %IniPath%    ;逐行读取ini信息
	{
		if inStr(A_LoopReadLine,"=") and mark    ;中间内容区
			Keys[SubStr(A_LoopReadLine,1,InStr(A_LoopReadLine,"=")-1)] := SubStr(A_LoopReadLine,InStr(A_LoopReadLine,"=")+1)
		else if ( A_LoopReadLine~="^\[" . Section . "]" and mark!=1 )    ;起始位置
			mark:=1	
		else if ( A_LoopReadLine~="^\[.*]" and mark=1 )    ;终止位置
			break
	}
	return Keys
}