$ErrorActionPreference = "Stop"

$gatesScript = Join-Path $PSScriptRoot "gates_run_ci.ps1"
$statePath = Join-Path $PSScriptRoot ".gates_state.json"
$head = (& git rev-parse HEAD).Trim()

try {
    & $gatesScript
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Gates failed with exit code $exitCode."
    }

    $state = [ordered]@{
        head      = $head
        status    = "passed"
        timestamp = (Get-Date).ToString("s")
        runner    = "manual"
    }
    $state | ConvertTo-Json -Depth 3 | Set-Content -Path $statePath -Encoding utf8

    Write-Host "HEAD: $head"
    Write-Host "Esito: passed"
    Write-Host "State file: $statePath"
    exit 0
} catch {
    $errorMessage = ($_ | Out-String).Trim()
    $state = [ordered]@{
        head      = $head
        status    = "failed"
        timestamp = (Get-Date).ToString("s")
        runner    = "manual"
        error     = $errorMessage
    }
    $state | ConvertTo-Json -Depth 3 | Set-Content -Path $statePath -Encoding utf8

    Write-Host "HEAD: $head"
    Write-Host "Esito: failed"
    Write-Host "State file: $statePath"
    throw
}
