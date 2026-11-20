# Hook SessionStart : injecte le contexte de reprise (dernier journal, sprint courant, limites).
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$root = Split-Path (Split-Path $PSScriptRoot)
$d = Join-Path $root "nautilus\.claude"
$f = Get-ChildItem (Join-Path $d "sessions") -Filter "20*.md" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
$s = Get-ChildItem (Join-Path $d "scrum\sprints") -Filter "S*.md" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
if ($f) { "[Derniere session : $($f.Name)]"; Get-Content $f.FullName -Encoding UTF8 -Tail 60 } else { "[Aucune session precedente]" }
if ($s) { "[Sprint courant : $($s.Name)]"; Get-Content $s.FullName -Encoding UTF8 -TotalCount 25 } else { "[Aucun sprint demarre : proposer /sprint-debut au daily]" }
$cfg = Join-Path $root ".nautilus\session.json"
if (Test-Path $cfg) { "[Session : $(Get-Content $cfg -Raw)]" }
exit 0
