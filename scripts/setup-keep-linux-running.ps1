# Chief of Staff: keep Linux (WSL) running so the Hermes Telegram bot stays online.
#
# What this does:
#   Creates ONE Windows scheduled task, for your user only (no admin needed):
#     Name:    \ChiefOfStaff\Chief of Staff - Keep Linux running
#     When:    every time you log in to Windows
#     Runs:    wsl.exe -d Ubuntu-24.04 --exec sleep infinity   (hidden, no window)
#   That "sleep infinity" does nothing except keep Ubuntu awake, so the
#   hermes-gateway service inside it keeps running.
#
# To undo:  Unregister-ScheduledTask -TaskName "Chief of Staff - Keep Linux running" -Confirm:$false

$action = New-ScheduledTaskAction -Execute "C:\Windows\System32\conhost.exe" `
  -Argument "--headless C:\Windows\System32\wsl.exe -d Ubuntu-24.04 --exec sleep infinity"
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) `
  -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) `
  -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName "Chief of Staff - Keep Linux running" -TaskPath "\ChiefOfStaff\" `
  -Action $action -Trigger $trigger -Settings $settings `
  -Description "Starts Ubuntu (WSL) at logon and keeps it running so the Hermes Telegram gateway stays online." | Out-Null

Start-ScheduledTask -TaskPath "\ChiefOfStaff\" -TaskName "Chief of Staff - Keep Linux running"
Start-Sleep -Seconds 3
Get-ScheduledTask -TaskPath "\ChiefOfStaff\" | Select-Object TaskName, State
Write-Host "KEEP-ALIVE DONE"
