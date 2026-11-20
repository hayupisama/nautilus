# Estime l'usage de la fenêtre de 5 h en cours : tokens du bloc actif / plus gros bloc passé (ccusage).
$root = Split-Path (Split-Path $PSScriptRoot)
$cache = Join-Path $root ".nautilus\usage.json"
try {
  $json = & npx -y ccusage@latest blocks --json 2>$null | Out-String
  $blocks = ($json | ConvertFrom-Json).blocks | Where-Object { -not $_.isGap }
  $active = $blocks | Where-Object { $_.isActive } | Select-Object -First 1
  $max = ($blocks | Where-Object { -not $_.isActive } | Measure-Object -Property totalTokens -Maximum).Maximum
  if ($active -and $max -gt 0) {
    $pct = [math]::Round(100 * $active.totalTokens / $max)
    @{ pct = $pct; at = (Get-Date).ToString("o") } | ConvertTo-Json | Set-Content $cache -Encoding UTF8
  } else { @{ pct = $null; at = (Get-Date).ToString("o") } | ConvertTo-Json | Set-Content $cache -Encoding UTF8 }
} catch { }
