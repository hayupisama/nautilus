# Hook PreToolUse : bloque les commandes irréversibles (garde-fou en mode « tout autorisé »).
$raw = [Console]::In.ReadToEnd()
try { $cmd = ($raw | ConvertFrom-Json).tool_input.command } catch { exit 0 }
if (-not $cmd) { exit 0 }
$rules = @(
  @('git\s+push\b.*(--force\b|--force-with-lease|\s-f\b|\s\+\S+)', 'push force interdit'),
  @('gh\s+repo\s+(delete|archive|rename)\b', 'suppression/archivage/renommage de dépôt interdit'),
  @('gh\s+(release|project)\s+delete\b', 'suppression GitHub interdite'),
  @('gh\s+api\b.*(-X|--method)\s+DELETE\b.*\brepos/[^/\s]+/[^/\s]+/?(\s|$|")', 'suppression de dépôt via API interdite'),
  @('rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)[a-zA-Z]*\s+("|'')?(/|~|/c/?|[cC]:[\\/]?|\$HOME|\$env:USERPROFILE)("|'')?(\s|$)', 'effacement récursif d''un disque ou du dossier personnel interdit'),
  @('Remove-Item\b.*-Recurse.*("|'')?([cC]:\\?("|'')?(\s|$)|\$HOME("|'')?(\s|$)|\$env:USERPROFILE("|'')?(\s|$)|~("|'')?(\s|$))', 'effacement récursif d''un disque ou du dossier personnel interdit'),
  @('(^|[;&|(]\s*)(format\s+[a-zA-Z]:|diskpart|mkfs(\.\w+)?\s|dd\s+if=)', 'opération disque interdite'),
  @('git\s+(branch\s+-D\s+main|push\s+\S+\s+(--delete\s+main|:main))', 'opération destructive sur main interdite'),
  @('\b(shutdown|Restart-Computer|Stop-Computer)\b', 'arrêt du poste interdit')
)
foreach ($r in $rules) {
  if ($cmd -match $r[0]) {
    [Console]::Error.WriteLine("BLOQUÉ par le garde-fou Nautilus : $($r[1]). Si c'est vraiment nécessaire, demande à Fouad.")
    exit 2
  }
}
exit 0
