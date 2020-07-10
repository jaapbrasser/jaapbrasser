$RandomFile = Get-ChildItem -Path ./Assets -Exclude *md | Get-Random | Select-Object -ExpandProperty Name
Write-Output "The new file is: '$RandomFile'"
$env:filename = $RandomFile
Write-Output "::set-env name=filename::$($env:filename)"
(Get-Content ./README.md) -replace '(/Assets/).*?(\")', ('$1{0}$2' -f $RandomFile) |
    Set-Content -Path ./README.md