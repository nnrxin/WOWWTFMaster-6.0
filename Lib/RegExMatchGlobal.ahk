;正则匹配全部，返回到数组
RegExMatchGlobal(ByRef Haystack, NeedleRegEx)
{
	Static Options := "U)^[imsxACDJOPSUX`a`n`r]+\)"
	NeedleRegEx := (RegExMatch(NeedleRegEx, Options, Opt) ? (InStr(Opt, "O", 1) ? "" : "O") : "O)") . NeedleRegEx
	Match := {Len: {0: 0}}, Matches := [], FoundPos := 1
	while (FoundPos := RegExMatch(Haystack, NeedleRegEx, Match, FoundPos + Match.Len[0]))
	Matches[A_Index] := Match
	return Matches
}