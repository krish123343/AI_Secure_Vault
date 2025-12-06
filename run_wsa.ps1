Write-Host "Connecting to WSA..." -ForegroundColor Cyan
adb connect 127.0.0.1:58526

Write-Host "Launching Flutter app in release mode..." -ForegroundColor Green
flutter run --release -d 127.0.0.1:58526

Write-Host "Done! Press any key to close..." -ForegroundColor Yellow
Pause
