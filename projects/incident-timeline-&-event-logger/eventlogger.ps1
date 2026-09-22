<#
.SYNOPSIS
    Real-Time Event Scorebot (Streaming API Client)
    Demonstrates in-memory execution, WebSocket connection handling, and Slack Webhook integration.
#>

# --- SECURITY: PULL CREDENTIALS FROM ENVIRONMENT VARIABLES ---
$SlackWebhookUrl =$env:SLACK_WEBHOOK_URL
$ApiKey =$env:VENDOR_API_KEY

if (-not $SlackWebhookUrl -or -not$ApiKey) {
    Write-Host "CRITICAL: SLACK_WEBHOOK_URL or VENDOR_API_KEY environment variables are missing." -ForegroundColor Red
    Write-Host "Please set them securely before running this script." -ForegroundColor Yellow
    exit
}

# Force PowerShell to use TLS 1.2 for modern web requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- SLACK ALERT FUNCTION ---
function Send-SlackAlert {
    param([string]$Message)
    $Payload = @{ message_text =$Message }
    $JsonPayload =$Payload | ConvertTo-Json -Compress

    try {
        Invoke-RestMethod -Uri $SlackWebhookUrl -Method Post -Body$JsonPayload -ContentType "application/json" | Out-Null
        Write-Host "[SLACK PUSH SUCCESS] -> $Message" -ForegroundColor Green
    }
    catch {
        Write-Host "[SLACK PUSH FAILED] -> $_" -ForegroundColor Red
    }
}

# --- MAIN SCRIPT ---
Clear-Host
Write-Host "=== Real-Time Event Milestone Monitor ===" -ForegroundColor Cyan

$EventId = Read-Host "Enter Target Event ID"
$AwayTeam = (Read-Host "Enter Away Team Abbreviation").Trim().ToUpper()
$HomeTeam = (Read-Host "Enter Home Team Abbreviation").Trim().ToUpper()

# Sanitized Endpoint
$WsUrl = "wss://api.vendor-endpoint.com:10001/ws?eventId=$EventId&apikey=$ApiKey"

# --- STATE TRACKER ---
$State = @{
    warmup_complete = $false
    highest_period_seen = 0
    last_period_break_sent = 0
    away_score = "0"
    home_score = "0"
    pending_tip_off = $false
    tip_off_sent = $false
    is_final = $false
    game_completed_sent = $false
}

function Format-Msg ([string]$EventName) {
    return "$AwayTeam VS $HomeTeam ($($State.away_score)-$($State.home_score))$EventName"
}

# --- WARMUP EVALUATION (HISTORY DUMP FLUSH) ---
function Finish-Warmup {
    $State.warmup_complete =$true
    
    if ($State.is_final) {
        Write-Host "`n[SYSTEM SYNC] Sync complete. Event is already finished." -ForegroundColor Yellow
        if ($State.away_score -ne "0" -or $State.home_score -ne "0") {
            Send-SlackAlert (Format-Msg "END OF EVENT")
            $State.game_completed_sent = $true
        }
    }
    elseif ($State.highest_period_seen -gt 1 -or $State.away_score -ne "0" -or $State.home_score -ne "0") {
        $State.tip_off_sent = $true
        $State.last_period_break_sent = [math]::Max($State.highest_period_seen - 1, 0)
        Write-Host "`n[SYSTEM SYNC] Sync complete. Detected mid-event state (Period $($State.highest_period_seen))." -ForegroundColor Yellow
        Send-SlackAlert "Event Monitor Synced!"
    }
    else {
        Write-Host "`n[SYSTEM SYNC] Sync complete. Live monitoring active from the start." -ForegroundColor Green
        if ($State.pending_tip_off) {
            Send-SlackAlert (Format-Msg "START OF EVENT")
            $State.tip_off_sent = $true
        }
    }
}

# --- WEBSOCKET SETUP (.NET NATIVE) ---
$WS = New-Object System.Net.WebSockets.ClientWebSocket
$CTS = New-Object System.Threading.CancellationTokenSource

