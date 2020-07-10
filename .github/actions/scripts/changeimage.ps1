$RandomFile = Get-ChildItem -Path ./Assets -Exclude *md | Get-Random | Select-Object -ExpandProperty Name
$env:filename = $RandomFile
(Get-Content ./README.md) -replace '(/Assets/).*?(\")', ('$1{0}$2' -f $RandomFile) |
    Set-Content -Path ./README.md