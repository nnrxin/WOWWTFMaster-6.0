#NoEnv
#NoTrayIcon
#MaxThreads 100    ;最大线程数量
#Include <Class_LV_Colors>    ;列表颜色控制
#Include <Class_ImageButton>    ;包含图片按键类
#Include <Class_WowConfig>    ;wow配置的操作类
#Include <Class_WowAddOnSave>    ;wow插件lua存档的操作类
#Include <Class_WowMacro>    ;wow宏文件操作类

;~ FileEncoding, CP54936    ;ANSI强制使用GB18030
OnExit, Saveini ;退出时保存设置信息

;版本变动，临时移动用
FileMoveDir, % A_MyDocuments "\WOWFastSetting", % A_AppData "\WOWWTFMaster", 2
;最先判断是否是管理员身份运行
if !A_IsAdmin
{
	MsgBox, 52, 非管理员身份运行,同步功能将会受限,是否以管理员身份运行?
	IfMsgBox, Yes
	{
        Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
		DoNotToSave:=1
        ExitApp
	}
}

;==============================================================================
;设置与参数读取 图标的安装：
;==============================================================================
;参数的设置读取

global DataFolder     := A_AppData "\WOWWTFMaster" ;wow目录地址保存信息文件夹
,Datafile                     := DataFolder "\data.ini"  ;wow目录地址保存信息ini
,BackupFolder           := "WFS的自动备份"  ;备份文件夹的名字（工作目录下）
,RenewLVByFilter      :=0    ;禁用筛选刷新
,IncdStrL                    := IniRead(Datafile,"Settings", "IncdStrL", A_Space)	 ;读取上次左包含
,IncdStrR                    := IniRead(Datafile,"Settings", "IncdStrR", A_Space)	 ;读取上次右包含
,IncdStrMacroSel       := IniRead(Datafile,"Settings", "IncdStrMacroSel", A_Space)	 ;读取上次宏包含
,NotIncdStrL              := IniRead(Datafile,"Settings", "NotIncdStrL", A_Space)    ;读取上次左排除
,NotIncdStrR              := IniRead(Datafile,"Settings", "NotIncdStrR", A_Space)    ;读取上次右排除
,NotIncdStrMacroSel := IniRead(Datafile,"Settings", "NotIncdStrMacroSel ", A_Space)    ;读取上次宏排除
,CopyItem                  := IniRead(Datafile,"Settings", "CopyItem", 11111111)	 ;读取覆盖项
,BackUPMod              := IniRead(Datafile,"Settings", "BackUPMod", 3)		;读取备份模式 默认7天
,ifWarnWhenDelBak  := IniRead(Datafile,"Settings", "ifWarnWhenDelBak", 1)	 ;读取是否在删除过期备份时警告 默认打开
,CharacterList            := []    ;硬盘所有角色列表
,ClassInfo                   := IniReadSection(Datafile,"ClassInfo")    ;读取职业信息
,ToolTipTxt                :={BTOpenWeb:"打开英雄榜"}


;安装图标文件
;界面图片
FileCreateDir, % DataFolder "\icons\gui"    ;创建文件夹
FileInstall, icons\gui\WoW.png, % DataFolder "\icons\gui\WoW.png"    ;图片按钮
FileInstall, icons\gui\WoWp.png, % DataFolder "\icons\gui\WoWp.png"    ;图片按钮

;宏图标
FileCreateDir, % DataFolder "\icons\macroicon"    ;创建文件夹
FileInstall, icons\macroicon\INV_Misc_QuestionMark.ico, % DataFolder "\icons\macroicon\INV_Misc_QuestionMark.ico"
;职业图标图片列表的创建
global MacroImageListID := IL_Create(10)  ; 创建加载 1 个小图标列表
IL_Add(MacroImageListID, DataFolder "\icons\macroicon\INV_Misc_QuestionMark.ico")

