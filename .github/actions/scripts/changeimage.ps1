$CurrentFile = (Get-Content ./README.md) -match 'Assets' -replace '.*?Assets/(.*?)".*','$1' | Select-Object -Last 1
$RandomFile = Get-ChildItem -Path ./Assets -Exclude *md |
    Where-Object {$_.Name -ne $CurrentFile} |
    Get-Random | Select-Object -ExpandProperty Name
Write-Output "The new file is: '$RandomFile'"
$env:filename = $RandomFile
Out-File -FilePath $GITHUB_ENV -Encoding utf8 -Append -InputObject "filename=$($env:filename)"
(Get-Content ./README.md) -replace '(/Assets/).*?(\")', ('$1{0}$2' -f $RandomFile) |
    Set-Content -Path ./README.md
