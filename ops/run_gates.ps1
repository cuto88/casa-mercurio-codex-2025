$ErrorActionPreference = 'Stop'

Write-Host '========================================='
Write-Host ' Running Manual Quality Gates'
Write-Host '========================================='

function Get-RepoRoot {
    $root = (& git rev-parse --show-toplevel 2>$null)
    if (-not $root) {
        Write-Error 'Unable to resolve git repo root.'
        exit 1
    }
    return $root.Trim()
}

function Get-TrackedYamlFiles {
    param([string]$Root)
    $tracked = @()
    $output = & git -C $Root ls-files -z -- '*.yaml' '*.yml' 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Unable to enumerate tracked YAML files.'
        exit 1
    }
    if ($output) {
        $tracked = $output -split "`0" | Where-Object { $_ -ne '' }
    }
    return $tracked
}

$repoRoot = Get-RepoRoot
$trackedYamlFiles = Get-TrackedYamlFiles -Root $repoRoot

$gates = @(
    # HYGIENE = formatter/mutating scripts (non-validation).
    @{ Name = '[HYGIENE] ops/fix_yaml_encoding.ps1 (mutating formatter)'; Script = 'ops/fix_yaml_encoding.ps1'; Args = @(); UsePowerShell = $true },
    # GATE = validation/non-mutating checks.
    @{ Name = '[GATE] yamllint tracked YAML (validation)'; Command = 'yamllint'; Args = @(); UsePowerShell = $false },
    @{ Name = '[GATE] ops/check_include_tree.ps1'; Script = 'ops/check_include_tree.ps1'; Args = @(); UsePowerShell = $true },
    @{ Name = '[GATE] ops/ha_structure_check.ps1 -CheckEntityMap'; Script = 'ops/ha_structure_check.ps1'; Args = @('-CheckEntityMap'); UsePowerShell = $true },
    @{ Name = '[GATE] VMC dashboards gate'; Script = 'ops/check_vmc_dashboards.ps1'; Args = @(); UsePowerShell = $true }
)

foreach ($gate in $gates) {
    if ($gate.UsePowerShell) {
        if (Test-Path -Path $gate.Script) {
            Write-Host ("\n==> {0}" -f $gate.Name)
            powershell -NoProfile -ExecutionPolicy Bypass -File $gate.Script @($gate.Args)
            $code = $LASTEXITCODE
        } else {
            Write-Host ("\n==> Skipping {0} (not found)" -f $gate.Name)
            continue
        }
    } else {
        if (Get-Command $gate.Command -ErrorAction SilentlyContinue) {
            Write-Host ("\n==> {0}" -f $gate.Name)
            if ($gate.Command -eq 'yamllint') {
                if ($trackedYamlFiles.Count -eq 0) {
                    Write-Host "No tracked YAML files found. Skipping yamllint."
                    $code = 0
                } else {
                    & $gate.Command @($trackedYamlFiles)
                    $code = $LASTEXITCODE
                    if ($code -eq 1) {
                        Write-Host "yamllint returned warnings only; continuing."
                        $code = 0
                    }
                }
            } else {
                & $gate.Command @($gate.Args)
                $code = $LASTEXITCODE
            }
        } else {
            Write-Host ("\n==> Skipping {0} (not found)" -f $gate.Name)
            continue
        }
    }

    if ($code -ne 0) {
        if ($null -eq $code) {
            Write-Host 'Gate failed (no exit code)'
            exit 1
        }
        $parsedCode = 0
        if (-not [int]::TryParse($code.ToString(), [ref]$parsedCode)) {
            Write-Host 'Gate failed (no exit code)'
            exit 1
        }
        Write-Host ("Gate failed with exit code {0}" -f $parsedCode)
        exit $parsedCode
    }
}

Write-Host "\nALL GATES PASSED"

# Scrive il marker gates.ok solo in caso di successo completo
$opsStateDir = Join-Path $repoRoot ".ops_state"
New-Item -ItemType Directory -Force -Path $opsStateDir | Out-Null

$head = (git rev-parse HEAD).Trim()
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

$gatesContent = @(
    "HEAD=$head"
    "BRANCH=$branch"
    "TIMESTAMP=$timestamp"
)

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines((Join-Path $opsStateDir "gates.ok"), $gatesContent, $utf8NoBom)
