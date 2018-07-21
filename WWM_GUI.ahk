;==============================================================================
;主界面的创建：
;~ #Include WWM_GUI.ahk
;==============================================================================
Gui, MainGui:New, +Disabled +HwndhMainGui
Gui, MainGui:Font,, 微软雅黑

MUNameFolder :=["当前目录:","自动匹配游戏目录","手动匹配游戏目录","打开配置保存文件夹"]    ;菜单：Lua修改
Menu, MUFolder, Add, % MUNameFolder[1], MenuA
Menu, MUFolder, Disable, % MUNameFolder[1]    ;禁用上面按钮
Menu, MUFolder, Add, % MUNameFolder[2], AutoGetWoWFolder
Menu, MUFolder, Add, % MUNameFolder[3], selectWoWFolder
Menu, MUFolder, Add
Menu, MUFolder, Add, % MUNameFolder[4], OpenSaveFolder
Menu, MainMenu, Add, 目录(&F), :MUFolder    ;文件

MUNameBak :=["关闭自动备份","保存1天","保存7天","保存30天","永久保存","","删除过期备份前提示","","备份库()"]	;菜单：自动保存
Menu, MUBackUp, Add, % MUNameBak[1], MUBackUpA
Menu, MUBackUp, Add, % MUNameBak[2], MUBackUpA
Menu, MUBackUp, Add, % MUNameBak[3], MUBackUpA
Menu, MUBackUp, Add, % MUNameBak[4], MUBackUpA
Menu, MUBackUp, Add, % MUNameBak[5], MUBackUpA
Menu, MUBackUp, Add, 
Menu, MUBackUp, Add, % MUNameBak[7], MUBackUpA
Menu, MUBackUp, Add, 
Menu, MUBackUp, Add, % MUNameBak[9], BTtoBakA    ;直接进入备份gui
Menu, MainMenu, Add, 自动备份(&B), :MUBackUp ;自动备份

Menu, MUHelp, Add, 关于, MUHelpA
Menu, MainMenu, Add, 帮助(&H), :MUHelp ;帮助

gui, MainGui:Menu, MainMenu ;添加菜单到gui

Gui, MainGui:Font, bold     ;粗体

;标签建立
MainTabName:=["配置覆盖与同步","游戏设置","宏管理","待填"]
Gui, MainGui:Add, Tab3, w690 h500 c0072E3 AltSubmit gChgMainTabA vMainTab, % MainTabName[1] "|" MainTabName[2] "|" MainTabName[3] "|" MainTabName[4]

;###########################################################################################################################
;选项卡1： 配置覆盖与同步  ####################################################################################################### 
Gui, MainGui:Tab, 1    
;###########################################################################################################################
Gui, MainGui:Add, text, xm+10 ym+40 R1 w30, 包含:
Gui, MainGui:Add, Edit, x+0 yp-3 R1 w100 gFilterA vIncdStrL,  ;左包含
Gui, MainGui:Add, text, x+5 yp+3 R1 w30, 排除:
Gui, MainGui:Add, Edit, x+0 yp-3 R1 w100 gFilterA vNotIncdStrL,  ;左排除

Gui, MainGui:Add, Button, x+140 yp+1 w21 h21 gLVRFastchooseA vChooseAllLVR, √
Gui, MainGui:Add, Button, x+0 yp w21 h21 gLVRFastchooseA vCancelAllLVR, ×
Gui, MainGui:Add, text, x+6 yp+2 R1 w30, 包含:
Gui, MainGui:Add, Edit, x+0 yp-3 R1 w76 gFilterA vIncdStrR,  ;右查找
Gui, MainGui:Add, text, x+5 yp+3 R1 w30, 排除:
Gui, MainGui:Add, Edit, x+0 yp-3 R1 w76 gFilterA vNotIncdStrR,  ;右排除

Gui, MainGui:Add, text, xm+10 y+6 R1 w40, 源角色
Gui, MainGui:Add, Edit, x+5 yp-3 R1 w195 ReadOnly vChooseL c921AFF,  ;左选定
Gui, MainGui:Add, Button, x+2 yp+2 w21 h21 gBTOpenWebA hwndhBTOpenWeb vBTOpenWeb,  ;联接战网的按钮
ImageButton.Create(hBTOpenWeb, [0,DataFolder "\icons\gui\WoW.png"],  [,DataFolder "\icons\gui\WoWp.png"])    ;创建为图片按钮

Gui, MainGui:Add, Button, x+7 yp-2 R1 w130 gBTRenewA vBTRenew HwndhBTRenew Default, 深度刷新列表    ;刷新**********************

Gui, MainGui:Add, text, xm+415 yp+3 vChooseRtxt R1 w70, 目标角色(0)
Gui, MainGui:Add, Edit, x+0 yp-3 R1 w195 ReadOnly Multi vChooseR c921AFF,  ;右选定

Gui, MainGui:Add, ListView, xm+10 y+3 h400 w265 Section HwndhLVL vLVL gLVMainA AltSubmit Grid -Multi, 源角色|账号|角色同步源|账号同步源
global cLVL := New LV_Colors(hLVL)    ;创建为颜色类

