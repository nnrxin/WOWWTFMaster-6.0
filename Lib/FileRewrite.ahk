;不删除原文件的情况下重写文件
FileRewrite(FliePath,Content,Encoding)
{
	File:=FileOpen(FliePath,"rw",Encoding)
	File.Length := 0
	File.Write(Content)
	File.Close()
}