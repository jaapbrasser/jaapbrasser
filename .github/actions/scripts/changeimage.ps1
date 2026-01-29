# Read README
$readmePath = "./README.md"
$assetsPath = "./Assets"

$readme = Get-Content -Path $readmePath -Raw

# Grab current filenames used in the 3 img tags (only within /Assets/)
$currentFiles = [regex]::Matches($readme, '/Assets/([^"]+)"') |
    ForEach-Object { $_.Groups[1].Value } |
    Select-Object -Unique

# Candidate pool (exclude markdown files and anything currently used)
$candidates = Get-ChildItem -Path $assetsPath -Filter *jpg |
    Where-Object { $currentFiles -notcontains $_.Name } |
    Select-Object -ExpandProperty Name

if ($candidates.Count -lt 3) {
    throw "Not enough unique candidate images. Need 3, found $($candidates.Count)."
}

# Pick 3 distinct new images
$newFiles = $candidates | Get-Random -Count 3

Write-Output "New files: $($newFiles -join ', ')"

# Optional: expose them to GitHub Actions environment
Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append -InputObject "filename1=$($newFiles[0])"
Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append -InputObject "filename2=$($newFiles[1])"
Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append -InputObject "filename3=$($newFiles[2])"

# Replace the first 3 /Assets/<file>" occurrences in order
$idx = 0
$updated = [regex]::Replace(
    $readme,
    '(/Assets/)([^"]+)(")',
    {
        param($m)
        if ($idx -lt 3) {
            $replacement = "$($m.Groups[1].Value)$($newFiles[$idx])$($m.Groups[3].Value)"
            $idx++
            return $replacement
        }
        return $m.Value
    }
)

Set-Content -Path $readmePath -Value $updated -NoNewline
