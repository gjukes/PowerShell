<# test #>﻿

$source = "F:\Video"
$dest = "e:\Video"

if ($source.TrimEnd().Substring($source.TrimEnd().Length-1) -ne "\"){$source=$source+"\"}
if ($dest.TrimEnd().Substring($dest.TrimEnd().Length-1) -ne "\"){$dest=$dest+"\"}

$dt = get-date
$dtstr = $dt.ToString("yyyy-MM-dd HH:mm:ss K")
$dtfil = $dt.ToString("yyyyMMddHHmmss")

$outfile_er = $dest + "gVerifyLOG_Errors_"+$dtfil+".csv"
'"scan_dt","source","destination","message","md5_src","md5_dest"' | out-file $outfile_er -Append -Encoding ascii

$outfile_ok = $dest + "gVerifyLOG_OK_"+$dtfil+".csv"
'"scan_dt","source","destination","message","md5_src","md5_dest"' | out-file $outfile_ok -Append -Encoding ascii

$outfile_sum = $dest + "gVerifyLOG_Summary_"+$dtfil+".txt"

$okcnt=0
$misscnt=0
$md5cnt=0
$fileerrcnt=0
$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

$files = Get-ChildItem $source -Name -Recurse -File

foreach ($f in $files) {

    $fullpathSource = $source + $f
    $fullpathDest = $dest + $f
    $dtevent = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"
    $fileerr = ""

    if (-not (Test-Path -LiteralPath $fullpathDest)) {
        $outline = '"' + $dtevent + '","'+$fullpathSource+'","","FILE MISSING FROM DESTINATION"'
        $outline  | out-file $outfile_er -Append -Encoding ascii
        $misscnt++

    }
<#    else {
        
        try {
            $file = [System.IO.File]::Open($fullpathSource,[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
            $Smd5 = [System.BitConverter]::ToString($md5.ComputeHash($file))
        } catch {
            $fileerr="S"
        } finally {
            
            $file.Dispose()
        }

        try {
            $file = [System.IO.File]::Open($fullpathDest,[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
            $Dmd5 = [System.BitConverter]::ToString($md5.ComputeHash($file))
        } catch {
            $fileerr=$fileerr+"/D"
        } finally {
            $file.Dispose()
        }

        if ($fileerr.length -eq 0) {
            if ($Dmd5 -ne $Smd5) {
                #write-host $fullpathDest " -- MD5 MISMATCH"
                $outline = '"' + $dtevent + '","'+$fullpathSource+'","'+$fullpathDest+'","MD5 MISMATCH",' + $Smd5 + '","' + $Dmd5 + '"'
                $outline  | out-file $outfile_er -Append -Encoding ascii
                $md5cnt++
            } else {
                $outline = '"' + $dtevent + '","'+$fullpathSource+'","'+$fullpathDest+'","OK",' + $Smd5 + '","' + $Dmd5 + '"'
                $outline  | out-file $outfile_ok -Append -Encoding ascii
                $okcnt++
            }

        } else {
            $outline = '"' + $dtevent + '","'+$fullpathSource+'","'+$fullpathDest+'","ERROR ACCESSING FILE [' + $fileerr + ']"'
            $outline  | out-file $outfile_er -Append -Encoding ascii
            $fileerrcnt++
        }
    }
#>
}

$dtend = get-date

$outline = $source+" -> "+$dest
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = "Time Start: "+$dtstr
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = "Time Finish: "+$dtend
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = "Timer: "+(NEW-TIMESPAN –Start $dtstr –End $dtend)
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = $files.Count.ToString()+" files processed"
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = $okcnt.ToString()+" files verified OK"
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = $misscnt.ToString()+" files missing from destination"
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = $md5cnt.ToString()+" files with MD5 mismatch"
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii

$outline = $fileerrcnt.ToString()+" file access errors"
write-host $outline
$outline | out-file $outfile_sum -Append -Encoding ascii
