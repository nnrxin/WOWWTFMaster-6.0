#Include <Class_WinHttp>


;获取网站状态    返回值: 1=正常, 0=不正常
WoWHttp_Status(portal:="CN")
{
	url:=(portal="CN")?"http://www.battlenet.com.cn/wow/zh/"    ;国服
								   :"https://worldofwarcraft.com/"    ;非国服
	Try, WinHttp.UrlDownloadToVar(url,"expected_status:200`r`nnumber_of_retries:3","")    ;获取状态码（最好加上try语句）
	return WinHttp.Status=200?1:0
}

;获取角色的职业
WoWHttp_GetCharacterClass(Character,Realm,portal:="CN")
{
	url:=(portal="CN")?"http://www.battlenet.com.cn/wow/zh/character/" Realm "/" Character "/simple"    ;国服战网地址
								   :"http://" portal ".battle.net/wow/en/character/" Realm "/" Character "/simple"
	HttpTxt:=WinHttp.UrlDownloadToVar(url)    ;保存网页信息到变量
	if pos:=InStr(HttpTxt,"class=""class"">")    ; <a xmlns="http://www.w3.org/1999/xhtml" href="/wow/en/game/class/death-knight" class="class">Death Knight</a>
		FoundPos := RegExMatch( SubStr(HttpTxt,pos-20,50), "(?<=class/).*(?="" class)|(?<=""class"">).*(?=</a>)", CharacterClass)    ;获取名称
	VarSetCapacity(HttpTxt, 0)    ;清空
	return CharacterClass
}