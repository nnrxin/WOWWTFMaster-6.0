;关联数组获取key总数
GetArrayLength(ByRef Array)
{
	i:=0
	For key in Array
		i++
	return i
}