try {
    Write-Host "`nConnecting to telemetry API..."
    $Uri = New-Object System.Uri($WsUrl)
    [void]$WS.ConnectAsync($Uri,$CTS.Token).GetAwaiter().GetResult()
    Write-Host "System Armed. Watching $AwayTeam vs$HomeTeam." -ForegroundColor Green
    Write-Host "Flushing data history buffer (2 seconds)..." -ForegroundColor Gray

    # Send Authentication Payload
    $Auth = @{ type="authentication"; apikey=$ApiKey; eventId=$EventId; format="json"; types="sc,ev,gi" }
    $AuthJson = $Auth \vert{} ConvertTo-Json -Compress$AuthBytes = [System.Text.Encoding]::UTF8.GetBytes($AuthJson)$AuthSegment = New-Object System.ArraySegment[byte]($AuthBytes, 0,$AuthBytes.Length)
    [void]$WS.SendAsync($AuthSegment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true,$CTS.Token).GetAwaiter().GetResult()

    # Start the 2-second background timer for the history dump
    $WarmupTimer = New-Object System.Timers.Timer(2000)
    $WarmupTimer.AutoReset =$false
    Register-ObjectEvent -InputObject $WarmupTimer -EventName Elapsed -Action { Finish-Warmup } \vert{} Out-Null$WarmupTimer.Start()

    # --- MESSAGE LISTENING LOOP ---
    $Buffer = New-Object byte[] 8192
    
    while ($WS.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $Segment = New-Object System.ArraySegment[byte]($Buffer, 0, $Buffer.Length)$MemStream = New-Object System.IO.MemoryStream
        
        do {
            $Result = $WS.ReceiveAsync($Segment, $CTS.Token).GetAwaiter().GetResult()$MemStream.Write($Buffer, 0,$Result.Count)
        } while (-not $Result.EndOfMessage)

        if ($Result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) { break }

        $RawMsg = [System.Text.Encoding]::UTF8.GetString($MemStream.ToArray())$MemStream.Dispose()

        try { $Data =$RawMsg | ConvertFrom-Json } catch { continue } 

        # Update Scores
        if ($null -ne$Data.homeTeam -and $null -ne$Data.homeTeam.score) { $State.home_score = [string]$Data.homeTeam.score }
        if ($null -ne$Data.awayTeam -and $null -ne$Data.awayTeam.score) { $State.away_score = [string]$Data.awayTeam.score }

        # Track active period
        $CurrentP = 0
        if ($null -ne$Data.periodNumber) { $CurrentP =$Data.periodNumber }
        elseif ($null -ne$Data.period) { $CurrentP =$Data.period }
        
        if ($CurrentP -gt$State.highest_period_seen) { $State.highest_period_seen =$CurrentP }

        if ($Data.matchStatus -in @("COMPLETE", "POST") -or $Data.status -eq "FINAL") {
            $State.is_final =$true
        }

        # START EVENT
        $IsJumpball = ($Data.eventType -eq "jumpball" -and $Data.subType -eq "tap")
        if ($IsJumpball -and$CurrentP -eq 1) {
            $State.pending_tip_off =$true
            if ($State.warmup_complete -and -not$State.tip_off_sent) {
                Send-SlackAlert (Format-Msg "START OF EVENT")
                $State.tip_off_sent =$true
            }
        }

        # PERIOD ENDING LOGIC
        $IsPeriodEnded = ($Data.eventType -eq "periodstatus" -and $Data.subType -eq "ended")
        if ($IsPeriodEnded) {
            $P =$Data.period
            if ($State.tip_off_sent -and $null -ne$P -and $P -gt$State.last_period_break_sent) {
                $State.last_period_break_sent =$P
                
                if ($State.warmup_complete) {
                    if ($P -eq 1) { Send-SlackAlert (Format-Msg "END OF FIRST") }
                    elseif ($P -eq 2) { Send-SlackAlert (Format-Msg "HALFTIME") }
                    elseif ($P -eq 3) { Send-SlackAlert (Format-Msg "END OF THIRD") }
                    elseif ($Data.periodType -eq "OVERTIME" -or $P -ge 5) { 
                        Send-SlackAlert (Format-Msg "END OF OVERTIME $($P - 4)") 
                    }
                }
            }
        }

        # END OF EVENT
        $IsGameEnded = ($Data.eventType -eq "game" -and $Data.subType -eq "end")
        if ($IsGameEnded) {
            $State.is_final =$true
            if ($State.warmup_complete -and -not$State.game_completed_sent) {
                if ($State.away_score -ne "0" -or $State.home_score -ne "0") {
                    Send-SlackAlert (Format-Msg "END OF EVENT")
                    $State.game_completed_sent =$true
                }
            }
        }
    }
}
catch {
    Write-Host "`n[CRASH DETECTED] Script encountered an error: $_" -ForegroundColor Red
}
finally {
    if ($WS) { $WS.Dispose() }
    Write-Host "`nConnection closed."
    Read-Host "Press ENTER to exit..."
}