;职业图标
FileCreateDir, % DataFolder "\icons\classicon"    ;创建文件夹
FileInstall, icons\classicon\1.ico, % DataFolder "\icons\classicon\1.ico"
FileInstall, icons\classicon\2.ico, % DataFolder "\icons\classicon\2.ico"
FileInstall, icons\classicon\3.ico, % DataFolder "\icons\classicon\3.ico"
FileInstall, icons\classicon\4.ico, % DataFolder "\icons\classicon\4.ico"
FileInstall, icons\classicon\5.ico, % DataFolder "\icons\classicon\5.ico"
FileInstall, icons\classicon\6.ico, % DataFolder "\icons\classicon\6.ico"
FileInstall, icons\classicon\7.ico, % DataFolder "\icons\classicon\7.ico"
FileInstall, icons\classicon\8.ico, % DataFolder "\icons\classicon\8.ico"
FileInstall, icons\classicon\9.ico, % DataFolder "\icons\classicon\9.ico"
FileInstall, icons\classicon\10.ico, % DataFolder "\icons\classicon\10.ico"
FileInstall, icons\classicon\11.ico, % DataFolder "\icons\classicon\11.ico"
FileInstall, icons\classicon\12.ico, % DataFolder "\icons\classicon\12.ico"
;职业图标图片列表的创建
global ImageListID := IL_Create(12)  ; 创建加载 12 个小图标的图像列表.
Loop 12  ; 把 DLL 中的一系列图标装入图像列表.
    IL_Add(ImageListID, DataFolder "\icons\classicon\" A_Index ".ico")



;==============================================================================
;界面构建：
#Include WWM_GUI.ahk
;==============================================================================


;确定工作目录位置
if not (WoWFolder:=IniRead(Datafile,"Root", "WoWRoot",A_Space))    ;读取目录失败
	gosub, FirstTimeToGetPath	;选择寻址方式

;GUi显示界面初始化
gosub, InitMainGui	


;失去时效备份目录的删除
gosub, CheckBakifOutTime

;消息监听 待填
OnMessage(0x200, "WM_MOUSEMOVE")    ;鼠标移动
;鼠标移动
WM_MOUSEMOVE(wParam, lParam)    ;鼠标移动
{
	global WM_oldGuiControl, ToolTipTxt 
	if ToolTipTxt[A_GuiControl]
	{
		if (A_GuiControl!=WM_oldGuiControl)
		{
			ToolTip % ToolTipTxt[A_GuiControl]
			sleep, 50
			WM_oldGuiControl:=A_GuiControl
		}
	}
	else if ( A_GuiControl!="LVL" and A_GuiControl!="LVR" and A_GuiControl!="LVMacroSel" )
	{
		ToolTip
		WM_oldGuiControl:=""
	}
}

return ;;启动自动执行段结束=============================================================
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;==============================================================================
;初始化：
;==============================================================================
;GUI界面的初始化(前提是确定好了工作目录)
InitMainGui:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	
	SetWorkingDir, % WoWFolder "\WTF\Account"    ;设置工作目录***
	Configwtf:=new WowConfig(WoWFolder "\WTF\Config.wtf")    ;配置信息导入
	global WTFportal := Configwtf.Get("portal","CN")    ;获取在哪个游戏大区
	Gui MainGui:Default
	Gui MainGui:+Disabled	;主窗口禁用
	gosub, GetCharacterList    ;从硬盘获取角色信息列表
	gosub, GetClassFromHttp    ;获取角色的职业##############################################################################需联网
	;菜单项的更新
	Try, Menu, MUFolder, Rename, % MUNameFolder[1], % MUNameFolder[1]:="当前目录: " WoWFolder    ;菜单：路径变更  （需要加Try）
	Menu, MUBackUp, Check, % MUNameBak[BackUPMod]		;菜单：备份保存天数
	Menu, MUBackUp, % ifWarnWhenDelBak?"Check":"Uncheck", % MUNameBak[7]    ;保存的是否警告
	;按钮的初始化
	Loop 8
		GuiControl,, CopyItem%A_Index%, % SubStr(CopyItem,A_index,1)    ;复选框：覆盖项
	gosub, RemoveBakDir    ;尝试移除文件夹线程（可以变更按钮）
	;列表菜单的初始化
	GuiControl,, ChooseL,    ;左边最终确认 清空
	GuiControl,, ChooseR,    ;右边最终确认 清空	
	;Tab2中复选框
	for wtfCodeName, wtfCodeValue in wtfCode
		GuiControl,, %wtfCodeName%, % Configwtf.Get(wtfCodeName,wtfCodeValue[1])

	;读取上次内容（但是不刷新！！！）
	RenewLVByFilter:=0    ;暂时关闭自动刷新
	GuiControl,, IncdStrL, %IncdStrL%    ;左包含历史
	GuiControl,, IncdStrR, %IncdStrR%    ;右包含历史
	GuiControl,, IncdStrMacroSel, %IncdStrMacroSel%    ;宏选择包含历史
	GuiControl,, NotIncdStrL, %NotIncdStrL%    ;左排除历史
	GuiControl,, NotIncdStrR, %NotIncdStrR%    ;右排除历史
	GuiControl,, NotIncdStrMacroSel, %NotIncdStrMacroSel%    ;宏选择排除历史
	sleep, 300    ;等待上面6条指令完成
	RenewLVByFilter:=1    ;打开关闭自动刷新	
	
	;保存控件内容到变量  刷新列表
	Gui, MainGui:Submit, NoHide
	RenewWTFLV(hLVL,cLVL,IncdStrL,NotIncdStrL)    ;左列表刷新
	RenewWTFLV(hLVR,cLVR,IncdStrR,NotIncdStrR)    ;右列表刷新
	;游戏配置非本地化时提醒修改
	if synchronizeSettings
	{
		MsgBox, 52,, 当前Config.wtf文件中synchronizeSettings=1`r`n系统设置、宏和按键将同步到服务器端,造成复制失败,是否改为本地化保存?
		IfMsgBox, Yes
		{
			Configwtf.Set("synchronizeSettings",0)		;保存设置到wtf文件中
			GuiControl,, synchronizeSettings, 0
		}
	}
	SB_SetText("魔兽世界目录: " WoWFolder)
	Gui MainGui:-Disabled	;主窗口启用
	
	
	;版本变动，临时移动用
	;~ FileMoveDir, % A_MyDocuments "\WOWFastSetting", % A_AppData "\WOWWTFMaster", 2
return


;扫描硬盘信息，获取账号列表
GetCharacterList:
	;清空再创建出数组
	CharacterList:=""
	CharacterList:=[]
	;文件夹扫描
	Loop, Files, *, D    ;文件夹WTF\Account内循环``
	{
		if (A_LoopFileName=BackupFolder)    ;备份文件夹时跳过
		or IsReparsePoint(A_LoopFileLongPath)    ;为联接文件夹时跳过
			continue
		Account:=A_LoopFileName    ;账号文件夹名称
		;分析账号下SavedVariables的实际地址
		if IsReparsePoint(A_LoopFileLongPath "\SavedVariables")    ;是联接目录 
		{
			if (RealPath:=GetFinalPath(A_LoopFileLongPath "\SavedVariables"))    ;联接目录没有失效时
			{
				SplitPath, RealPath,, RealAccountPath    ;地址解析：实际账号地址
				SplitPath, RealAccountPath, RealAccount    ;地址解析：实际账号名
			}
			else    ;联接目录失效时删除该目录
				FileRemoveDir, % A_LoopFileLongPath "\SavedVariables", 1
		}
		else
			RealAccount:=""    ;正常文件夹
		;服务器-角色循环：
		Loop, Files, %A_LoopFileLongPath%\*, D ;文件夹WOW\WTF\Account\某账号内循环
		{
			if ((Realm:=A_LoopFileName)="SavedVariables") ;服务器名称(排除SavedVariables)
				continue
			Loop, Files, %A_LoopFileLongPath%\*, D ;文件夹WOW\WTF\Account\某账号\某服务器内循环
			{
				if ((Character:=A_LoopFileName)="(null)") ;角色名称(排除(null))
				or (LimitStr!="" and !InStr(Account "`n" Realm "`n" Character, LimitStr))  ;文字筛选功能
					continue
				;联接文件夹的处理
				if IsReparsePoint(A_LoopFileLongPath)    ;是联接目录
				{
					if (RealPath:=GetFinalPath(A_LoopFileLongPath))     ;联接目录没有失效时
					{
						SplitPath, RealPath, RealCharacter, RealCharacterFolder    ;地址解析：指向的角色
						SplitPath, RealCharacterFolder, RealRealm   ;地址解析：指向角色坐在服务器
					}
					else     ;联接目录失效时删除该目录
						FileRemoveDir, % A_LoopFileLongPath, 1
				}
				else
					RealCharacter:=RealRealm:=""    ;正常文件夹
				;添加到全部角色数组里
				CharacterList.push([Account,Realm,Character,RealAccount,RealRealm,RealCharacter])    ;返回数组[账号，服务器，角色，真实账号，真实服务器，真实角色]
			}
		}
	}
return

;联网获取职业信息
GetClassFromHttp:
	;判断官网网站是否能连接，不能联网直接跳过
	if not WoWHttp_Status(WTFportal)
		return
	;开始确认需要联网查找的角色的名单
	CharacterList_tf:=""
	CharacterList_tf:=[]
	loop, % CharacterList.Length()
	{
		if not ClassInfo[CharacterList[A_index,3] "-" CharacterList[A_index,2]]    ;当不存在该职业颜色时
			CharacterList_tf.Push([CharacterList[A_index,3], CharacterList[A_index,2]])    ;保存到需要联网查询列表里[1：角色，2：服务器]
	}
	;判断是否有未知角色，全部已知时直接跳过
	if not CharacterList_tf.Length()
		return
	;状态栏变更
	SB_SetParts((MainGui_W-50)*5//9,50,(MainGui_W-50)*4//9)	;状态栏分3部分
	SB_SetProgress(0,3,"show Range0-" CharacterList_tf.Length())
	;开始循环查找，没保存的颜色联网查询
	loop, % CharacterList_tf.Length()
	{
		SB_SetText("联网获取职业信息: " (Character:=CharacterList_tf[A_index,1]) "-" (Realm:=CharacterList_tf[A_index,2]),1)	   ;信息条变更
		SB_SetProgress(A_index,3)	   ;进度条变更
		SB_SetText(Round(A_index*100/CharacterList_tf.Length(),1) "%",2)	    ;百分比变化
		if not ClassInfo[Character "-" Realm]    ;当不存在该职业颜色时
			ClassInfo[Character "-" Realm]:=WoWHttp_GetCharacterClass(Character,Realm,WTFportal)    ;联网获取角色的职业
	}
	;状态栏变更
	SB_SetProgress(0,3,"hide")
	SB_SetParts()	;状态栏合并为1
return

;==============================================================================
;主菜单选项动作：
#Include WWM_GUIMenu.ahk
;==============================================================================

;==============================================================================
;右键菜单：
#Include WWM_RBMenu.ahk
;==============================================================================

;==============================================================================
;备份还原相关动作：
#Include WWM_Bak.ahk
;==============================================================================

;==============================================================================
;游戏目录的定位（包括自动和手动）：
#Include WWM_SetPath.ahk
;==============================================================================

;==============================================================================
;主面板的控件动作指令：
#Include WWM_MainGUICtrl.ahk
;==============================================================================

;==============================================================================
;核心**执行复制/同步动作：
;==============================================================================
BTdoneA:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	Gui, Submit, NoHide
	;同一角色错误
	if (ChooseL=ChooseR) and (AccountL=AccountR)
	{
		MsgBox, 16,, 错误！源角色与目标角色不能相同
		return
	}
	;确认信息
	MsgBoxTxt:=(A_GuiControl="BTCopy")?("是否将<" ChooseL ">的配置覆盖到<" ChooseR ">上?`n请对重要设置进行备份!!!")
						:(A_GuiControl="BTSyn")?("是否将<" ChooseR ">的配置同步到 <" ChooseL "> 上?`n`n同步之后登陆<" ChooseR ">时将读取使用<" ChooseL ">的配置文件，产生的改动也将影响到<" ChooseL ">，反过来也一样。`n`n同步之后<" ChooseR ">账号内其他角色所使用的账号配置也将是<" ChooseL ">所在账号的配置,请将这些角色也进行同步，并且同时对重要设置进行备份!!!")
						:"未知错误,请点否..."
	MsgBox, 52,, % MsgBoxTxt
	IfMsgBox No
		return
	;正式开始复制过程↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
	Gui MainGui:+Disabled	;冻结主窗口
	
	;计时条设置
	Maxpp:=pp:=0
	if (A_GuiControl="BTCopy")    ;复制模式
	{
		if (CopyItem1=1)    ;账号插件
		{
			loop, Files, % AccountL "\SavedVariables\*.lua"
				Maxpp++
		}
		if (CopyItem5=1)    ;角色插件
		{
			loop, Files, % AccountL "\" RealmL "\" CharacterL "\SavedVariables\*.lua"
				Maxpp++
		}
	}
	else if (A_GuiControl="BTSyn")    ;同步模式
	{
		loop, Files, % AccountL "\SavedVariables\*.lua"
			Maxpp++
	}
	Maxpp*=AccountR.Length()
	SB_SetParts((MainGui_W-50)*2//10,(MainGui_W-50)*5//10,50,(MainGui_W-50)*3//10)	;状态栏分2部分
	SB_SetProgress(0,4,"show Range0-" Maxpp)
	
	;开始执行复制动作：
	loop % AccountR.Length()    ;多选复制模式
	{
		i:=A_index      ;循环次数
		SB_SetText(CharacterR[i] "-" RealmR[i],1)    ;状态栏1显示变更
		;跳过完全相同的角色
		if (AccountL=AccountR[i] and RealmL=RealmR[i] and CharacterL=CharacterR[i])
		{
			SB_SetText("源角色重复,跳过",2)
			sleep, 500
			continue
		}
		;复制前的备份
		if (BackUPMod!=1)
			FileCreateDir, % NowBakPath:=BackupFolder "\" AccountR[i] "[" CharacterR[i] "-" RealmR[i]  "] -- " A_Now, 1    ;创建出备份文件夹
		;常规模式复制：
		if (A_GuiControl="BTCopy")    ;复制模式===========================================================================
		{
			;账号文件夹的选择性覆盖
			if (AccountL!=AccountR[i]) ;源账号与目标账号不相同时
			{
				Loop, Files, %AccountL%\*, DF  ;账号文件夹内循环
				{
					if  (A_LoopFileName="SavedVariables" and CopyItem1=0)    ;账号插件
					or (instr(A_LoopFileAttrib,"D") and A_LoopFileName!="SavedVariables")    ;不是"SavedVariables"的文件夹
					or ((A_LoopFileName="macros-cache.txt" or A_LoopFileName="macros-cache.old") and CopyItem4=0)    ;通用宏
					or ((A_LoopFileName="config-cache.wtf" or A_LoopFileName="config-cache.old") and CopyItem2=0)    ;账号设置
					or ((A_LoopFileName="bindings-cache.wtf" or A_LoopFileName="bindings-cache.old") and CopyItem3=0)    ;账号按键
						continue    ;跳过
					if (BackUPMod!=1)
						FolderCopyEx(A_WorkingDir "\" AccountR[i] "\" A_LoopFileName ,A_WorkingDir "\" NowBakPath "\" A_LoopFileName)     ;备份账号文件
					FolderCopyEx(A_LoopFileLongPath, A_WorkingDir "\" AccountR[i] "\" A_LoopFileName)     ;强力复制复制--账号文件
				}
				;账号配置档变更
				if (CopyItem1=1)
					WoW_ChgLuaProfileKeys(AccountR[i] "\SavedVariables", CharacterR[i] " - " RealmR[i], CharacterL " - " RealmL)    ;账号配置档变更
			}
			;角色文件夹的选择性覆盖
			Loop, Files, % AccountL "\" RealmL "\" CharacterL "\*", DF  ;角色文件夹内循环
			{
				if (A_LoopFileName="SavedVariables" and CopyItem5=0)    ;角色插件配置文件夹
				or ((A_LoopFileName="macros-cache.txt" or A_LoopFileName="macros-cache.old") and CopyItem8=0)    ;角色专用宏
				or ((A_LoopFileName="bindings-cache.wtf" or A_LoopFileName="bindings-cache.old") and CopyItem7=0)    ;角色按键
				or (A_LoopFileName="AddOns.txt" and CopyItem5=0)    ;角色插件--插件开关状态
				or ((A_LoopFileName="config-cache.wtf" or A_LoopFileName="config-cache.old") and CopyItem6=0)    ;角色设置
				or (A_LoopFileName="layout-local.txt" and CopyItem6=0)    ;角色设置--头像位置
				or ((A_LoopFileName="chat-cache.txt" or A_LoopFileName="chat-cache.old") and CopyItem6=0)    ;角色设置--聊天框
				or ((A_LoopFileName="CUFProfiles.txt" or A_LoopFileName="CUFProfiles.txt.bak") and CopyItem6=0)    ;角色设置--团队框架
					continue
				if (BackUPMod!=1)
					FolderCopyEx(A_WorkingDir "\" AccountR[i] "\" RealmR[i] "\" CharacterR[i] "\" A_LoopFileName
											,A_WorkingDir "\" NowBakPath "\" RealmR[i] "\" CharacterR[i] "\" A_LoopFileName)     ;备份账号文件
				FolderCopyEx(A_LoopFileLongPath, A_WorkingDir "\" AccountR[i] "\" RealmR[i] "\" CharacterR[i] "\" A_LoopFileName)     ;强力复制复制--角色文件
			}
			;角色插件名字替换
			if (CopyItem5=1)    ;开启了角色插件复制时
				WoW_ChgLua(AccountR[i] "\" RealmR[i] "\" CharacterR[i] "\SavedVariables",RealmL,CharacterL,RealmR[i],CharacterR[i])    ;账号配置lua替换
		}
		else if (A_GuiControl="BTSyn")    ;同步模式复制=========================================================================
		{
			;信息提示
			SB_SetText("正在同步到" CharacterL "-" RealmL "...",2)
			;角色部分
			IfNotEqual, BackUPMod, 1, FileCopyDir, % AccountR[i] "\" RealmR[i] "\" CharacterR[i], % NowBakPath "\" RealmR[i] "\" CharacterR[i], 1    ;备份
			FileRemoveDir, % AccountR[i] "\" RealmR[i] "\" CharacterR[i], 1    ;删除目标 账号\服务器\角色 文件夹
			FileAppend, % "mklink /j " AccountR[i] "\" RealmR[i] "\" CharacterR[i] " " AccountL "\" RealmL "\" CharacterL, ahkmklink.bat    ;账号\服务器\角色  的目录联接
			;账号部分
			if (AccountL!=AccountR[i])    ;不在同一账号下时
			{	
				IfNotEqual, BackUPMod, 1, FileCopyDir, % AccountR[i] "\SavedVariables", % NowBakPath "\SavedVariables", 1    ;备份账号插件
				IfNotEqual, BackUPMod, 1, FileCopy, % AccountR[i] "\config-cache.wtf", % NowBakPath "\config-cache.wtf", 1    ;备份账号设置
				IfNotEqual, BackUPMod, 1, FileCopy, % AccountR[i] "\bindings-cache.wtf", % NowBakPath "\bindings-cache.wtf", 1    ;备份账号按键
				IfNotEqual, BackUPMod, 1, FileCopy, % AccountR[i] "\macros-cache.txt", % NowBakPath "\macros-cache.txt", 1    ;备份账号宏
				FileRemoveDir, % AccountR[i] "\SavedVariables", 1    ;删除目标 账号\SavedVariables 文件夹（账号插件配置）
				FileDelete, % AccountR[i] "\config-cache.wtf"    ;删除目标 账号设置
				FileDelete, % AccountR[i] "\bindings-cache.wtf"    ;删除目标 按键设置
				FileDelete, % AccountR[i] "\macros-cache.txt"    ;删除目标 宏设置
				FileAppend, % "`r`nmklink /j " AccountR[i] "\SavedVariables " AccountL "\SavedVariables", ahkmklink.bat    ;账号\SavedVariables  的目录联接
				FileAppend, % "`r`nmklink /h " AccountR[i] "\config-cache.wtf " AccountL "\config-cache.wtf", ahkmklink.bat    ;账号设置  的文件硬连接
				FileAppend, % "`r`nmklink /h " AccountR[i] "\bindings-cache.wtf " AccountL "\bindings-cache.wtf", ahkmklink.bat    ;账号按键  的文件硬连接
				FileAppend, % "`r`nmklink /h " AccountR[i] "\macros-cache.txt " AccountL "\macros-cache.txt", ahkmklink.bat    ;账号宏  的文件硬连接
			}
			;生成联接文件（夹）
			RunWait, ahkmklink.bat,, Hide    ;运行批处理文件(隐藏)
			sleep, 1000
			FileDelete, ahkmklink.bat    ;删除该批处理文件
			;LUA配置变更
			WoW_ChgLuaProfileKeys(AccountL "\SavedVariables", CharacterR[i] " - " RealmR[i], CharacterL " - " RealmL) ;账号配置档变更
		}
	}
	
	;状态栏进度条恢复
	SB_SetProgress(0,4,"hide")
	SB_SetParts()	;状态栏合并为1
	
	;刷新列表
	gosub, GetCharacterList    ;从硬盘获取角色信息列表
	sleep 300
	Gui, Submit, NoHide
	RenewWTFLV(hLVL,cLVL,IncdStrL,NotIncdStrL) ;左筛选刷新
	RenewWTFLV(hLVR,cLVR,IncdStrR,NotIncdStrR) ;右筛选刷新
	;备份开启的时候启用下按钮
	if (BackUPMod!=1)
	{
		Menu, MUBackUp, Enable, % MUNameBak[9]    ;按钮启用
		Try, Menu, MUBackUp, Rename, % MUNameBak[9], % MUNameBak[9]:="备份库(" FolderGetSize(BackupFolder,"m") "MB)"   ;菜单：备份库重命名
	}
	SB_SetText("覆盖完毕")
	Gui MainGui:-Disabled	;解冻主窗口
	WinActivate, ahk_id %hMainGui%    ;激活主窗口
return

;==============================================================================
;退出部分：
;==============================================================================
;退出时保存
Saveini:
	IfEqual, DoNotToSave, 1, ExitApp
	;保存设置信息：
	IfNotExist, %Datafile% 
	{
		file:=FileOpen(Datafile, "rw")
		file.Close()
	}
	IniWrite, %WoWFolder%, %Datafile%, Root, WoWRoot ;写入游戏目录
	IniWrite, %IncdStrL%, %Datafile%, Settings, IncdStrL    ;写入上次左包含
	IniWrite, %IncdStrR%, %Datafile%, Settings, IncdStrR    ;写入上次右包含
	IniWrite, %IncdStrMacroSel%, %Datafile%, Settings, IncdStrMacroSel    ;写入上次宏包含
	IniWrite, %NotIncdStrL%, %Datafile%, Settings, NotIncdStrL    ;写入上次左排除
	IniWrite, %NotIncdStrR%, %Datafile%, Settings, NotIncdStrR    ;写入上次右排除
	IniWrite, %NotIncdStrMacroSel%, %Datafile%, Settings, NotIncdStrMacroSel    ;写入上次宏排除
	IniWrite, % CopyItem1 CopyItem2 CopyItem3 CopyItem4 CopyItem5 CopyItem6 CopyItem7 CopyItem8, %Datafile%, Settings, CopyItem ;写入覆盖项
	IniWrite, %BackUPMod%, %Datafile%, Settings, BackUPMod    ;写入备份模式
	IniWrite, %ifWarnWhenDelBak%, %Datafile%, Settings, ifWarnWhenDelBak ;写入是否在删除过期备份时警告
	for CharacterFullName, ClassName in ClassInfo
	{
		if ClassName    ;存在职业名称时写入
			IniWrite, %ClassName%, %Datafile%, ClassInfo, %CharacterFullName%    ;写入职业的颜色
	}
ExitApp

MainGuiGuiEscape:
MainGuiGuiClose:
ExitApp