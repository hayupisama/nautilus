# Module Nautilus : commandes d'administration des sessions Claude Code pour Fouad.
# Utilisable depuis n'importe quel dossier : tape `nautilus aide`.

$script:Root = if ($env:NAUTILUS_ROOT) { $env:NAUTILUS_ROOT } else { Join-Path $HOME "Projets\nautilus-repos" }
$script:Repos = "nautilus","nautilus-contrat-api","nautilus-api","nautilus-flutter-commun","nautilus-app-passager","nautilus-app-chauffeur","nautilus-back-office","nautilus-infra"
$script:Cfg = Join-Path $script:Root ".nautilus\session.json"

function Write-N($t, $c = "Cyan") { Write-Host "[nautilus] $t" -ForegroundColor $c }

function Get-Minutes([string]$d) {
  if ($d -match '^(\d+)h(\d+)?$') { return [int]$Matches[1] * 60 + [int]("0" + $Matches[2]) }
  if ($d -match '^(\d+)(m|min)?$') { return [int]$Matches[1] }
  throw "Durée invalide : $d (exemples : 2h, 1h30, 90m)"
}

function Update-Repos {
  foreach ($r in $script:Repos) {
    $p = Join-Path $script:Root $r
    if (-not (Test-Path $p)) { Write-N "dépôt manquant : $r" Yellow; continue }
    $dirty = git -C $p status --porcelain
    if ($dirty) { Write-N "$r : modifications locales, pas de mise à jour" Yellow; continue }
    git -C $p pull --ff-only -q 2>$null
    if ($LASTEXITCODE -ne 0) { Write-N "$r : mise à jour impossible (l'orchestrateur s'en occupera)" Yellow }
  }
}

function Test-Root {
  if (-not (Test-Path (Join-Path $script:Root "CLAUDE.md"))) {
    Write-N "Espace de travail introuvable : $script:Root (définir `$env:NAUTILUS_ROOT si tu l'as déplacé)" Red
    return $false
  }
  return $true
}

function Get-Session {
  if (Test-Path $script:Cfg) { try { return Get-Content $script:Cfg -Raw | ConvertFrom-Json } catch {} }
  return $null
}

function Invoke-Cloture {
  $s = Get-Session
  if ($s -and -not $s.closed) {
    Write-N "Clôture de la session en arrière-plan (journal, sprint, statuts)…"
    Push-Location $script:Root
    claude --dangerously-skip-permissions -c -p "/cloture"
    Pop-Location
  }
  if (Test-Path $script:Cfg) {
    Remove-Item $script:Cfg -Force
    Remove-Item (Join-Path $script:Root ".nautilus\level.txt") -Force -ErrorAction SilentlyContinue
  }
  Write-N "Session terminée." Green
}

