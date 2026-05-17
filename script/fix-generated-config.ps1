$root = if ($args -and (Test-Path $args[0])) { $args[0] } else { Join-Path $PSScriptRoot ".." }
$genDir = Join-Path $root ".opencode\generated"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# Strip UTF-8 BOM from both opencode.json and opencode.jsonc
foreach ($name in @("opencode.json", "opencode.jsonc")) {
    $cfg = Join-Path $genDir $name
    if (Test-Path $cfg) {
        $bytes = [System.IO.File]::ReadAllBytes($cfg)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            [System.IO.File]::WriteAllText($cfg, [Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3), $utf8NoBom)
            Write-Host "[cody-pro] Fixed BOM in $name"
        }
    }
}

# Fix empty key in opencode.json caused by old install.ps1 here-string $schema interpolation
$legacyCfg = Join-Path $genDir "opencode.json"
if (Test-Path $legacyCfg) {
    $text = [System.IO.File]::ReadAllText($legacyCfg, [Text.Encoding]::UTF8)
    if ($text.Contains('"":')) {
        Write-Host "[cody-pro] Fixed empty key in opencode.json"
        $fixed = @'
{
  "$schema": "https://cody.dev/config.json",
  "model": "cody/big-pickle"
}
'@
        [System.IO.File]::WriteAllText($legacyCfg, $fixed.TrimStart(), $utf8NoBom)
    }
}
