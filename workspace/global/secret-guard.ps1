# Hook global Claude Code (PreToolUse) : bloque tout commit, push ou PR qui contiendrait un secret.
# Analyse : modifications non encore commitées + fichiers non suivis (pour un commit), commits non poussés (pour un push / une PR).
# Faux positif avéré : ajouter « pragma: allowlist secret » sur la ligne, UNIQUEMENT avec l'accord de Fouad.

$raw = [Console]::In.ReadToEnd()
try { $in = $raw | ConvertFrom-Json } catch { exit 0 }
$cmd = $in.tool_input.command
if (-not $cmd) { exit 0 }
$isCommit = $cmd -match '\bgit\b[^|;&]*\bcommit\b'
$isPush   = ($cmd -match '\bgit\b[^|;&]*\bpush\b') -or ($cmd -match '\bgh\s+(pr\s+create|release\s+create|gist\s+create)\b')
if (-not ($isCommit -or $isPush)) { exit 0 }

# Dossier du dépôt visé : git -C <chemin>, sinon « cd <chemin> && … », sinon le dossier courant
$dir = if ($in.cwd) { $in.cwd } else { (Get-Location).Path }
if ($cmd -match '^\s*cd\s+("([^"]+)"|''([^'']+)''|(\S+))\s*(&&|;)') { $d = @($Matches[2], $Matches[3], $Matches[4]) | Where-Object { $_ } | Select-Object -First 1; $dir = Join-Path $dir $d }
if ($cmd -match '\bgit\s+-C\s+("([^"]+)"|''([^'']+)''|(\S+))') { $d = @($Matches[2], $Matches[3], $Matches[4]) | Where-Object { $_ } | Select-Object -First 1; if ([IO.Path]::IsPathRooted($d) -or $d -match '^/[a-zA-Z]/') { $dir = $d } else { $dir = Join-Path $dir $d } }
if ($dir -match '^/([a-zA-Z])/(.*)$') { $dir = "$($Matches[1]):\$($Matches[2])" }
if (-not (Test-Path $dir)) { exit 0 }
$top = git -C $dir rev-parse --show-toplevel 2>$null
if (-not $top) { exit 0 }

$patterns = [ordered]@{
  "clé privée"              = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  "clé age (SOPS)"          = 'AGE-SECRET-KEY-1[0-9A-Z]{20,}'
  "jeton GitHub"            = '\b(gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})'
  "clé Anthropic"           = '\bsk-ant-[A-Za-z0-9_-]{20,}'
  "clé OpenAI"              = '\bsk-(proj-)?[A-Za-z0-9]{24,}'
  "clé AWS"                 = '\b(AKIA|ASIA)[0-9A-Z]{16}\b'
  "clé Google"              = '\bAIza[0-9A-Za-z_-]{35}'
  "jeton Slack"             = '\bxox[baprs]-[A-Za-z0-9-]{10,}'
  "clé Stripe"              = '\b(sk|rk)_live_[0-9a-zA-Z]{20,}'
  "jeton JWT"               = '\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
  "identifiants dans une URL" = '\b(postgres(ql)?|mysql|mongodb(\+srv)?|redis|amqps?|https?|ftp)://[^:/\s"''@]+:[^@\s"'']{3,}@'
  "mot de passe / secret en clair" = '(?i)\b(password|passwd|pwd|mot_de_passe|secret|api[_-]?key|apikey|token|client[_-]?secret|access[_-]?key|private[_-]?key)\b["'']?\s*[:=]\s*["'']?(?!changeme|example|exemple|placeholder|your[_-]|xxx|\*\*\*|<|\$\{|\$\(|ENC\[|dummy|fake|null|none|true|false)[^\s"''`,;]{8,}'
}
$badName = '(?i)(^|/)(\.env(\.[^/]+)?|[^/]+\.(pem|key|p12|pfx|jks|keystore|ppk)|id_(rsa|dsa|ecdsa|ed25519)(\.pub)?|\.?credentials(\.json)?|kubeconfig[^/]*|settings\.local\.json|\.npmrc|\.pypirc|\.netrc|secrets?\.(ya?ml|json))$'
$okName  = '(?i)\.(example|sample|template|dist)$|\.sops\.|\.enc\.'

$findings = New-Object System.Collections.Generic.List[string]
function Check-Line([string]$file, [string]$line) {
  if ($line -match 'pragma:\s*allowlist secret') { return }
  foreach ($k in $patterns.Keys) {
    $m = [regex]::Match($line, $patterns[$k])
    if ($m.Success) {
      $v = $m.Value; $mask = if ($v.Length -gt 6) { $v.Substring(0, 6) + "…" } else { "…" }
      $findings.Add("  - $file : $k ($mask)"); return
    }
  }
}
function Check-Name([string]$file) {
  if ($file -match $badName -and $file -notmatch $okName) { $findings.Add("  - $file : fichier sensible (ne doit pas être versionné)") }
}
function Scan-Patch([string[]]$lines) {
  $file = "?"
  foreach ($l in $lines) {
    if ($l -match '^\+\+\+ b/(.+)$') { $file = $Matches[1]; Check-Name $file; continue }
    if ($l -match '^\+\+\+ ') { continue }
    if ($l.StartsWith("+")) { Check-Line $file $l.Substring(1) }
  }
}

$hasHead = git -C $top rev-parse --verify HEAD 2>$null
if ($isCommit) {
  if ($hasHead) { Scan-Patch (git -C $top diff HEAD --no-color -U0 --no-ext-diff 2>$null) } else { Scan-Patch (git -C $top diff --cached --no-color -U0 2>$null) }
  foreach ($f in (git -C $top ls-files --others --exclude-standard 2>$null)) {
    Check-Name $f
    $p = Join-Path $top $f
    if ((Test-Path $p -PathType Leaf) -and (Get-Item $p).Length -lt 1MB) {
      $bytes = [IO.File]::ReadAllBytes($p)
      if ($bytes -notcontains 0) { foreach ($l in ([Text.Encoding]::UTF8.GetString($bytes) -split "`r?`n")) { Check-Line $f $l } }
    }
  }
}
if ($isPush -and $hasHead) {
  $remotes = git -C $top for-each-ref --format='%(refname)' refs/remotes 2>$null
  if ($remotes) { Scan-Patch (git -C $top log -p --no-color --no-ext-diff HEAD --not --remotes 2>$null) }
  else { Scan-Patch (git -C $top log -p --no-color --no-ext-diff HEAD 2>$null) }
}

if ($findings.Count -gt 0) {
  $list = ($findings | Select-Object -Unique | Select-Object -First 15) -join "`n"
  $why = if ($isPush) { "push" } else { "commit" }
  [Console]::Error.WriteLine(@"
BLOQUÉ par le garde-fou secrets : ce $why contiendrait une information sensible.
$list
À faire : retirer la valeur (variable d'environnement, secret chiffré SOPS, secret GitHub Actions), ajouter le fichier au .gitignore,
et si le secret est déjà dans un commit local, réécrire ce commit avant de pousser. Un secret déjà poussé doit être considéré comme compromis : le révoquer.
Faux positif avéré : demander l'accord de Fouad avant d'ajouter « pragma: allowlist secret » sur la ligne.
"@)
  exit 2
}
exit 0
