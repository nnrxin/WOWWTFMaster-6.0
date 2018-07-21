;安装文件夹内所有文件到目标文件夹内
FolderInstall(From,To,Flag:=0)
{
	FileCreateDir, %To%
	loop, Files, % From "\*", F
		FileInstall, % A_LoopFileLongPath, % To "\" A_LoopFileName, %Flag%
}