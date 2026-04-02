# ==========================================================
# SENTINEL EDR - CORE MONITORING ENGINE (STABLE VERSION)
# ==========================================================

$LogFile = "C:\Sentinel-EDR\logs\Alerts.json"
Clear-Host
Write-Host "SENTINEL EDR IS NOW ACTIVE... MONITORING FOR THREATS" -ForegroundColor Cyan

while($true) {
    $Events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4688} -MaxEvents 5 -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -gt (Get-Date).AddSeconds(-5) }
    
    foreach ($Event in $Events) {
        $CmdLine = [string]$Event.Properties[8].Value
        $ProcName = [string]$Event.Properties[5].Value

        if ($CmdLine -like "*lsass*" -or $CmdLine -like "*certutil*" -or $CmdLine -like "*vssadmin*") {
            
            $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            
            Write-Host "THREAT DETECTED!" -ForegroundColor Red -BackgroundColor Black
            Write-Host "Command: $CmdLine" -ForegroundColor Yellow

            $AlertObj = [PSCustomObject]@{
                Timestamp = $Timestamp
                Threat    = "Suspicious Process"
                Process   = $ProcName
                Command   = $CmdLine
                Severity  = "CRITICAL"
            }

            $AlertObj | ConvertTo-Json -Compress | Out-File -Append $LogFile
        }
    }
    Start-Sleep -Seconds 2
}