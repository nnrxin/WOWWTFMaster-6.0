;切换Tab动作
ChgMainTabA:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	Gui, Submit, NoHide
	SB_SetText("切换到: " MainTabName[MainTab])
	;宏管理标签
	if (MainTab=3)
		RenewWTFLV(hLVMacroSel,cLVMacroSel,IncdStrMacroSel,NotIncdStrMacroSel)    ;宏角色选择筛选刷新
	else
	{
		if (MainTab=2) and (WinExist("ahk_exe Wow.exe") or WinExist("ahk_exe Wow-64.exe"))      ;标签：游戏设置
			MsgBox 检测到魔兽世界窗口,请完全退出游戏后再来修改游戏设置!
		GuiControl,, EDMacro,    ;清空宏指令内容
		Gui, ListView, LVMacro    ;选择操作表
		LV_Delete()    ;清理 ListView
	}
return



/*
;刷新下拉框函数
RenewDDLMacro(FindStr:="")
{
	global CharacterList
	GuiControl,, DDLMacro, |
	Loop, % CharacterList.Length()    ;角色数组内循环
	{
		if InStr(newline:=CharacterList[A_index,3] "-" CharacterList[A_index,2] "(" CharacterList[A_index,1] ")", FindStr)
			GuiControl,, DDLMacro, % newline
	}
}
*/

;==============================================================================
;主面板的控件动作指令_Tab1：
;~ #Include WWM_MainGUICtrl.ahk
;==============================================================================
;筛选动作
FilterA:
	;禁用了刷新时直接返回
	if not RenewLVByFilter
		return
	;开始动作
	Gui, Submit, NoHide
	if (A_GuiControl="IncdStrL" or A_GuiControl="NotIncdStrL")
		RenewWTFLV(hLVL,cLVL,IncdStrL,NotIncdStrL)    ;左筛选刷新
	else if (A_GuiControl="IncdStrR" or A_GuiControl="NotIncdStrR")
		RenewWTFLV(hLVR,cLVR,IncdStrR,NotIncdStrR)    ;右筛选刷新
	else if (A_GuiControl="IncdStrMacroSel" or A_GuiControl="NotIncdStrMacroSel")
		RenewWTFLV(hLVMacroSel,cLVMacroSel,IncdStrMacroSel,NotIncdStrMacroSel)    ;宏角色选择筛选刷新
return

;右侧列表全选/全取消
LVRFastchooseA:
	Gui, ListView, %hLVR%    ;选择右侧操作表
	if (A_GuiControl="ChooseAllLVR")
		LV_Modify(0, "Check")
	else if (A_GuiControl="CancelAllLVR")
		LV_Modify(0, "-Check")
	gosub, LVRAfterChoose    ;选择后动作
	Gui, Submit, NoHide
	;按钮激活控制
	GuiControl, % "Enable" (ChooseL!="" && ChooseR!="" && CopyItem1+CopyItem2+CopyItem3+CopyItem4+CopyItem5+CopyItem6+CopyItem7+CopyItem8!=0), BTCopy ;列表同时选取了两侧的选择了文件，还要选择了一个覆盖项，按钮才会显示出来
	GuiControl, % "Enable" (ChooseL!="" && ChooseR!=""), BTSyn ;列表同时选取了两侧的选择了文件，按钮才会显示出来
return


;深度刷新按键
BTRenewA:
	Gui, Submit, NoHide
	gosub, GetCharacterList    ;从硬盘获取角色信息列表
	sleep 300
	RenewWTFLV(hLVL,cLVL,IncdStrL,NotIncdStrL)    ;左列表刷新
	RenewWTFLV(hLVR,cLVR,IncdStrR,NotIncdStrR)    ;右列表刷新
	GuiControl, Focus, BTCopy
	GuiControl, Disable, % hBTRenew
	SetTimer, EnabledBTRenew, -1000
return
;恢复刷新按键
EnabledBTRenew:
	GuiControl, Enable, % hBTRenew
return


