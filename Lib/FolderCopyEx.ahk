; 强力移动文件夹，会将目标文件夹内相同文件替换，需要完整路径
FolderCopyEx(From, To)
{
    FileGetAttrib, Attributes, %From%
    IfInString, Attributes, D    ;文件夹时
    {
        ;源文件夹扫描
        FromFlies:=[]    ;包含文件夹
        Loop, Files, %From%\*, DR
            FromFlies.Push(SubStr(A_LoopFileLongPath,StrLen(From)+2))    ;先添加文件夹
        Loop, Files, %From%\*, FR
            FromFlies.Push(SubStr(A_LoopFileLongPath,StrLen(From)+2))    ;后添加文件
        
        ;检查目标文件夹是否存在 和 其真实性
        if IsReparsePoint_p(To)    ;联接文件夹时删除
            FileRemoveDir, %To%, 1
        FileCreateDir, %To%   ;创建一个文件夹
        
        ;开始复制
        loop % FromFlies.Length()
        {
            FileGetAttrib, Attributes, % From "\" FromFlies[A_index]
            IfInString, Attributes, D    ;文件夹时
            {
                if IsReparsePoint_p(To "\" FromFlies[A_index])    ;联接文件夹时删除
                    FileRemoveDir, % To "\" FromFlies[A_index], 1
                FileCreateDir, % To "\" FromFlies[A_index]    ;创建一个文件夹
            }
            else    ;文件时
                FileCopy, % From "\" FromFlies[A_index], % To "\" FromFlies[A_index], 1    ;文件覆盖
        }
    }
    else IfExist, %From%    ;文件时
    {
        SplitPath,To,, ToDir    ;解析出目标文件所在文件夹
        if IsReparsePoint_p(ToDir)    ;联接文件夹时删除
            FileRemoveDir, %ToDir%, 1
        FileCreateDir, %ToDir%   ;创建一个文件夹
        FileCopy, %From%, %To%, 1    ;文件覆盖
    }
}

;解析一个文件夹是否是联接文件夹（非真实文件夹），真返回1，否则返回0
IsReparsePoint_p(File) 
{
    attributes := DllCall("GetFileAttributes", "str", File)
    return (attributes != -1 && attributes & 0x400)     ; FILE_ATTRIBUTE_REPARSE_POINT = 0x400
}