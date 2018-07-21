/*
;~ aaaa:= new WowMacro("C:\Users\Administrator\Desktop\macros-cache.txt")
for i in aaaa.Part
	MsgBox % aaaa.Get(i).Icon
*/

;wow宏文件操作类
class WowMacro
{
	__New(file)
	{
		this.file:=file
		NowFileEncoding:=A_FileEncoding     ;保存当前编码
		FileEncoding, UTF-8     ;lua的写入需要UTF-8
		FileRead, MacroTxt, %file%    ;读取内容到变量
		this.Part:=RegExMatchGlobal(MacroTxt, "U)VER(.*\R)*END(?=\RVER|\R*$)")    ;正则匹配全部到数组
		MacroTxt:=""    ;清空
		FileEncoding, %NowFileEncoding%     ;恢复之前的编码
	}

	;获取Macro的参数及内容
	Get(i:=1)
	{		
		return {Pos    :this.Part[i].Pos(0)    ;位置
				   ,Len     :this.Part[i].Len(0)    ;长度
				   ,Value  :Value:=this.Part[i].Value(0)     ;内容
				   ,Title    :Title:=RegExReplace(Value,"\R(.*\R*)*")    ;标题行内容
				   ,Macro :RegExReplace(Value,"(^.*\R)|(\REND\R*$)")    ;宏内容
				   ,Index  :RegExReplace(Title,"(^VER \d )|( "".*"" ""[a-z0-9A-Z_ \.]*""$)")    ;宏序号
				   ,Name :RegExReplace(Title,"(^VER \d [a-z0-9A-Z]{16} "")|("" ""[a-z0-9A-Z_ \.]*""$)")    ;宏名字
				   ,Icon    :RegExReplace(Title,"(^VER \d [a-z0-9A-Z]{16} "".*"" "")|(""$)")}   ;宏图标
	}


	;设置key值为Value *****************
	Set(key,Value)
	{
		Loop % this.line.Length()
		{
			if InStr("SET " this.line[A_index] " """, key)
			{
				this.line[A_index]:=RegExReplace(this.line[A_index], "(?<=" key ").*", " """ Value """")
				isfound:=1
			}
			newContents.= this.line[A_index] "`r`n"
		}
		FileRewrite(this.file,newContents,"UTF-8")
		if not isfound
			FileAppend, % "SET " key " """ Value """", % this.file, UTF-8
	}
	
	;删除key的那行 ***********************
	Del(key)
	{
		Loop % this.line.Length()
		{
			if InStr("SET " this.line[A_index] " """, key)
				continue
			newContents.= this.line[A_index] "`r`n"
		}
		FileRewrite(this.file,newContents,"UTF-8")
	}
}