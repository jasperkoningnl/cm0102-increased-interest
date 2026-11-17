param(
    [Parameter(Mandatory=$true)][string]$ExePath,
    [ValidateSet('Install','Remove')][string]$Mode = 'Install'
)
$ErrorActionPreference = 'Stop'
try {
    $taskExe = (Resolve-Path -LiteralPath $ExePath).Path
    $taskBytes = [IO.File]::ReadAllBytes($taskExe)
    function U16([int]$p) { [BitConverter]::ToUInt16($taskBytes,$p) }
    function U32([int]$p) { [BitConverter]::ToUInt32($taskBytes,$p) }
    function Test-TaskBytes([int]$offset,[byte[]]$expected) {
        if ($offset -lt 0 -or $offset+$expected.Length -gt $taskBytes.Length) { return $false }
        for ($j=0; $j -lt $expected.Length; $j++) { if ($taskBytes[$offset+$j] -ne $expected[$j]) { return $false } }
        return $true
    }
    if ($taskBytes.Length -lt 4096 -or (U16 0) -ne 0x5A4D) { throw 'Not a Windows game executable.' }
    $taskPe = U32 0x3C
    if ($taskPe -gt $taskBytes.Length-248 -or (U32 $taskPe) -ne 0x4550 -or (U16 ($taskPe+4)) -ne 0x14C) { throw 'Expected a 32-bit Windows executable.' }
    $taskOpt = $taskPe+24
    if ((U16 $taskOpt) -ne 0x10B -or (U32 ($taskOpt+28)) -ne 0x400000) { throw 'Unsupported image layout.' }
    $taskSectionCount = U16 ($taskPe+6)
    $taskSectionTable = $taskOpt+(U16 ($taskPe+20))
    if ($taskSectionCount -lt 1 -or $taskSectionTable+40*$taskSectionCount -gt $taskBytes.Length) { throw 'Invalid section table.' }
    function Test-TaskMapping([int]$offset,[int]$size,[uint32]$rva,[uint32]$requiredFlags) {
        for ($i=0; $i -lt $taskSectionCount; $i++) {
            $s=$taskSectionTable+40*$i
            $raw=U32 ($s+20); $rawSize=U32 ($s+16); $sectionRva=U32 ($s+12); $virtualSize=U32 ($s+8)
            if ($offset -ge $raw -and $offset+$size -le $raw+$rawSize -and $offset+$size -le $taskBytes.Length) {
                return (($sectionRva+$offset-$raw -eq $rva) -and ($offset-$raw+$size -le [Math]::Max($virtualSize,$rawSize)) -and (((U32 ($s+36)) -band $requiredFlags) -eq $requiredFlags))
            }
        }
        return $false
    }
    if (-not (Test-TaskMapping 0x440D80 0x1260 0x440D80 0x60000000)) { throw 'Recruitment routine is mapped differently.' }
    if (-not (Test-TaskMapping 0x5689B8 8 0x5689B8 0x40000000)) { throw 'Original constant is mapped differently.' }
    if (-not (Test-TaskMapping 0x8DB200 64 0xBE6200 0x40000000)) { throw 'Required expanded 3.9.68 space is missing or mapped differently.' }
    $taskOriginal=Test-TaskBytes 0x4411C1 ([byte[]](0xDC,0x0D,0xB8,0x89,0x96,0x00))
    $taskInstalled=Test-TaskBytes 0x4411C1 ([byte[]](0xDC,0x0D,0x00,0x62,0xFE,0x00))
    if (-not ($taskOriginal -or $taskInstalled)) { throw 'Transfer bonus instruction has been changed by another patch.' }
    # Compare the entire known recruitment routine, normalizing only this patch's pointer.
    $taskFunction=New-Object byte[] 0x1260
    [Array]::Copy($taskBytes,0x440D80,$taskFunction,0,$taskFunction.Length)
    [Array]::Copy([byte[]](0xB8,0x89,0x96,0x00),0,$taskFunction,0x443,4)
    $taskHasher=[Security.Cryptography.SHA256]::Create()
    try { $taskFunctionHash=([BitConverter]::ToString($taskHasher.ComputeHash($taskFunction))).Replace('-','').ToLowerInvariant() }
    finally { $taskHasher.Dispose() }
    if ($taskFunctionHash -ne '0a4802ef314ed8d84bbc284ecae98096063766223704aaf009c52c37be8b7387') { throw 'Recruitment routine differs from the tested build; compatibility is not established.' }
    if (-not (Test-TaskBytes 0x5689B8 ([BitConverter]::GetBytes([double]1.05)))) { throw 'Shared original 1.05 constant was modified.' }
    $taskExpectedCave=New-Object byte[] 64
    if ($taskInstalled) { [Array]::Copy([BitConverter]::GetBytes([double]1.35),$taskExpectedCave,8) }
    if (-not (Test-TaskBytes 0x8DB200 $taskExpectedCave)) { throw 'Reserved constant space is in use or the installed constant differs.' }
    # Validate both patch files against their exact intended changes, not just their headers.
    $taskExpected=@{0x4411C3=@(0xB8,0x00);0x4411C4=@(0x89,0x62);0x4411C5=@(0x96,0xFE)}
    $taskFactor=[BitConverter]::GetBytes([double]1.35)
    for ($i=0;$i -lt 8;$i++) { $taskExpected[0x8DB200+$i]=@(0,$taskFactor[$i]) }
    foreach ($taskPatchName in @('IncreasedTransferInterest.patch','RemoveIncreasedTransferInterest.patch')) {
        $taskReverse=$taskPatchName.StartsWith('Remove')
        $taskSeen=@{}
        foreach ($taskLine in [IO.File]::ReadAllLines((Join-Path $PSScriptRoot $taskPatchName))) {
            if ($taskLine.Trim().StartsWith('#') -or $taskLine.Trim() -eq '') { continue }
            if ($taskLine -notmatch '^([0-9A-F]{8}): ([0-9A-F]{2}) ([0-9A-F]{2})$') { throw 'Unrecognized patch line.' }
            $taskOffset=[Convert]::ToInt32($Matches[1],16)
            if (-not $taskExpected.ContainsKey($taskOffset) -or $taskSeen.ContainsKey($taskOffset)) { throw 'Unexpected or duplicate patch offset.' }
            $taskPair=$taskExpected[$taskOffset]
            if ($taskReverse) { $taskPair=@($taskPair[1],$taskPair[0]) }
            if ([Convert]::ToInt32($Matches[2],16) -ne $taskPair[0] -or [Convert]::ToInt32($Matches[3],16) -ne $taskPair[1]) { throw 'Patch contents have changed.' }
            $taskSeen[$taskOffset]=$true
        }
        if ($taskSeen.Count -ne 11) { throw 'Incomplete patch file.' }
    }
    if ($Mode -eq 'Remove') {
        if (-not $taskInstalled) { throw 'This beta is not installed; do not use the removal patch.' }
        Write-Host 'PASS REMOVE: this beta is installed. Back up the executable, then apply RemoveIncreasedTransferInterest.patch.'
    } elseif ($taskInstalled) {
        Write-Host 'ALREADY INSTALLED: the 1.35 transfer-interest bonus is present. Do not apply it again.'
    } else {
        Write-Host 'PASS INSTALL: known layout, recruitment routine, constants and patch files match.'
        Write-Host 'Back up the executable, then apply IncreasedTransferInterest.patch through Nick''s Patcher.'
    }
    Write-Host 'Read-only check. It does not establish compatibility of every other game routine or mod.'
    exit 0
} catch {
    Write-Host ('NOT SUPPORTED: '+$_.Exception.Message)
    exit 1
}
