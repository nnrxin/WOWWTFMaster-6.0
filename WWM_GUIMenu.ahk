;==============================================================================
;主菜单选项动作：
;~ #Include WWM_GUIMenu.ahk
;==============================================================================
;MainMenu主菜单选项（空）
MenuA:
return

;打开配置保存目录
OpenSaveFolder:
Run % DataFolder
return

;MainMenu主菜单帮助
MUHelpA:
	MsgBox 详情参阅 http://bbs.ngacn.cc/read.php?tid=9550429
return


;Menu自动备份列表的执行动作
MUBackUpA:
	if (A_ThisMenuItemPos <= 5) ;选中的是时效设置部分
	{
		loop 5
		{
			Menu, MUBackUp, Uncheck, % MUNameBak[A_index]		;先全部全否
			if (A_ThisMenuItemPos=A_index)
			{
				Menu, MUBackUp, Check, % MUNameBak[A_index]		;选中的再选是
				BackUPMod:=A_index	;保存模式
				SB_SetText("自动保存切换为: " MUNameBak[A_index])
			}
		}
	}
	else if (A_ThisMenuItemPos = 7) ;选中的是删除过期备份前确认
	{
		Menu, MUBackUp, ToggleCheck, % MUNameBak[7]		;选择切换
		ifWarnWhenDelBak := 1-ifWarnWhenDelBak		;保存信息
		SB_SetText( ((ifWarnWhenDelBak=1)?"开启 ":"关闭 ") MUNameBak[7])
	}
return