;打开英雄榜按钮
BTOpenWebA:
	Gui, Submit, NoHide
	if ClassInfo[ChooseL]
	{
		if (WTFportal="CN" and WoWHttp_Status())
			Run % "http://www.battlenet.com.cn/wow/zh/character/" SubStr(ChooseL,InStr(ChooseL,"-")+1) "/" SubStr(ChooseL,1,InStr(ChooseL,"-")-1) "/advanced"    ;国服战网地址
		else if WoWHttp_Status(WTFportal)
			Run % "http://" portal ".battle.net/wow/en/character/" SubStr(ChooseL,InStr(ChooseL,"-")+1) "/" SubStr(ChooseL,1,InStr(ChooseL,"-")-1) "/advanced"    ;非国服战网地址
	}
return


;选择覆盖项
ChooseCopyItem:
	Gui, Submit, NoHide
	GuiControl, % "Enable" (ChooseL!="" && ChooseR!="" && CopyItem1+CopyItem2+CopyItem3+CopyItem4+CopyItem5+CopyItem6+CopyItem7+CopyItem8!=0), BTCopy ;列表同时选取了两侧的选择了文件，还要选择了一个覆盖项，按钮才会显示出来
return

;刷新listview,IncdStr可以设定出筛选的字符
RenewWTFLV(LVHwnd,cLV:="",IncdStr:="",NotIncdStr:="")
{
	Gui, ListView, %LVHwnd%    ;选择操作表
	LV_Delete()    ;清理 ListView
	LV_SetImageList(ImageListID)    ;把图像列表指定给当前的 ListView.
	GuiControl, -Redraw, %LVHwnd%    ;在加载时禁用重绘来提升性能.
	;账号循环：
	Loop, % CharacterList.Length()    ;角色数组内循环
	{
		Account:=CharacterList[A_index,1]    ;账号
		CharacterFull:=CharacterList[A_index,3] "-" CharacterList[A_index,2]    ;角色-服务器
		RealAccount:=CharacterList[A_index,4]    ;真实账号
		RealCharacterFull:=Trim(CharacterList[A_index,6] "-" CharacterList[A_index,5], "-")    ;真实角色-服务器
		;筛选功能
		if (IncdStr!="" and !InStr(Account "`r`n" CharacterFull "`r`n" ClassInfo[CharacterFull], IncdStr))    ;不包含“包含文字”时，跳过
		or (NotIncdStr!="" and InStr(Account "`r`n" CharacterFull "`r`n" ClassInfo[CharacterFull], NotIncdStr))    ;包含“不包含文字”时，跳过
			continue
		;添加到表格
		LV_Add("Icon" . WoW_ClassInfo(ClassInfo[CharacterFull]).Number, CharacterFull, Account,  RealCharacterFull, RealAccount)
		;单元格染色
		if cLV
		{
			BCol:=WoW_ClassInfo(ClassInfo[CharacterFull]).Color    ;默认背景颜色=职业颜色
			TCol:=0x1A0F09    ;默认文字颜色=深棕
			cLV.Cell(LV_GetCount(), 1, RealCharacterFull?TCol:BCol, RealCharacterFull?BCol:TCol)    ;角色存在联接目录时背景为职业颜色
			cLV.Cell(LV_GetCount(), 2, RealAccount?TCol:0xE0E0E0, RealAccount?0xE0E0E0:TCol)    ;账号存在联接目录时背景染色
		}
	}
	;调整行宽
	LV_LimitColWidth(LVHwnd,1,150)
	LV_LimitColWidth(LVHwnd,2,100)
	LV_ModifyCol(3,0)    ;隐藏列3
	LV_ModifyCol(4,0)    ;隐藏列4
	GuiControl, +Redraw, %LVHwnd%  ; 重新启用重绘 (上面把它禁用了).
}

