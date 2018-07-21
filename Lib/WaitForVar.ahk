;循环等待直到Var等于一个数，之后会将值修改回去
WaitForVar(ByRef Var,value1:=1,value0:=0,t:=200)
{
	loop
	{
		sleep, %t%
		if (Var=value1)
		{
			Var:=value0
			break
		}
	}
}