# Hook PostToolUse : signale l'approche de la durée max et du seuil d'usage (fenêtre de 5 h, estimation ccusage).
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$null = [Console]::In.ReadToEnd()
$root = Split-Path (Split-Path $PSScriptRoot)
$dir = Join-Path $root ".nautilus"
$cfgPath = Join-Path $dir "session.json"
if (-not (Test-Path $cfgPath)) { exit 0 }
try { $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json } catch { exit 0 }
if ($cfg.closed) { exit 0 }

$elapsed = ((Get-Date) - [datetime]$cfg.start).TotalMinutes
$timePct = [math]::Round(100 * $elapsed / [double]$cfg.maxMinutes)

# Usage : cache rafraîchi en arrière-plan toutes les 10 min (ccusage)
$cache = Join-Path $dir "usage.json"
$stale = (-not (Test-Path $cache)) -or (((Get-Date) - (Get-Item $cache).LastWriteTime).TotalMinutes -gt 10)
if ($stale) {
  $refresh = Join-Path $PSScriptRoot "usage-refresh.ps1"
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-File","`"$refresh`"" | Out-Null
}
$usagePct = $null
if (Test-Path $cache) { try { $usagePct = [double](Get-Content $cache -Raw | ConvertFrom-Json).pct } catch {} }

$seuil = [double]$cfg.usageThreshold
$level = 0
if ($timePct -ge 80 -or ($usagePct -ne $null -and $usagePct -ge ($seuil - 10))) { $level = 1 }
if ($timePct -ge 100 -or ($usagePct -ne $null -and $usagePct -ge $seuil)) { $level = 2 }

$lvlPath = Join-Path $dir "level.txt"
$prev = 0; if (Test-Path $lvlPath) { $prev = [int](Get-Content $lvlPath -Raw) }
if ($level -le $prev) { exit 0 }
Set-Content $lvlPath $level

$u = if ($usagePct -ne $null) { "usage estimé $usagePct % (seuil $seuil %)" } else { "usage inconnu" }
$msg = if ($level -eq 2) { "LIMITE ATTEINTE ($timePct % de la durée max, $u). Arrête-toi au prochain point stable et lance /cloture." }
       else { "LIMITE PROCHE ($timePct % de la durée max, $u). Ne démarre plus de nouvelle US ; termine celle en cours." }
@{ hookSpecificOutput = @{ hookEventName = "PostToolUse"; additionalContext = $msg } } | ConvertTo-Json -Compress
exit 0