;主列表的选择动作：
LVMainA: 
	Gui, ListView, % A_GuiControl    ;选择操作表
	LV_GetText(Character_Realm, LV_GetNext(), 1)    ;获取角色-服务器
	LV_GetText(Account, LV_GetNext(), 2)    ;获取服务器
	LV_GetText(SynCharacter_Realm, LV_GetNext(), 3)    ;获取同步源 角色-服务器
	LV_GetText(SynAccount, LV_GetNext(), 4)    ;获取同步源 服务器
	if LV_GetNext()
	{
		if (A_GuiControl="LVL" and A_GuiEvent="I")    ;项目发生了变化
		{
			GuiControl,, ChooseL, % Character_Realm    ;左边最终确认
			AccountL:=Account
			RealmL:=SubStr(Character_Realm,InStr(Character_Realm,"-")+1)
			CharacterL:=SubStr(Character_Realm,1,InStr(Character_Realm,"-")-1)
			SB_SetText("源角色选择为: " CharacterL "-" RealmL)
		}
		else if (A_GuiControl="LVR" and A_GuiEvent="Normal")
		{
			LV_Modify(LV_GetNext(), (LV_GetNext(LV_GetNext()-1, "Checked")=LV_GetNext())?"-Check":"Check")    ;控制开关
			gosub, LVRAfterChoose    ;右侧列表选择后动作
		}
		Gui, Submit, NoHide
		;提示框相关
		if (A_GuiEvent="Normal")    ;点击到了联接目录项
			ToolTip % Trim((SynAccount?"`n账号同步源:" SynAccount:"") . (SynCharacter_Realm?"`n角色同步源:" SynCharacter_Realm:""), "`n")
	}
	;按钮激活控制
	GuiControl, % "Enable" (ChooseL!="" && ChooseR!="" && CopyItem1+CopyItem2+CopyItem3+CopyItem4+CopyItem5+CopyItem6+CopyItem7+CopyItem8!=0), BTCopy ;列表同时选取了两侧的选择了文件，还要选择了一个覆盖项，按钮才会显示出来
	GuiControl, % "Enable" (ChooseL!="" && ChooseR!=""), BTSyn ;列表同时选取了两侧的选择了文件，按钮才会显示出来
return
;右边列表选择完成后执行的动作
LVRAfterChoose:
	;每次搜索前初始化
	RowNumber:=pp:=0
	lvrtxt:=AccountR:=RealmR:=CharacterR:=""
	AccountR:=[]
	RealmR:=[]
	CharacterR:=[]
	;循环查找选中的项
	Loop
	{
		RowNumber := LV_GetNext(RowNumber,"C")  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(Character_Realm, RowNumber, 1)    ;获取角色-服务器
		LV_GetText(Account, RowNumber, 2) ;获取服务器
		AccountR[++pp]:=Account
		RealmR[pp]:=SubStr(Character_Realm,InStr(Character_Realm,"-")+1)
		CharacterR[pp]:=SubStr(Character_Realm,1,InStr(Character_Realm,"-")-1)
		lvrtxt.= Character_Realm "; "
	}
	;界面变动
	GuiControl,, ChooseRtxt, % "目标角色(" pp ")" ;右边最终确认前标题
	GuiControl,, ChooseR, % Trim(lvrtxt,"; ")  ;右边最终确认
	SB_SetText("目标角色选择为(" pp "): " Trim(lvrtxt,"; "))
return



;==============================================================================
;主面板的控件动作指令_Tab2：
;~ #Include WWM_MainGUICtrl.ahk
;==============================================================================

;设置游戏配置的执行动作
CBSetConfigA:
	Gui MainGui:+Disabled	;主窗口禁用
	Gui, Submit, NoHide
	GuiControlGet, wtfCodeState, , %A_GuiControl%
	SB_SetText( ((wtfCodeState=1)?"开启 ":"关闭 ") . wtfCode[A_GuiControl,2] "[" A_GuiControl "]")
	FileGetTime, LastModifiedTime, % WoWFolder "\WTF\Config.wtf"
	Configwtf.Set(A_GuiControl,wtfCodeState)		;保存设置到wtf文件中
	;循环等待修改完成
	loop    
	{
		sleep, 100
		FileGetTime, NowModifiedTime, % WoWFolder "\WTF\Config.wtf"
	} until (NowModifiedTime!=LastModifiedTime)
	Gui MainGui:-Disabled	;主窗口启用
return


