;正则匹配全部，返回到数组
RegExMatchAll(str, pat, pos := 1)
{
    static matches    ;见后"matches := []"
    if IsObject(str) ; 本函数同时作为正则的调出函数。
    {
        matches.Insert(str)    ;记录当前匹配（str）至数组对象（matches）。
        return    ;调出函数结束。返回空，继续向后匹配。
    }
    RegExMatch(pat, "sO)(^[^\(]*\))?(.*)", pat)    ;查找原模式中的选项。
    opt := pat.1 != "" ? pat.1 : ")"                ;提取原模式中的选项。
    pat := "O" opt "(?:" pat.2 ")(?C" A_ThisFunc ")"    ;构造新选项。保留原模式，并增加"O"（对象）模式、"?C"调出函数模式。
    matches := []        ;用于记录各个匹配结果。
    RegExReplace(str, pat, "",,, pos)    ;开始正则查找
    return matches    ;返回记录了各匹配结果的数组对象。
}