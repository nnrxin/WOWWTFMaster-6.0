;==============================================================================
;右键菜单：
;~ #Include WWM_RBMenu.ahk
;==============================================================================
;在主GUI上右键时动作
MainGuiGuiContextMenu:
	if A_EventInfo ;包含信息时
	{
		return ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 暂时禁用了
		if (NowLV:=A_GuiControl)="LVL" and NowRN:=LV_GetNext()  ;右键到左列表时
		{
			FolderDelPath:=(NowLV="LVL")?AccountL "\" RealmL "\" CharacterL		;左边选取
							         :(NowLV="LVR")?AccountR[NowRN] "\" RealmR[NowRN] "\" CharacterR[NowRN]		;右边选取
							         :"ERROR"		;不能为空 以防下面误删
			Menu, ContextMenu_MainLV, Add 
			Menu, ContextMenu_MainLV, DeleteAll
			Menu, ContextMenu_MainLV, Add, % "删除配置(" FolderDelPath ")", MainLV_DelA
			Menu, ContextMenu_MainLV, Show 
		}	
	}
return
;删除配置-动作
MainLV_DelA:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	MsgBox, 49,, % "删除  " A_WorkingDir "\" FolderDelPath "  ，请确认!!!"
	IfMsgBox, Ok
	{
		FileRemoveDir, %FolderDelPath%, 1 ;彻底删除
		Gui MainGui:Default ;设置MainGui窗口为默认gui
		GuiControl,, ChooseL,  	;左边最终确认 清空
		GuiControl,, ChooseR, 	;右边最终确认 清空
		RenewWTFLV(hLVL,cLVL,IncdStrL,NotIncdStrL) ;左筛选刷新
		RenewWTFLV(hLVR,cLVR,IncdStrR,NotIncdStrR) ;右筛选刷新
		SB_SetText("已删除配置: " FolderDelPath)
	}
return

;在备份库GUI上右键时动作
BakGuiGuiContextMenu:
	if A_EventInfo ;包含信息时
	{
		if ((NowLV:=A_GuiControl)="LVBak")	;右键到两个列表时
		{
			Menu, ContextMenu_BakLV, Add 
			Menu, ContextMenu_BakLV, DeleteAll
			Menu, ContextMenu_BakLV, Add, % "删除备份", BakLV_DelA
			Menu, ContextMenu_BakLV, Show 
		}	
	}
return
;删除备份-动作
BakLV_DelA:
	Gui BakGui:+OwnDialogs ;各种对话框的从属
	MsgBox, 49,, % "删除  " A_WorkingDir "\" RestorePath "  ，请确认!!!"
	IfMsgBox, Ok
	{
		FileRemoveDir, %RestorePath%, 1 ;彻底删除
		Gui BakGui:Default ;设置默认
		GuiControl, Disable, BTRestore ;禁用按钮
		gosub, RenewLVBak ;刷新LVBak
	}
return