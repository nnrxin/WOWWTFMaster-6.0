;ini的读取
IniRead(Filename, Section, Key, Default:="")
{
	IniRead, OutputVar, %Filename%, %Section%, %Key%, %Default%
	return % OutputVar
}