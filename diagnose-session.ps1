# Diagnostic Script - Check Session Cookie Issue

Write-Host "Checking Production Server Configuration..." -ForegroundColor Cyan
Write-Host ""

# Check current .env settings
Write-Host "1. Environment URLs (from .env):" -ForegroundColor Yellow
$envContent = Get-Content ".\.env" -Raw
if ($envContent -match 'SERVER_URL="([^"]+)"') {
    Write-Host "   SERVER_URL: $($matches[1])" -ForegroundColor White
}
if ($envContent -match 'APP_URL="([^"]+)"') {
    Write-Host "   APP_URL: $($matches[1])" -ForegroundColor White
}

Write-Host ""
Write-Host "2. HTTPS Status:" -ForegroundColor Yellow
$viteConfig = Get-Content ".\vite.config.ts" -Raw
if ($viteConfig -match "https:\s*\{") {
    Write-Host "   HTTPS: ENABLED" -ForegroundColor Green
} else {
    Write-Host "   HTTPS: DISABLED" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Certificate Files:" -ForegroundColor Yellow
if (Test-Path ".\cert\desktop-2r1gsn5+3.pem") {
    Write-Host "   Certificate: EXISTS" -ForegroundColor Green
    $cert = Get-Item ".\cert\desktop-2r1gsn5+3.pem"
    Write-Host "   Modified: $($cert.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "   Certificate: MISSING" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Server Process:" -ForegroundColor Yellow
$nodeProcess = Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq "" }
if ($nodeProcess) {
    Write-Host "   Status: RUNNING (PID: $($nodeProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "   Status: NOT RUNNING" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Testing HTTPS Connection:" -ForegroundColor Yellow
try {
    # Skip certificate validation for self-signed cert
    $null = [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $response = Invoke-WebRequest -Uri "https://192.168.25.184:3000" -UseBasicParsing -TimeoutSec 5
    Write-Host "   HTTPS Access: SUCCESS (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   HTTPS Access: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSIS:" -ForegroundColor Yellow
Write-Host ""

# Check if NODE_ENV is in .env
if ($envContent -match "NODE_ENV\s*=") {
    Write-Host "WARNING: NODE_ENV is set in .env file!" -ForegroundColor Red
    Write-Host "This should be removed for production mode." -ForegroundColor Red
    Write-Host ""
}

Write-Host "Common Issues:" -ForegroundColor Yellow
Write-Host "1. Session not persisting = Supabase Auth URLs still using HTTP" -ForegroundColor White
Write-Host "2. Login works but redirects back = Cookie domain/secure mismatch" -ForegroundColor White
Write-Host "3. Browser shows 'Not Secure' = Certificate not trusted" -ForegroundColor White
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Green
Write-Host "1. Go to: https://supabase.com/dashboard/project/jvdnbkrzvtfsqfxvdqgj" -ForegroundColor White
Write-Host "2. Click: Authentication -> URL Configuration" -ForegroundColor White
Write-Host "3. Update Site URL to: https://192.168.25.184:3000" -ForegroundColor White
Write-Host "4. Add Redirect URL: https://192.168.25.184:3000/**" -ForegroundColor White
Write-Host "5. Save and test again" -ForegroundColor White
Write-Host ""