;==============================================================================
;主面板的控件动作指令_Tab3：
;~ #Include WWM_MainGUICtrl.ahk
;==============================================================================
/*
;下拉框动作
DDLMacroA:
	Gui, Submit, NoHide
	GuiControl,, EDMacro,    ;清空宏指令内容
	
	PublicMacros:=new WowMacro( RegExReplace(DDLMacro,"^.*\(|\)$") "\macros-cache.txt" )
	ExclusiveMacros:=new WowMacro( RegExReplace(DDLMacro,"^.*\(|\)$") "\" RegExReplace(DDLMacro,"^.*-|\(.*$") "\" RegExReplace(DDLMacro,"-.*$") "\macros-cache.txt" )
	RenewMacroLV(hLVMacro,PublicMacros)    ;刷新列表
return
*/
;选取角色
LVMacroSelA:
	Gui, ListView, % A_GuiControl    ;选择操作表
	if LV_GetNext()
	{
		;刷新列表
		if (A_GuiEvent="I")
		{
			GuiControl,, EDMacro,    ;清空宏指令内容
			;读取信息
			LV_GetText(Character_Realm, LV_GetNext(), 1)    ;获取角色-服务器
			LV_GetText(Account, LV_GetNext(), 2)    ;获取服务器
			LV_GetText(SynCharacter_Realm, LV_GetNext(), 3)    ;获取同步源 角色-服务器
			LV_GetText(SynAccount, LV_GetNext(), 4)    ;获取同步源 服务器
			;信息处理
			AccountMacro:=Account
			RealmMacro:=SubStr(Character_Realm,InStr(Character_Realm,"-")+1)
			CharacterMacro:=SubStr(Character_Realm,1,InStr(Character_Realm,"-")-1)
			SB_SetText("角色选择为: " CharacterMacro "-" RealmMacro)
			;预加载文件
			PublicMacros:=new WowMacro( AccountMacro "\macros-cache.txt" )
			ExclusiveMacros:=new WowMacro( AccountMacro "\" RealmMacro "\" CharacterMacro "\macros-cache.txt" )
			GuiControlGet, IfEnabled_BTtoPublic, Enabled, BTtoPublic    ;获取按钮共用是否禁用
			RenewMacroLV( hLVMacro, IfEnabled_BTtoPublic?ExclusiveMacros:PublicMacros )    ;刷新列表
			Gui, Submit, NoHide
		}
		;提示框相关
		if (A_GuiEvent="Normal")    ;点击到了联接目录项
			ToolTip % Trim( (SynAccount?"`n账号同步源:" SynAccount:"") . (SynCharacter_Realm?"`n角色同步源:" SynCharacter_Realm:""), "`n")
	}
return
;刷新listview,IncdStr可以设定出筛选的字符
RenewMacroLV(LVHwnd,WhichMacro)
{
	Gui, ListView, %LVHwnd%    ;选择操作表
	LV_Delete()    ;清理 ListView
	LV_SetImageList(MacroImageListID)    ;把图像列表指定给当前的 ListView.
	GuiControl, -Redraw, %LVHwnd%    ;在加载时禁用重绘来提升性能.
	;循环添加：
	for i in WhichMacro.Part
		LV_Add("Icon1", i, WhichMacro.Get(i).Name)
	;调整行宽
	LV_ModifyCol(1,40) 
	LV_ModifyCol(2) 
	GuiControl, +Redraw, %LVHwnd%  ; 重新启用重绘 (上面把它禁用了).
}

;变更宏列表
ChgMacroMod:
	GuiControl, Disable, %A_GuiControl%    ;禁用按键
	GuiControl,, EDMacro,    ;清空宏指令内容
	if (A_GuiControl="BTtoPublic")
	{
		RenewMacroLV(hLVMacro,PublicMacros)    ;刷新列表
		GuiControl, Enable, BTtoExclusive
	}
	else if (A_GuiControl="BTtoExclusive")
	{
		RenewMacroLV(hLVMacro,ExclusiveMacros)    ;刷新列表
		GuiControl, Enable, BTtoPublic
	}		
return

;宏LV动作
LVMacroA:
	if (A_GuiEvent="I")
	{
		Gui, ListView, LVMacro    ;选择操作表
		LV_GetText(NowNum, LV_GetNext(), 1)    ;获取序号
		GuiControlGet, IfEnabled_BTtoPublic, Enabled, BTtoPublic    ;获取按钮共用是否禁用
		if IfEnabled_BTtoPublic    ;专用宏
			GuiControl,, EDMacro, % ExclusiveMacros.Get(NowNum).Macro
		else    ;私用宏
			GuiControl,, EDMacro, % PublicMacros.Get(NowNum).Macro
	}
return
