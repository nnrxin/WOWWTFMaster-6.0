
;需要函数 正则匹配全部：RegExMatchGlobal()
class WowAddOnSave
{
	static FILE_ENCODING := "UTF-8"    ;文件所用编码
	
	__New(filename)
	{
		NowFileEncoding:=A_FileEncoding     ;保存当前编码
		FileEncoding, % this.FILE_ENCODING    ;设置编码
		FileRead, OutputVar, % this.filename:=filename
		this.file := OutputVar
		OutputVar := ""
		FileEncoding, %NowFileEncoding%     ;恢复之前的编码
	}

    __Delete()
	{
		this.file:=this.filename:=""
	}



	;获取key的内容，单行/多行 返回匹配的内容数组
	Get(Section)
	{
		MatchSection := []
		for i, m in RegExMatchGlobal(this.file, "iU)(\t*)\[""" Section """] = (\{(\R.*)*\R\1},|.*,)")    ; U)(\t*)\["profiles"] = ({(\R.*)*\R\1},|.*,)
			MatchSection.Push( m.Value(0) )
		return	MatchSection
	}

	;获取Section的下全部key名称 返回2级数组[i,j] i是第几个Section  j是Section下第几个key
	GetKeyList(Section)
	{
		key := []
		for i, m in this.Get(Section)
		{
			for j, n in RegExMatchGlobal(m, "iU)(?<=\t\["").*(?=""] = [^{])")    ; U)(?<=\t\[").*(?="] = [^{])
				Key[i,j] := n.Value(0)
		}
		return key
	}

	;设置Section下面的key值，默认不检查Section
	Set(key,value,Section:="")
	{
		if Section    ;存在Section
		{
			;先将内容按section分段
			Part := []
			Pos := 1
			for i, m in RegExMatchGlobal(this.file, "iU)(\t*)\[""" Section """] = ({(\r\n.*)*\r\n\1},|.*,\s*(--.*)?)") 
			{
				Part[2*i-1] := SubStr(this.file,Pos, m.Pos(0)-Pos)
				Part[2*i] := m.Value(0)
				pos := m.Pos(0) + m.Len(0) 
			}
			Part.Push( SubStr(this.file,Pos) )    ;结尾
			;然后将含section分段进行处理
			loop % Part.Length()
			{
				if !Mod(A_index,2)    ;偶数列
				{
					part[A_Index] := RegExReplace(Part[A_index], "i)(?<=\t\[""" key """] = ).*(?=,\s*(--.*)?\r\n)", value, ReplaceCount)    ;替换
					isChanged := ReplaceCount=0?isChanged:1
				}
				Newfile .= part[A_Index]    ;拼合出新文本
			}
			Part := ""    ;清空
		}
		else    ;不存在Section
		{
			Newfile := RegExReplace(this.file, "i)(?<=\t\[""" key """] = ).*(?=,\s*(--.*)?\r\n)", value, ReplaceCount)    ;替换
			isChanged := ReplaceCount=0?isChanged:1
		}
		;实际执行
		if isChanged  ;替换成功时，执行设置动作，返回1
		{
			FileRewrite(this.filename,Newfile,this.FILE_ENCODING)
			return 1,VarSetCapacity(Newfile,0)
		}
		else  ;没发生替换时，无动作，返回0
			return 0,VarSetCapacity(Newfile,0)
	}

	;设置Sections(可以多个)下面的key为同层下key0的值******
	SetAs(key,key0,Sections)
	{
		;先将内容按section分段
		Part := []
		Pos := 1
		for i, m in RegExMatchGlobal(this.file, "iU)(\t*)\[""(" RegExReplace(Sections,"\n\t*","|") ")""] = ({(\r\n.*)*\r\n\1},|.*,\s*(--.*)?)") 
		{
			Part[2*i-1] := SubStr(this.file,Pos, m.Pos(0)-Pos)
			Part[2*i] := m.Value(0)
			pos := m.Pos(0) + m.Len(0) 
		}
		Part.Push( SubStr(this.file,Pos) )    ;结尾
		;然后将含section分段进行处理
		loop % Part.Length()
		{
			if !Mod(A_index,2)    ;偶数列
			and RegExMatch(Part[A_index], "i)(?<=\t\[""" key0 """] = ).*(?=,\s*(--.*)?\r\n)", value)    ;先得到key0的值，存在时进行替换
			{
				part[A_Index] := RegExReplace(Part[A_index], "i)(?<=\t\[""" key """] = ).*(?=,\s*(--.*)?\r\n)", value, ReplaceCount)    ;替换
				if (ReplaceCount=0)    ;如果没找到key时新建里一个key=value
				{
					RegExMatch(Part[A_index], "im)^\t*(?=},.*$)", Tabs) 
					part[A_Index] := RegExReplace(Part[A_index], "i)(\t*)},", Tabs "`t[""" key """] = " value ",`r`n" Tabs "},")    ;替换
				}
				isChanged := 1    ;修改过的
			}
			Newfile .= part[A_Index]    ;拼合出新文本
		}
		;清空	
		Part := ""    
		;实际执行
		if isChanged  ;替换成功时，执行设置动作，返回1
		{
			FileRewrite(this.filename,Newfile,this.FILE_ENCODING)
			return 1,VarSetCapacity(Newfile,0)
		}
		else  ;没发生替换时，无动作，返回0
			return 0,VarSetCapacity(Newfile,0)
	}
	
	;将第一个发现的Section的内容 完全覆盖为Value（多行), 如果没有就在Sign下增加新内容
	CoverAs(Section,Value,Sign:=" = {")
	{
		if !RegExMatch(this.file, "iU)(\t*)\[""" Section """] = (\{(\R.*)*\R\1},|.*,)")  ;没有找到Section
			newContents:=RegExReplace(this.file, "i)(?<=" Sign ")\R", "`r`n" Value "`r`n",,1)
		else   ;已存在该Section
			newContents:=RegExReplace(this.file, "iU)(\t*)\[""" Section """] = (\{(\R.*)*\R\1},|.*,)", Value)
		if (newContents!=this.file) ;有变化，执行替换动作，返回1
		{
			FileRewrite(this.filename,newContents,this.FILE_ENCODING)
			return 1,VarSetCapacity(newContents,0)
		}
		else ;无变化，无动作，返回0
			return 0,VarSetCapacity(newContents,0)
	}

	;将内容插入到所有包含key的下一行
	InsContents(key,Contents) 
	{
		if Contents
		{
			Loop % this.line.Length()
			{
				newContents.=this.line[A_index] "`r`n"
				if InStr(this.line[A_index], "[""" key """] = ")
					isfound:=true
					,newContents.=Contents "`r`n"
			}
			if isfound ;存在key值，执行删除动作，返回1
			{
				FileRewrite(this.filename,newContents,this.FILE_ENCODING)
				return 1,VarSetCapacity(newContents,0)
			}
			else ;没找到key值，无动作，返回0
				return 0,VarSetCapacity(newContents,0)
		}
	}
	
	;删除Section下面的key及其内容，默认不检查Section
	Del(key,Section:="")
	{
		;待填
	}
	
	;精确获取值，keys：= xxx.xxx.xxx
	GetEx(keys,mod:=0)		;mod=0是只保留值， mod=1是保留”键=值“
	{
		lua:=this.file, key := StrSplit(keys,".")
		loop % key.Length()
		{
			if !RegExMatch(lua, "iU)(\t*)\[""" key[A_Index] """] = (\{(\R.*)*\R\1},|.*,)",lua) 
				return		;没有匹配到则返回空值
		}
		if (mod=0)  ;只保留值的模式
		{
			lua:=RegExMatch(lua, "\R") ;多行
				?RegExReplace(lua,"iU)(^.*\R)|(\R`t+},( --.*)?$)")
				:RegExReplace(lua,"i)(.*""] = )|(,( --.*)?$)")
		}
		return % lua
	}

	;精确设定值，keys：= xxx.xxx.xxx   文字版的value需要加"",段落版的value段尾需要加`r`n
	SetEx(keys,value)
	{
		Oldlua:=this.file, key := StrSplit(keys,"."), Pos:=1
		loop % key.Length()
		{
			if !(Pos+=RegExMatch(lua, "iU)(\t*)\[""" key[A_Index] """] = (\{(\R.*)*\R\1},|.*,)",lua)-1) 
				return 0		;没有匹配到则返回，无动作
		}
		Pos+=RegExMatch(lua, "\R")
			?(RegExMatch(lua,"i)(\R.*)*\R",lua), len:=StrLen(lua)-2)    ;多行
			:(RegExMatch(lua,"i)(?<=""] = ).*(?=,)",lua)-1, len:=StrLen(lua))    ;单行
		Newlua:=SubStr(Oldlua,1,Pos-1) . value . SubStr(Oldlua,Pos+len+1)
		FileRewrite(this.filename,Newlua,this.FILE_ENCODING)
		return 1
	}
	
	;精确删除值，keys：= xxx.xxx.xxx
	DelEx(keys)
	{
		Oldlua:=this.file, key := StrSplit(keys,"."), Pos:=1
		loop % key.Length()
		{
			if !(Pos+=RegExMatch(lua, "iU)(\t*)\[""" key[A_Index] """] = (\{(\R.*)*\R\1},|.*,)",lua)-1) 
				return 0		;没有匹配到则返回，无动作
		}
		Newlua:=SubStr(Oldlua,1,Pos-1) . SubStr(Oldlua,Pos+StrLen(lua)+1)
		FileRewrite(this.filename,Newlua,this.FILE_ENCODING)
		return 1
	}
}