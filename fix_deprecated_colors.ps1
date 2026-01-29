# PowerShell script to fix deprecated color methods
# Replaces withOpacity() and withAlpha() with withValues()

$files = @(
    "lib\app\theme\ping_theme.dart",
    "lib\features\reminders\presentation\screens\reminders_screen.dart",
    "lib\features\reminders\presentation\widgets\reminder_card.dart",
    "lib\features\reminders\presentation\widgets\calendar_widget.dart",
    "lib\features\reminders\presentation\widgets\reminders_summary_card.dart",
    "lib\features\reminders\presentation\widgets\empty_state.dart",
    "lib\features\reminders\presentation\screens\create_reminder_screen.dart",
    "lib\features\reminders\presentation\screens\edit_reminder_screen.dart",
    "lib\features\history\presentation\screens\history_screen.dart",
    "lib\core\notifications\snooze_picker.dart",
    "lib\features\settings\presentation\screens\settings_screen.dart",
    "lib\features\profile\presentation\screens\profile_screen.dart",
    "lib\features\auth\presentation\screens\login_screen.dart"
)

foreach ($file in $files) {
    $path = Join-Path $PSScriptRoot $file
    if (Test-Path $path) {
        Write-Host "Processing $file..."
        $content = Get-Content $path -Raw
        
        # Replace withOpacity(decimal) with withValues(alpha: decimal)
        $content = $content -replace '\.withOpacity\(([0-9.]+)\)', '.withValues(alpha: $1)'
        
        # Replace withAlpha(integer) with withValues(alpha: integer/255)
        $content = $content -replace '\.withAlpha\((\d+)\)', '.withValues(alpha: $1/255)'
        
        Set-Content $path $content -NoNewline
        Write-Host "  ✓ Fixed $file"
    } else {
        Write-Host "  ✗ File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "All deprecated color methods fixed!" -ForegroundColor Green
