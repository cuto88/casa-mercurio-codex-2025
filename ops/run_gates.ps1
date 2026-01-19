$ErrorActionPreference = 'Stop'

Write-Host '========================================='
Write-Host ' Running Manual Quality Gates'
Write-Host '========================================='

$gates = @(
    @{ Name = 'yamllint .'; Command = 'yamllint'; Args = @('.'); UsePowerShell = $false },
    @{ Name = 'ops/check_include_tree.ps1'; Script = 'ops/check_include_tree.ps1'; Args = @(); UsePowerShell = $true },
    @{ Name = 'ops/ha_structure_check.ps1 -CheckEntityMap'; Script = 'ops/ha_structure_check.ps1'; Args = @('-CheckEntityMap'); UsePowerShell = $true },
    @{ Name = 'VMC dashboards gate'; Script = 'ops/check_vmc_dashboards.ps1'; Args = @(); UsePowerShell = $true }
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
            & $gate.Command @($gate.Args)
            $code = $LASTEXITCODE
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