Gui, MainGui:Add, GroupBox, x+5 yp w130 h275, 覆盖模式
gui, MainGui:Font, norm
Gui, MainGui:Add, Checkbox, xp+10 yp+20 h20 gChooseCopyItem vCopyItem1, 账号插件配置
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem2, 账号系统设置
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem3, 账号按键
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem4, 账号通用宏
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem5, 角色插件配置
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem6, 角色系统设置
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem7, 角色按键
Gui, MainGui:Add, Checkbox, xp yp+20 h20 gChooseCopyItem vCopyItem8, 角色专用宏

Gui, MainGui:Font, bold     ;粗体
Gui, MainGui:Add, Button, xp y+5 h80 w110 gBTdoneA vBTCopy Disabled, 配置覆盖`r> > > >
Gui, MainGui:Add, GroupBox, xp-10 y+25 vGBSyn w130 h110, 同步模式
Gui, MainGui:Add, Button, xp+10 yp+20 h80 w110 gBTdoneA vBTSyn Disabled, 配置同步`r< < < <
if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2003,WIN_XP,WIN_2000    ;VISTA之前的操作系统都不支持联接目录
{
	GuiControl, hide, BTSyn   
	GuiControl, hide, GBSyn
}
Gui, MainGui:Add, ListView, x+15 ys h400 w265 HwndhLVR vLVR gLVMainA AltSubmit Grid Checked, 目标角色|账号|角色同步源|账号同步源
global cLVR := New LV_Colors(hLVR)    ;创建为颜色类

gui, MainGui:Font, norm
;##############################################################################################
;选项卡2： 游戏设置  ###############################################################################
Gui, MainGui:Tab, 2    
;##############################################################################################

;wtf的code
global wtfCode := {synchronizeSettings:[1,"设置同步到服务器端"]
							   ,overrideArchive:[1,"模型和谐"]}    
Gui, MainGui:Add, Checkbox, gCBSetConfigA vsynchronizeSettings, 同步配置[synchronizeSettings]
Gui, MainGui:Add, Checkbox, gCBSetConfigA voverrideArchive, 模型和谐[overrideArchive]


;##############################################################################################
;选项卡3： 宏管理  ################################################################################
Gui, MainGui:Tab, 3   
;##############################################################################################

;~ Gui, MainGui:Add, DDL, w140 Section gDDLMacroA vDDLMacro,
Gui, MainGui:Add, Text, yp-15 w30 Section, 包含:
Gui, MainGui:Add, Edit, x+0 yp-3 w92 gFilterA vIncdStrMacroSel,    ;左包含
Gui, MainGui:Add, text, x+6 yp+3 R1 w30, 排除:
Gui, MainGui:Add, Edit, x+0 yp-3 w92 gFilterA vNotIncdStrMacroSel,    ;右排除
Gui, MainGui:Add, ListView, xs y+5 w250 h150 AltSubmit Grid -Multi ReadOnly gLVMacroSelA HwndhLVMacroSel vLVMacroSel, 角色|账号|角色同步源|账号同步源
global cLVMacroSel := New LV_Colors(hLVMacroSel)    ;创建为颜色类

Gui, MainGui:Add, Button, xs y+5 w125 h25 Disabled gChgMacroMod vBTtoPublic, 通用宏
Gui, MainGui:Add, Button, x+0 yp w125 h25 gChgMacroMod vBTtoExclusive, 角色宏
Gui, MainGui:Add, ListView, xs y+0 w250 h240 AltSubmit Grid -Multi ReadOnly gLVMacroA HwndhLVMacro vLVMacro, 序|宏
Gui, MainGui:Add, Edit, x+25 ys-3 w380 h450 vEDMacro, 
;~ GuiAddMacroToolbar(hMainGui)    ;创建出宏工具条





Gui, MainGui:Font, italic    ;斜体
Gui, MainGui:Add, StatusBar, c800080
gui, MainGui:Font, norm
gui, MainGui:Show
WinGetPos, , , MainGui_W, MainGui_H, ahk_id %hMainGui%    ;获取主GUI的尺寸
;==============================================================================
;工具条创建函数 ====================================================================
;==============================================================================
GuiAddMacroToolbar(hWnd) 
{
    ImageList := IL_Create(2)
    IL_Add(ImageList, "shell32.dll", 1)
    IL_Add(ImageList, "shell32.dll", 1)
    hToolbar := Toolbar_Add(hWnd, "OnToolbar", "flat list tooltips", ImageList, "x20 y20")
    Buttons = 
    (LTrim
        1
        12
    )
    Toolbar_Insert(hToolbar, Buttons)
    return hToolbar
}
OnToolbar(hWnd, Event, Text, Pos, Id) {
    If (Event = "Hot") {
		Return
    }
}
;==============================================================================
;==============================================================================
;==============================================================================
;==============================================================================
;==============================================================================
;==============================================================================
;==============================================================================
;备份账号列表小界面的创建：
;==============================================================================
Gui BakGui:+Owner +HwndhBakGui
Gui, BakGui:font,, 微软雅黑
Gui, BakGui:Add, ListView, h350 w350 gLVBakA vLVBak HwndhLVBak AltSubmit Grid -Multi, 备份账号|备份日期
Gui, BakGui:Add, Button, xm+115 w120 gBTRestoreA vBTRestore Disabled, 还原备份  ;还原按钮