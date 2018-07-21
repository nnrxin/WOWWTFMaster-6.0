;~ bind NUMPAD1 CLICK U1BAR1AB1:LeftButton
;魔兽世界按键操作类
class WowAddOnsTxt
{
	__New(file)
	{
		this.file:=file
		FileRead, content, %file%
		this.content:=content
	}

	;获取key的设定值 dominos_actionsets: disabled
	Get(key,Default="")
	{
		if !IsObject(key)  ;不是数组
		{
			if RegExMatch(this.content, "im)(?<=^" key ": ).*$", OutputVar)  ;正则匹配
				return OutputVar
			return Default
		}
		else  ;是数组
		{
			Result:=[]  ;结果数组
			Loop % key.Length()  ;数组循环
			{
				if RegExMatch(this.content, "im)(?<=^" key[A_index] ": ).*$", OutputVar)  ;正则匹配
					Result.Push(OutputVar)
				else
					Result.Push(Default)
			}
			return % Result
		}
	}

	;设置key值为Value
	Set(key,Value)
	{
		if !IsObject(key)  ;不是数组
		{
			if RegExMatch(this.content, "im)^" key ": .*$")  ;正则匹配
			{
				FileRewrite(this.file,RegExReplace(this.content, "im)(?<=^" key ": ).*$", Value),A_FileEncoding)
			}
			else
			{
				newcontent:=RTrim(this.content,"`r`n") . "`r`n" key ": " Value "`r`n"
				FileRewrite(this.file,newcontent,A_FileEncoding)
			}
		}
		else  ;是数组
		{
			Loop % key.Length()  ;数组循环
			{
				if RegExMatch(this.content, "im)^" key[A_index] ": .*$")  ;正则匹配
					this.content:=RegExReplace(this.content, "im)(?<=^" key[A_index] ": ).*$", Value[A_index])
				else
					this.content:= RTrim(this.content,"`r`n") . "`r`n" key[A_index] ": " Value[A_index] "`r`n"
			}
			FileRewrite(this.file,this.content,A_FileEncoding)
		}
	}
	
	;删除key的那行
	Del(key)
	{
		if !IsObject(key)  ;不是数组
		{
			if RegExMatch(this.content, "im)^" key ": .*$")  ;正则匹配
			{
				FileDelete, % this.file
				FileAppend, % RegExReplace(this.content, "i)" key ": .*`r?`n?", ""), % this.file
			}
		}
		else
		{
			Loop % key.Length()  ;数组循环
			{
				if RegExMatch(this.content, "im)^" key[A_index] ": .*$")  ;正则匹配
					this.content:=RegExReplace(this.content, "i)" key[A_index] ": .*`r?`n?", "")
			}
			FileRewrite(this.file,this.content,A_FileEncoding)
		}
	}
}

/* 内容
!!!163UI.libs!!!: disabled
gladiatorlossa_zhcn: enabled
battlegroundtargets: disabled
betterpowerbaralt: disabled
tomtom: disabled
blizzmove: enabled
gridstatusbanzai: disabled
ellipsis: disabled
mapster: enabled
deathannounce: disabled
gridstatusraidicons: disabled
whisperpop: enabled
tullarange: enabled
tiptacoptions: enabled
!tddropdown: enabled
savedinstances: enabled
hpetbattleany: disabled