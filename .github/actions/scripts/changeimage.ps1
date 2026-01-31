# Read README
$readmePath = "./README.md"
$assetsPath = "./Assets"

$readme = Get-Content -Path $readmePath -Raw
Get-Content -Path $readmePath -Raw
# Grab current filenames used in the 3 img tags (only within /Assets/)
$currentFiles = [regex]::Matches($readme, '/Assets/([^"]+)"') |
    ForEach-Object { $_.Groups[1].Value } |
    Select-Object -Unique

$currentFiles

# Candidate pool (exclude markdown files and anything currently used)
$candidates = Get-ChildItem -Path $assetsPath -Filter *jpg |
    Where-Object { $currentFiles -notcontains $_.Name } |
    Select-Object -ExpandProperty Name

$candidates

if ($candidates.Count -lt 3) {
    throw "Not enough unique candidate images. Need 3, found $($candidates.Count)."
}

# Pick 3 distinct new images
$newFiles = $candidates | Get-Random -Count 3

Write-Output "New files: $($newFiles -join ', ')"

# Optional: expose them to GitHub Actions environment
# Expose them to GitHub Actions environment for later steps
"filename1=$($newFiles[0])" | Out-File -FilePath $env:GITHUB_ENV -Append -Encoding utf8
"filename2=$($newFiles[1])" | Out-File -FilePath $env:GITHUB_ENV -Append -Encoding utf8
"filename3=$($newFiles[2])" | Out-File -FilePath $env:GITHUB_ENV -Append -Encoding utf8

# (Optional) also write to logs
Write-Host "filename1=$($newFiles[0])"
Write-Host "filename2=$($newFiles[1])"
Write-Host "filename3=$($newFiles[2])"

# Replace the first 3 /Assets/<file>" occurrences in order
$newFiles = @($newFiles)

$script:idx = 0
$updated = [regex]::Replace(
  $readme,
  '(/Assets/)([^"]+)(")',
  {
    param([System.Text.RegularExpressions.Match] $m)

    if ($script:idx -lt 3 -and $script:idx -lt $newFiles.Count) {
      $file = $newFiles[$script:idx]
      $script:idx++
      return "$($m.Groups[1].Value)$file$($m.Groups[3].Value)"
    }

    return $m.Value
  }
)

Set-Content -Path $readmePath -Value $updated -NoNewline
