;计算出文件夹大小（有缺陷，会把联接文件夹内的都统计上....）
FolderGetSize(Folder,Units:="",N:="1") ;units参数: ""=b  "k"=kb  "m"=mb "g"=gb  ,N是小数点后几位 负数的时候反向表示
{
	BatchLines:=A_BatchLines 
	SetBatchLines, -1  ; 让操作以最快速度运行.
	s := 0
	Loop, Files, %Folder%\*, FR ;读取文件且递归
		s += %A_LoopFileSize%
	SetBatchLines, %BatchLines%  ;恢复原有
	return (Units="k")?Round(s/1024,N)
		:(Units="m")?Round(s/1024**2,N)
		:(Units="g")?Round(s/1024**3,N)
		:s
}