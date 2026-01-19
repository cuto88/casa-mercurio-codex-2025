$ErrorActionPreference = 'Stop'

Write-Host '========================================='
Write-Host ' Running Manual Quality Gates'
Write-Host '========================================='

$gates = @(
    @{ Name = 'yamllint .'; Command = 'yamllint'; Args = @('.') },
    @{ Name = 'ops/check_include_tree.ps1'; Command = 'ops/check_include_tree.ps1'; Args = @() },
    @{ Name = 'ops/ha_structure_check.ps1 -CheckEntityMap'; Command = 'ops/ha_structure_check.ps1'; Args = @('-CheckEntityMap') },
    @{ Name = 'VMC dashboards gate'; Command = 'powershell'; Args = @('-ExecutionPolicy', 'Bypass', '-File', 'ops\check_vmc_dashboards.ps1') }
)

foreach ($gate in $gates) {
    if (Get-Command $gate.Command -ErrorAction SilentlyContinue) {
        Write-Host ("\n==> {0}" -f $gate.Name)
        & $gate.Command @($gate.Args)
        if ($LASTEXITCODE -ne 0) {
            Write-Host ("Gate failed with exit code {0}" -f $LASTEXITCODE)
            exit $LASTEXITCODE
        }
    } else {
        Write-Host ("\n==> Skipping {0} (not found)" -f $gate.Name)
    }
}

Write-Host "\nALL GATES PASSED"
