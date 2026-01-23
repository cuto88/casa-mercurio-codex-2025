# Ops notes

## deploy_safe.ps1
- The script preflights the target path before the backup. If `Z:\` is missing it attempts to map the drive.
- Customize SMB mapping with `HA_SMB_SHARE`, `HA_SMB_USER`, and `HA_SMB_PASS` environment variables (avoid committing secrets).
