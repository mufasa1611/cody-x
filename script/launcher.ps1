param([string]$Root)

$options = @("CLI (Terminal UI)", "Web UI (Browser)")
$selected = 0
$esc = [char]0x1b
$arrow = [char]0x276f
$up = [char]0x2191
$down = [char]0x2193
$first = $true
try {
    try { [Console]::CursorVisible = $false } catch {}
    $host.UI.RawUI.FlushInputBuffer()
    do {
        if (-not $first) {
            $host.UI.RawUI.CursorPosition = $startPos
            Write-Host "${esc}[J" -NoNewline
        } else {
            $startPos = $host.UI.RawUI.CursorPosition
            $first = $false
        }
        Write-Host "`n  ${esc}[1mCody Pro Launcher${esc}[22m`n"
        for ($i = 0; $i -lt $options.Length; $i++) {
            if ($i -eq $selected) {
                Write-Host "  ${esc}[7m${arrow} $($options[$i])${esc}[27m"
            } else {
                Write-Host "    $($options[$i])"
            }
        }
        Write-Host "`n  (${esc}[1m${up}${esc}[22m/${esc}[1m${down}${esc}[22m to move, ${esc}[1mEnter${esc}[22m to select)"
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 38) { $selected = ($selected - 1 + $options.Length) % $options.Length }
        elseif ($key.VirtualKeyCode -eq 40) { $selected = ($selected + 1) % $options.Length }
        elseif ($key.VirtualKeyCode -eq 27) { $selected = 255; break }
    } until ($key.VirtualKeyCode -eq 13)
} finally {
    try { [Console]::CursorVisible = $true } catch {}
    $host.UI.RawUI.FlushInputBuffer()
}

$selected
