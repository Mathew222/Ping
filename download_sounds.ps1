# Download Free Notification Sounds
# This script downloads free notification sounds from Pixabay

Write-Host "🎵 Downloading Free Notification Sounds..." -ForegroundColor Cyan
Write-Host ""

$soundsDir = "assets\sounds"

# Create sounds directory if it doesn't exist
if (-not (Test-Path $soundsDir)) {
    New-Item -ItemType Directory -Path $soundsDir -Force | Out-Null
}

Write-Host "⚠️  IMPORTANT: I cannot automatically download audio files." -ForegroundColor Yellow
Write-Host ""
Write-Host "Please follow these simple steps:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Open your browser and go to:" -ForegroundColor White
Write-Host "   https://pixabay.com/sound-effects/search/notification/" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Download 4 short notification sounds (1-3 seconds each)" -ForegroundColor White
Write-Host ""
Write-Host "3. Rename them to:" -ForegroundColor White
Write-Host "   - gentle_chime.mp3" -ForegroundColor Yellow
Write-Host "   - classic_bell.mp3" -ForegroundColor Yellow
Write-Host "   - digital_beep.mp3" -ForegroundColor Yellow
Write-Host "   - urgent_alert.mp3" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Copy them to this folder:" -ForegroundColor White
Write-Host "   $((Get-Location).Path)\$soundsDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "✨ Alternative - Use these direct links:" -ForegroundColor Green
Write-Host ""
Write-Host "Open these URLs in your browser to download sounds:" -ForegroundColor White
Write-Host ""
Write-Host "Gentle sounds:" -ForegroundColor Cyan
Write-Host "https://pixabay.com/sound-effects/search/gentle%20notification/" -ForegroundColor Gray
Write-Host ""
Write-Host "Bell sounds:" -ForegroundColor Cyan
Write-Host "https://pixabay.com/sound-effects/search/bell%20notification/" -ForegroundColor Gray
Write-Host ""
Write-Host "Beep sounds:" -ForegroundColor Cyan
Write-Host "https://pixabay.com/sound-effects/search/beep%20notification/" -ForegroundColor Gray
Write-Host ""
Write-Host "Alert sounds:" -ForegroundColor Cyan
Write-Host "https://pixabay.com/sound-effects/search/alert%20notification/" -ForegroundColor Gray
Write-Host ""
Write-Host "⏱️  Time needed: ~5 minutes" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Tip: Look for sounds that are:" -ForegroundColor Green
Write-Host "   - 1-3 seconds long" -ForegroundColor White
Write-Host "   - MP3 format" -ForegroundColor White
Write-Host "   - Free to use (Pixabay sounds are all free!)" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to open Pixabay in your browser..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open Pixabay in default browser
Start-Process "https://pixabay.com/sound-effects/search/notification/"

Write-Host ""
Write-Host "✅ Browser opened! Download 4 sounds and add them to the sounds folder." -ForegroundColor Green
Write-Host ""
