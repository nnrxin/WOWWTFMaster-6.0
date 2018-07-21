;~ bind NUMPAD1 CLICK U1BAR1AB1:LeftButton
;魔兽世界按键操作类
class WowBindings
{
	__New(file)
	{
		this.file:=file
		;~ FileRead, content, *P65001 %file%  ;UTF-8 读取内容到 this.content
		FileRead, content, %file%  ;UTF-8 读取内容到 this.content
		this.content:=content
	}

	;获取key的设定值
	Get(key,Default="")
	{
		if !IsObject(key)  ;不是数组
		{
			if RegExMatch(this.content, "im)(?<=^bind " key " ).*$", OutputVar)  ;正则匹配
				return OutputVar
			return Default
		}
		else  ;是数组
		{
			Result:=[]  ;结果数组
			Loop % key.Length()  ;数组循环
			{
				if RegExMatch(this.content, "im)(?<=^bind " key[A_index] " ).*$", OutputVar)  ;正则匹配
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
			if RegExMatch(this.content, "im)(?<=^bind " key " ).*$")  ;正则匹配
				newcontent:=RegExReplace(this.content, "im)(?<=^bind " key " ).*$", Value)
			else
				newcontent:=RTrim(this.content,"`r`n") . "`r`nbind " key " " Value "`r`n"
			FileRewrite(this.file,newcontent,"UTF-8")
		}
		else  ;是数组
		{
			Loop % key.Length()  ;数组循环
			{
				if RegExMatch(this.content, "im)(?<=^bind " key[A_index] " ).*$")  ;正则匹配
					this.content:=RegExReplace(this.content, "im)(?<=^bind " key[A_index] " ).*$", Value[A_index])
				else
					this.content:= RTrim(this.content,"`r`n") . "`r`nbind " key[A_index]  " " Value[A_index] "`r`n"
			}
			FileRewrite(this.file,this.content,"UTF-8")
		}
	}
	
	;删除key的那行
	Del(key)
	{
		if !IsObject(key)  ;不是数组
		{
			if RegExMatch(this.content, "im)(?<=^bind " key " ).*$")  ;正则匹配
			{
				newcontent:=RegExReplace(this.content, "i)bind " key " .*`r?`n?", "")
				FileRewrite(this.file,newcontent,"UTF-8")
			}
		}
		else
		{
			Loop % key.Length()  ;数组循环
			{
				if RegExMatch(this.content, "im)(?<=^bind " key[A_index] " ).*$")  ;正则匹配
					this.content:=RegExReplace(this.content, "i)bind " key[A_index] " .*`r?`n?", "")
			}
			FileRewrite(this.file,this.content,"UTF-8")
		}
	}
}

/* 按键信息
bind NUMPAD1 CLICK U1BAR1AB1:LeftButton
bind NUMPAD2 CLICK U1BAR1AB2:LeftButton
bind NUMPAD3 CLICK U1BAR1AB3:LeftButton
bind NUMPAD4 CLICK U1BAR1AB4:LeftButton
bind NUMPAD5 CLICK U1BAR1AB5:LeftButton
bind NUMPAD6 CLICK U1BAR1AB6:LeftButton
bind NUMPAD7 CLICK U1BAR1AB7:LeftButton
bind NUMPAD8 CLICK U1BAR1AB8:LeftButton
bind NUMPAD9 CLICK U1BAR1AB9:LeftButton
bind NUMPAD0 CLICK U1BAR1AB10:LeftButton
bind CTRL-NUMPAD1 CLICK U1BAR1AB11:LeftButton
bind CTRL-NUMPAD2 CLICK U1BAR1AB12:LeftButton
bind CTRL-NUMPAD3 CLICK U1BAR2AB1:LeftButton
bind CTRL-NUMPAD4 CLICK U1BAR2AB2:LeftButton
bind CTRL-NUMPAD5 CLICK U1BAR2AB3:LeftButton
bind CTRL-NUMPAD6 CLICK U1BAR2AB4:LeftButton
bind CTRL-NUMPAD7 CLICK U1BAR2AB5:LeftButton
bind CTRL-NUMPAD8 CLICK U1BAR2AB6:LeftButton
bind CTRL-NUMPAD9 CLICK U1BAR2AB7:LeftButton
bind CTRL-NUMPAD0 CLICK U1BAR2AB8:LeftButton
bind ALT-NUMPAD1 CLICK U1BAR2AB9:LeftButton
bind ALT-NUMPAD2 CLICK U1BAR2AB10:LeftButton
bind ALT-NUMPAD3 CLICK U1BAR2AB11:LeftButton
bind ALT-NUMPAD4 CLICK U1BAR2AB12:LeftButton