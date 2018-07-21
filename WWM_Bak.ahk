;==============================================================================
;备份还原相关动作：
;~ #Include WWM_Bak.ahk
;==============================================================================
;线程：失去时效备份目录的删除（启动时执行一次）：
CheckBakifOutTime:
	Gui, Submit, NoHide
	Gui MainGui:+OwnDialogs ;各种对话框的从属
	BackUpTimeLimit:= (BackUPMod=1)?-100000		;不备份
									:(BackUPMod=2)?1		;保存1天
									:(BackUPMod=3)?7		;保存7天
									:(BackUPMod=4)?30		;保存30天
									:(BackUPMod=5)?100000		;永久保存
									:0
	NowTime:=A_now
	Loop, Files, %BackupFolder%\*, D ;备份文件夹内循环
	{
		EnvSub, NowTime, A_LoopFileTimeCreated, D  ;时间比较
		if (NowTime>BackUpTimeLimit) ;超时的备份文件
		{
			if (ifWarnWhenDelBak=1) ;开启删除警告时
			{
				MsgBox, 52, 删除过期备份确认, % "备份文件"""A_LoopFileName """已过期，是否删除?"
				IfMsgBox, No  ;取消
					continue
			}
			FileRemoveDir, %A_LoopFileLongPath%, 1 ;删除
		}
	}
;线程：当备份文件夹空了的时候删除文件夹 并 禁用按钮！
RemoveBakDir:
	FileCreateDir, %BackupFolder%  ;为了让下面的ErrorLevel正确的计算.... 非完美方案
	FileRemoveDir, %BackupFolder%, 0  ;移除空备份文件夹
	Menu, MUBackUp, % ErrorLevel?"Enable":"Disable", % MUNameBak[9]    ;ErrorLevel表明了文件夹内是否为空，为空的时候按钮禁用
	Try, Menu, MUBackUp, Rename, % MUNameBak[9], % MUNameBak[9]:="备份库(" FolderGetSize(BackupFolder,"m") "MB)"   ;菜单：备份库重命名  （需要加Try）
return


;进入自动备份gui列表
BTtoBakA:
	;gui切换需要的指令
	Gui MainGui:+Disabled ;主窗口禁用
	Gui BakGui:Show
	Gui BakGui:Default ;设置MklinkGui窗口为默认gui
	gosub, RenewLVBak ;刷新LVBak
return
;从备份gui时返回主界面
BakGuiGuiEscape:
BakGuiGuiClose:
	;gui切换需要的指令
	Gui BakGui:Hide
	Gui MainGui:-Disabled    ;主窗口启用
	Gui MainGui:Default    ;设置MainGui窗口为默认gui
	WinActivate, ahk_id %hMainGui%    ;激活主窗口
	;其他工作
	gosub, BTRenewA    ;刷新
	gosub, RemoveBakDir    ;尝试移除文件夹线程
return

;线程：将备份信息导入LV
RenewLVBak:
	Gui, ListView, %hLVBak% ;选择操作表
	LV_Delete()  ; 清理 ListView
	GuiControl, -Redraw, %hLVBak%  ; 在加载时禁用重绘来提升性能.
	Loop, Files, %BackupFolder%\*, D ;备份文件夹内循环
	{
		FormatTime, BackUpTime, %A_LoopFileTimeCreated%, yyyy/MM/dd HH:mm:ss
		LV_Add(, SubStr(A_LoopFileName,1,instr(A_LoopFileName," -- ")-1), BackUpTime) ;添加到列表里
	}
	LV_ModifyCol()  ;调整第1列宽
	GuiControl, +Redraw, %hLVBak%  ; 重新启用重绘 (上面把它禁用了).
return
;变动备份gui列表时的动作
LVBakA:
	LV_GetText(RestoreAccount, LV_GetNext(), 1)	;获取备份账号
	LV_GetText(RestoreTime, LV_GetNext(), 2)	;获取备份时间
	RestorePath:=BackupFolder "\" RestoreAccount " -- " DateParse(RestoreTime)		;选取的备份文件的路径
	GuiControl, % "Enable" LV_GetNext(), BTRestore ;列表选择了文件，还原按钮才会显示出来
return
;还原备份按钮：
BTRestoreA:
	Gui BakGui:+OwnDialogs ;各种对话框的从属
	MsgBox, 49,, % "是否还原" RestoreAccount "(" RestoreTime ")?`n该账号下现有设置将会因被备份设置覆盖而丢失!"
	IfMsgBox, Cancel	;取消
		return
	FolderCopyEx(A_WorkingDir "\" RestorePath, A_WorkingDir "\" SubStr(RestoreAccount,1,InStr(RestoreAccount,"[")-1))     ;强力复制函数（需要完整路径）
	FileRemoveDir, % RestorePath, 1    ;删除备份
	;主GUI界面的变动：
	Gui MainGui:Default ;设置MklinkGui窗口为默认gui
		;刷新左右列表
		RenewWTFLV(hLVL,cLVL,IncdStrL,NotIncdStrL) ;左筛选刷新
		RenewWTFLV(hLVR,cLVR,IncdStrR,NotIncdStrR) ;右筛选刷新
		;刷新目录联接状态按钮
		if MklinkList.Delete(RestoreAccount)	;删除键 同时 如果该键存在时
		{
			MklinkList_fail[RestoreAccount] := 0		;失效的mklink列表增加
			GuiControl,, BTtoLink, % "目录联接状态(" GetArrayLength(MklinkList) ")"	;按钮名称变更联接个数
			GuiControl, % GetArrayLength(MklinkList)?"Enable":"Disable" , BTtoLink		;目录联接表的启用或禁用
		}
	Gui BakGui:Default ;设置MklinkGui窗口为默认gui
	;刷新列表 禁用按钮
	GuiControl, Disable, BTRestore ;禁用按钮
	gosub, RenewLVBak ;刷新LVBak
return