
;由职业名称返回 .Number（颜色默认黑） .Color（颜色默认黑）
WoW_ClassInfo(ClassName)
{
	return (ClassName="Warrior" or ClassName="战士")                   ? {Number:1,   Color:0xC79C6E}    ;ZS
			  :(ClassName="Mage" or ClassName="法师")                      ? {Number:2,   Color:0x69CCF0}     ;FS
			  :(ClassName="Rogue" or ClassName="潜行者")                  ? {Number:3,   Color:0xFFF569}     ;DZ
			  :(ClassName="Priest" or ClassName="牧师")                      ? {Number:4,   Color:0xFFFFFF}      ;MS
			  :(ClassName="Paladin" or ClassName="圣骑士")                ? {Number:5,   Color:0xF58CBA}     ;QS
			  :(ClassName="Shaman" or ClassName="萨满祭司")            ? {Number:6,   Color:0x0070DE}     ;SM
			  :(ClassName="Druid" or ClassName="德鲁伊")                   ? {Number:7,   Color:0xFF7D0A}     ;XD
			  :(ClassName="Hunter" or ClassName="猎人")                    ? {Number:8,   Color:0xABD473}     ;LR
			  :(ClassName="Warlock" or ClassName="术士")                  ? {Number:9,   Color:0x9482C9}      ;SS
			  :(ClassName="Death-Knight" or ClassName="死亡骑士")   ? {Number:10, Color:0xC41F3B}      ;DK
			  :(ClassName="Monk" or ClassName="武僧")                      ? {Number:11, Color:0x00FF96}       ;WS
			  :(ClassName="Demon-Hunter" or ClassName="恶魔猎手") ? {Number:12, Color:0xA330C9}     ;DH
			  :{Number:99999, Color:0xFFFFFF}    ;默认序号99999 颜色白
}



;WoW配置快速复制专用函数，变更lua中的配置档
;需要类 #Include <Class_WowAddOnSave> ;插件lua存档的操作类
;需要函数 SB
WoW_ChgLuaProfileKeys(Folder,Fullname,SrcFullname,SBProgress:=1)  ;文件夹，角色，源角色 （格式为 "角色 - 服务器"） 默认开启计时条
{
	BatchLines:=A_BatchLines 
	SetBatchLines, -1  ; 让操作以最快速度运行.
    NowFileEncoding:=A_FileEncoding     ;保存当前编码
    FileEncoding, UTF-8     ;lua的写入需要UTF-8

	global pp,Maxpp    ;全局参数
	;配置档Section集合
	Sections=
	(
	profileKeys
	_currentProfile
	)
	
    Loop, Files, % Folder "\*.lua"  ;文件夹内循环
    {
		if SBProgress    ;加入了状态栏进度条的！！！
		{
			SB_SetText("配置档变更: " A_LoopFileName,2)	;名称变更
			SB_SetProgress(++pp,4)	;进度条变更
			if (Percent:=Round(pp*100/Maxpp,1))<=100
				SB_SetText(Percent "%",3)	    ;百分比变化
		}
		lua:=new WowAddOnSave(A_LoopFileLongPath)
		lua.SetAs(Fullname,SrcFullname,Sections)
		lua.__Delete
		VarSetCapacity(lua,0) ;释放
    }
	
    FileEncoding, %NowFileEncoding%     ;恢复之前的编码
	SetBatchLines, %BatchLines%  ;恢复原有速度
}


;WoW配置快速复制专用函数，替换wow的lua
;需要函数 SB
WoW_ChgLua(Folder,Realm,Character,NewRealm,NewCharacter,SBProgress:=1)  ;文件夹，原服务器，原角色，新服务器，新角色
{
	BatchLines:=A_BatchLines 
	SetBatchLines, -1  ; 让操作以最快速度运行.
    NowFileEncoding:=A_FileEncoding     ;保存当前编码
    FileEncoding, UTF-8     ;lua的写入需要UTF-8
	
	global pp,Maxpp    ;全局参数
	
    Loop, Files, % Folder "\*.lua"  ;文件夹内循环
    {
		if SBProgress    ;加入了状态栏进度条的！！！
		{
			SB_SetText("配置档变更: " A_LoopFileName,2)	;名称变更
			SB_SetProgress(++pp,4)	;进度条变更
			if (Percent:=Round(pp*100/Maxpp,1))<=100
				SB_SetText(Percent "%",3)	    ;百分比变化
		}
        FileRead, luatxt, %A_LoopFileLongPath%  ;读取lua
        luatxt := RegExReplace(luatxt, """" Character """", """" NewCharacter """")  ; 替换 "角色"
        luatxt := RegExReplace(luatxt, """" Character " - " Realm """", """" NewCharacter " - " NewRealm """")  ; 替换 "角色 - 服务器"
        luatxt := RegExReplace(luatxt, """" Character "-" Realm """", """" NewCharacter "-" NewRealm """")  ; 替换 "角色-服务器"
        luatxt := RegExReplace(luatxt, """" Realm " - " Character """", """" NewRealm " - " NewCharacter """")  ; 替换 "服务器 - 角色"
        luatxt := RegExReplace(luatxt, """" Realm "-" Character """", """" NewRealm "-" NewCharacter """")  ; 替换 "服务器-角色"
        FileDelete, %A_LoopFileLongPath%    ;删除原lua
        FileAppend, %luatxt%, %A_LoopFileLongPath%  ;创建新lua
    }

    VarSetCapacity(luatxt,0) ;释放
    FileEncoding, %NowFileEncoding%     ;恢复之前的编码
	SetBatchLines, %BatchLines%  ;恢复原有速度
}