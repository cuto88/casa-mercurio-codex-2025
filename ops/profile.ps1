# PowerShell shortcuts for Casa Mercurio ops.
#
# Keep this file self-contained so it can be dot-sourced from $PROFILE.
# Update $HA_REPO if the repo path changes.

$HA_REPO = "F:\01_PROJECT\home-assistant\casa-mercurio-codex-2025"

function Invoke-HaOpsScript {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
  )

  $scriptPath = Join-Path $HA_REPO "ops\$ScriptName"
  if (Test-Path $scriptPath) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $scriptPath @Args
    return
  }

  Write-Warning "HA ops script not found: $scriptPath"
}

function ha-sync {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

  Invoke-HaOpsScript -ScriptName "repo_sync.ps1" -Args $Args
}

function ha-gates {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

  Invoke-HaOpsScript -ScriptName "gates_run.ps1" -Args $Args
}

function ha-gates-ci {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

  Invoke-HaOpsScript -ScriptName "gates_run_ci.ps1" -Args $Args
}

function ha-deploy {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

  Invoke-HaOpsScript -ScriptName "deploy_safe.ps1" -Args $Args
}

function ha-flow {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

  Invoke-HaOpsScript -ScriptName "repo_sync.ps1" -Args $Args
  if ($LASTEXITCODE -eq 0) {
    Invoke-HaOpsScript -ScriptName "gates_run.ps1" -Args $Args
  }
}

function dep! {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)

  Invoke-HaOpsScript -ScriptName "deploy_safe.ps1" -Args $Args
}
