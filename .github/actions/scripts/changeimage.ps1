$RandomFile = Get-ChildItem -Path ./Assets | Get-Random | Select-Object -ExpandProperty Name
(Get-Content ./README.md) -replace '(/Assets/).*?(\")', ('$1{0}$2' -f $RandomFile) |
    Set-Content -Path ./README.md