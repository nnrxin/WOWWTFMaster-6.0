;魔兽世界配置文件操作类
class WowConfig
{
	__New(file)
	{
		this.file:=file
		this.line:=[]
		NowFileEncoding:=A_FileEncoding     ;保存当前编码
		FileEncoding, UTF-8     ;lua的写入需要UTF-8
		Loop, read, %file%
			this.line.push(A_LoopReadLine)
		FileEncoding, %NowFileEncoding%     ;恢复之前的编码
	}

	;获取key的设定值
	Get(key,Default="")
	{
		Loop % this.line.Length()
		{
			if InStr(this.line[A_index], "SET " key " """)
				return Trim(SubStr(this.line[A_index],InStr(this.line[A_index],"""")),"""")	;简单的处理 可能会多切掉"
		}
		return Default
	}

	;设置key值为Value
	Set(key,Value)
	{
		Loop % this.line.Length()
		{
			if InStr(this.line[A_index], "SET " key " """)
			{
				this.line[A_index]:=RegExReplace(this.line[A_index], "i)(?<=" key ").*", " """ Value """")
				isfound:=1
			}
			newContents.= this.line[A_index] "`r`n"
		}
		FileRewrite(this.file,newContents,"UTF-8")
		if not isfound
			FileAppend, % "SET " key " """ Value """", % this.file, UTF-8
	}
	
	;删除key的那行
	Del(key)
	{
		Loop % this.line.Length()
		{
			if InStr(this.line[A_index], "SET " key " """)
				continue
			newContents.= this.line[A_index] "`r`n"
		}
		FileRewrite(this.file,newContents,"UTF-8")
	}
}

/* 账号配置
synchronizeSettings "0"	;本地化 0:本地  1:
maxFPS "60"	;前台最高帧数  0-199 "0"=200
maxFPSBk "60"	;后台最高帧数  0-199 "0"=200
checkAddonVersion "1"	;检查插件版本  0:过期不会禁止   1:过期将被禁止
gxWindow = "0"		;窗口模式
gxMaximize = "0"	;0:窗口模式   1:窗口最大化
gxApi = "D3D11"	;渲染方式 DirectX 11
realmName "夏维安"	;服务器名
lastCharacterIndex "1"	;最后登陆角色位置
*/

/*



*/