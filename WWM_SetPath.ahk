;==============================================================================
;游戏目录的定位（包括自动和手动）：
;~ #Include WWM_SetPath.ahk
;==============================================================================
;首次登陆询问是否自动搜索
FirstTimeToGetPath:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	MsgBox, 4,, 是否使用自动定位wow目录?
	IfMsgBox, Yes
		gosub, AutoGetWoWFolder
	else
		gosub, selectWoWFolder
return

;自动选择魔兽世界位置
AutoGetWoWFolder:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	;先查询注册表
	if (WoWFolder:=GetWoWPathByReg())
	{
		gosub, InitMainGui	;主GUI界面初始化
		return
	}
	;注册表中未发现路径
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	Gui MainGui:+Disabled	;主窗口禁用
	Progress, m2 b c01 fs12 fm12 zh0 CTWhite CWBlue w400, 扫描中 . . ., 自动定位WoW游戏目录, , 微软雅黑		;进度条
	SetTimer, RenewProgress, 50
	WoWFolder_AutoGet := AutoFindPath("WTF","Wow.exe",ProgressSubText)		;搜索wow的函数
	SetTimer, RenewProgress,Off
	Progress, Off
	;不同数量的可用路径分别处理
	if (WoWFolder_AutoGet.Length()=0)	;0个结果时
	{
		MsgBox 自动扫描没有发现wow路径,请手动设置 T_T
		gosub, selectWoWFolder
	}
	else
	{
		WoWFolder:=WoWFolder_AutoGet[1]	;直接设定为目录
		gosub, InitMainGui	;主GUI界面初始化
	}
	Gui MainGui:-Disabled	;主窗口启用
	WinActivate, ahk_id %hMainGui%    ;激活主窗口
return
;进度条更新线程：
RenewProgress: 
	Progress,, %ProgressSubText% ;变更
return

;手动选择魔兽世界位置
selectWoWFolder:
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	FileSelectFolder, newWoWFolder,,, 请选择魔兽世界的游戏目录
	if newWoWFolder	;有效值
	{
		WoWFolder:=newWoWFolder
		gosub, InitMainGui	;主GUI界面初始化
	}
return