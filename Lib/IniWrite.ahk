;ini写入
IniWrite(Value, Filename, Section, Key)
{
	IniWrite, %Value%, %Filename%, %Section%, %Key%
	return, Value
}