function nautilus {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0)] [string]$Commande = "aide",
    [string]$Duree = "2h",
    [int]$Seuil = 80,
    [string]$Modele,
    [switch]$Reparer,
    [switch]$Force
  )
  switch ($Commande.ToLower()) {

    "start" {
      if (-not (Test-Root)) { return }
      $s = Get-Session
      if ($s -and -not $s.closed -and -not $Force) {
        Write-N "Une session semble déjà ouverte (début $($s.start)). Lance 'nautilus stop' d'abord, ou 'nautilus start -Force'." Yellow
        return
      }
      $min = Get-Minutes $Duree
      New-Item -ItemType Directory -Force -Path (Split-Path $script:Cfg) | Out-Null
      Remove-Item (Join-Path $script:Root ".nautilus\level.txt") -Force -ErrorAction SilentlyContinue
      [ordered]@{ start = (Get-Date).ToString("o"); maxMinutes = $min; usageThreshold = $Seuil; closed = $false } |
        ConvertTo-Json | Set-Content $script:Cfg -Encoding UTF8
      Write-N "Mise à jour des dépôts…"
      Update-Repos
      Write-N "Session de dev : durée max $Duree, seuil d'usage $Seuil %. Réponds 'go' au plan du daily pour lancer le travail." Green
      Push-Location $script:Root
      $args2 = @("--dangerously-skip-permissions")
      if ($Modele) { $args2 += @("--model", $Modele) }
      $args2 += "/daily"
      & claude @args2
      Pop-Location
      $s = Get-Session
      if ($s -and -not $s.closed) { Write-N "La session a été fermée sans clôture : je la clôture." Yellow; Invoke-Cloture }
      else { if (Test-Path $script:Cfg) { Remove-Item $script:Cfg -Force }; Write-N "Session terminée." Green }
    }

    "stop" {
      if (-not (Test-Root)) { return }
      if (-not (Get-Session)) { Write-N "Aucune session ouverte." ; return }
      Write-N "Si la session est encore ouverte dans une autre fenêtre, tape plutôt /cloture dedans." Yellow
      Invoke-Cloture
    }

    "etat" {
      if (-not (Test-Root)) { return }
      Push-Location $script:Root
      claude -p --model haiku --allowedTools "Read,Grep,Glob" "Résume pour Fouad, en français, en 8 lignes maximum et sans numéros de tickets : avancement du sprint courant (nautilus/.claude/scrum/sprints, velocity.md), ce qui a été livré récemment (dernière revue nautilus/docs/revues et dernier journal nautilus/.claude/sessions), blocages éventuels, prochaine étape. Ne modifie rien."
      Pop-Location
      $s = Get-Session
      if ($s -and -not $s.closed) { Write-N "Session en cours depuis $($s.start) (max $($s.maxMinutes) min)." }
    }

    "revue" {
      if (-not (Test-Root)) { return }
      $r = Get-ChildItem (Join-Path $script:Root "nautilus\docs\revues") -Filter "S*.md" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
      if ($r) { Write-N "Ouverture de $($r.Name)"; Invoke-Item $r.FullName } else { Write-N "Pas encore de revue de sprint." }
    }

    "usage" { npx -y ccusage@latest blocks --active }

    "maj" {
      Write-N "Mise à jour de Claude Code…"; claude update
      if (Test-Root) { Write-N "Mise à jour des dépôts…"; Update-Repos }
      Write-N "Terminé." Green
    }

    "check" {
      $tools = @(
        @{ n = "git";    t = { git --version };                     w = "Git.Git" },
        @{ n = "gh";     t = { gh --version };                      w = "GitHub.cli" },
        @{ n = "claude"; t = { claude --version };                  w = $null },
        @{ n = "node";   t = { node --version };                    w = "OpenJS.NodeJS.LTS" },
        @{ n = "java";   t = { java -version 2>&1 | Select-Object -First 1 }; w = "EclipseAdoptium.Temurin.21.JDK" },
        @{ n = "docker"; t = { docker --version };                  w = "Docker.DockerDesktop" },
        @{ n = "flutter";t = { flutter --version 2>$null | Select-Object -First 1 }; w = "flutter-git" }
      )
      foreach ($x in $tools) {
        $ok = [bool](Get-Command $x.n -ErrorAction SilentlyContinue); $v = $null
        if ($ok) { try { $v = & $x.t 2>$null } catch {} }
        if ($ok) { Write-Host ("  OK   {0,-8} {1}" -f $x.n, ($v | Select-Object -First 1)) -ForegroundColor Green; continue }
        Write-Host ("  ---  {0,-8} absent" -f $x.n) -ForegroundColor Yellow
        if ($Reparer -and $x.w) {
          if ($x.w -eq "flutter-git") {
            $dest = Join-Path $HOME "dev\flutter"
            if (-not (Test-Path $dest)) { git clone https://github.com/flutter/flutter.git -b stable $dest }
            $bin = Join-Path $dest "bin"
            $up = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($up -notlike "*$bin*") { [Environment]::SetEnvironmentVariable("Path", "$up;$bin", "User") }
            Write-N "Flutter installé dans $dest (rouvre PowerShell)." Green
          } else { winget install --id $x.w -e --accept-source-agreements --accept-package-agreements }
        }
      }
      $auth = gh auth status 2>&1 | Out-String
      if ($auth -match "Logged in") { Write-Host "  OK   gh auth" -ForegroundColor Green } else { Write-Host "  ---  gh auth : lance 'gh auth login'" -ForegroundColor Yellow }
      if ($auth -notmatch "'project'") { Write-Host "  ---  gh : droit 'project' manquant ('gh auth refresh -s project')" -ForegroundColor Yellow }
      if (-not $Reparer) { Write-N "Pour installer ce qui manque : nautilus check -Reparer" }
      Test-Root | Out-Null
    }

    default {
      Write-Host @"

  NAUTILUS — commandes de Fouad (depuis n'importe quel dossier)

  nautilus start [-Duree 2h] [-Seuil 80] [-Modele opus]
        Met à jour les dépôts, ouvre la session de dev et lance le daily.
        Réponds 'go' au plan proposé. Durée max et seuil d'usage (% de la fenêtre de 5 h, estimé).
  nautilus stop      Clôture propre (aussi après une fermeture brutale).
                     Dans une session ouverte : tape /cloture.
  nautilus etat      Résumé de l'avancement, sans ouvrir de session.
  nautilus revue     Ouvre la dernière revue de sprint.
  nautilus usage     Consommation estimée de la fenêtre de 5 h en cours.
  nautilus check [-Reparer]   Vérifie (et installe) les outils du poste.
  nautilus maj       Met à jour Claude Code et les dépôts.

  Espace de travail : $script:Root

"@
    }
  }
}

Export-ModuleMember -Function nautilus
