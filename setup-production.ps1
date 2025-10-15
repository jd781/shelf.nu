# Production Mode Setup Script for Shelf.nu
# This script helps prepare your environment for production deployment

Write-Host "Shelf.nu Production Setup" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check if running from correct directory
if (-not (Test-Path ".\package.json")) {
    Write-Host "ERROR: Please run this script from the shelf.nu root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Checking current environment..." -ForegroundColor Yellow

# Check if .env exists
if (-not (Test-Path ".\.env")) {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    exit 1
}

# Create logs directory if it doesn't exist
if (-not (Test-Path ".\logs")) {
    Write-Host "Creating logs directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path ".\logs" -Force | Out-Null
}

Write-Host "`nStep 2: Configuring environment for production..." -ForegroundColor Yellow

# Read current .env
$envContent = Get-Content ".\.env" -Raw

# Check if NODE_ENV=development exists
if ($envContent -match "NODE_ENV=development") {
    Write-Host "   Found NODE_ENV=development - this should be removed for production" -ForegroundColor Cyan
    
    # Ask user what to do
    $response = Read-Host "`n   Do you want to comment it out? (Y/N)"
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        # Comment out the line
        $envContent = $envContent -replace "(?m)^NODE_ENV=development", "# NODE_ENV=development  # Commented for production mode"
        Set-Content -Path ".\.env" -Value $envContent -NoNewline
        Write-Host "   SUCCESS: Commented out NODE_ENV=development" -ForegroundColor Green
    } else {
        Write-Host "   SKIPPED: Keeping current setting" -ForegroundColor Gray
    }
} else {
    Write-Host "   OK: NODE_ENV not set to development" -ForegroundColor Green
}

Write-Host "`nStep 3: Checking HTTPS configuration..." -ForegroundColor Yellow

# Check vite.config.ts for HTTPS settings
$viteConfig = Get-Content ".\vite.config.ts" -Raw

if ($viteConfig -match "//\s*https:\s*\{") {
    Write-Host "   INFO: HTTPS is currently DISABLED in vite.config.ts" -ForegroundColor Cyan
    Write-Host "   For production, you should enable HTTPS with proper certificates" -ForegroundColor Cyan
    Write-Host "   See PRODUCTION_SETUP.md Step 1 for certificate setup instructions" -ForegroundColor Cyan
} else {
    Write-Host "   OK: HTTPS appears to be configured" -ForegroundColor Green
}

Write-Host "`nStep 4: Security check..." -ForegroundColor Yellow

# Check for strong secrets  
$secrets = @("SESSION_SECRET", "INVITE_TOKEN_SECRET")
$weakSecrets = @()

foreach ($secret in $secrets) {
    if ($envContent -match "$secret=\`"([^\`"]+)\`"") {
        $value = $matches[1]
        if ($value.Length -lt 32) {
            $weakSecrets += $secret
        }
    }
}

if ($weakSecrets.Count -gt 0) {
    Write-Host "   WARNING: The following secrets may be too short:" -ForegroundColor Yellow
    foreach ($secret in $weakSecrets) {
        Write-Host "      - $secret" -ForegroundColor Yellow
    }
    Write-Host "   Generate stronger secrets with:" -ForegroundColor Cyan
    Write-Host "      node -e `"console.log(require('crypto').randomBytes(32).toString('hex'))`"" -ForegroundColor White
} else {
    Write-Host "   OK: Secrets appear strong" -ForegroundColor Green
}

Write-Host "`nStep 5: Building for production..." -ForegroundColor Yellow
$buildResponse = Read-Host "   Run production build now? (Y/N)"

if ($buildResponse -eq 'Y' -or $buildResponse -eq 'y') {
    Write-Host "   Building... (this may take 30-60 seconds)" -ForegroundColor Cyan
    
    # Set NODE_ENV for this build
    $env:NODE_ENV = "production"
    
    npm run build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   SUCCESS: Build completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "   ERROR: Build failed - check errors above" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   SKIPPED: You can run 'npm run build' manually" -ForegroundColor Gray
}

Write-Host "`nStep 6: Service setup options..." -ForegroundColor Yellow
Write-Host "   You have several options for running Shelf in production:" -ForegroundColor Cyan
Write-Host "`n   Option A: Windows Service (NSSM)" -ForegroundColor White
Write-Host "      - Auto-starts on boot" -ForegroundColor Gray
Write-Host "      - Runs in background" -ForegroundColor Gray
Write-Host "      - Requires: choco install nssm" -ForegroundColor Gray
Write-Host "      - Setup: See PRODUCTION_SETUP.md Step 4" -ForegroundColor Gray
Write-Host "`n   Option B: PM2 Process Manager" -ForegroundColor White
Write-Host "      - Cross-platform" -ForegroundColor Gray
Write-Host "      - Good monitoring tools" -ForegroundColor Gray
Write-Host "      - Requires: npm install -g pm2" -ForegroundColor Gray
Write-Host "      - Setup: See PRODUCTION_SETUP.md Step 4" -ForegroundColor Gray
Write-Host "`n   Option C: Manual start" -ForegroundColor White
Write-Host "      - Simple: npm run start" -ForegroundColor Gray
Write-Host "      - Must start manually after reboot" -ForegroundColor Gray

Write-Host "`nProduction Setup Summary" -ForegroundColor Green
Write-Host "==========================`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review PRODUCTION_SETUP.md for complete guide" -ForegroundColor White
Write-Host "2. Set up HTTPS certificates (mkcert or Let's Encrypt)" -ForegroundColor White
Write-Host "3. Update Supabase Auth redirect URLs to HTTPS" -ForegroundColor White
Write-Host "4. Choose a service manager (NSSM or PM2)" -ForegroundColor White
Write-Host "5. Configure Windows Firewall" -ForegroundColor White
Write-Host "6. Set up automated backups" -ForegroundColor White
Write-Host "7. Test from multiple devices" -ForegroundColor White

Write-Host "`nTo test production build locally:" -ForegroundColor Yellow
Write-Host "   npm run start" -ForegroundColor White
Write-Host "   (Then browse to your configured URL)" -ForegroundColor Gray

Write-Host "`nFull documentation: ./PRODUCTION_SETUP.md`n" -ForegroundColor Cyan
