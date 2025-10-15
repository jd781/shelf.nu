# Shelf.nu Production Setup Guide for Windows Self-Hosting

## Overview
This guide will help you configure Shelf.nu for production use on your Windows machine.

## Prerequisites
- ✅ Node.js 20+ installed
- ✅ Supabase project configured
- ✅ SMTP configured (Gmail app password)
- ✅ Current working development setup

---

## Step 1: Switch to HTTPS with Production Certificates

### Option A: Use mkcert for Local Network (Recommended for internal use)

1. **Install mkcert** (if not already installed):
   ```powershell
   choco install mkcert
   # OR download from https://github.com/FiloSottile/mkcert/releases
   ```

2. **Install the local CA**:
   ```powershell
   mkcert -install
   ```

3. **Generate certificate for your computer's hostname**:
   ```powershell
   # Get your computer name
   $hostname = $env:COMPUTERNAME.ToLower()
   
   # Generate cert for hostname and IP
   cd C:\Users\Admin\Documents\shelf.nu
   mkcert $hostname 192.168.25.184 localhost
   
   # This creates: _wildcard.$hostname.pem and _wildcard.$hostname-key.pem
   ```

4. **Update vite.config.ts** to use the new certificates:
   - Uncomment the HTTPS section
   - Point to your new cert files

### Option B: Use a Real Domain with Let's Encrypt (Advanced)

If you have a domain pointing to this machine:
- Use Caddy or nginx as a reverse proxy
- Configure Let's Encrypt for automatic SSL
- Proxy to http://localhost:3000

---

## Step 2: Update Environment for Production

### A. Create `.env.production` file:

```bash
# Copy your current .env
cp .env .env.production
```

### B. Edit `.env.production` and make these changes:

1. **Remove development mode**:
   ```
   # DELETE THIS LINE:
   NODE_ENV=development
   ```

2. **Update URLs to HTTPS** (if using SSL):
   ```
   SERVER_URL="https://YOUR-COMPUTER-NAME:3000"
   APP_URL="https://YOUR-COMPUTER-NAME:3000"
   BASE_URL="https://YOUR-COMPUTER-NAME:3000"
   PUBLIC_APP_URL="https://YOUR-COMPUTER-NAME:3000"
   ```

3. **Update Supabase Auth URLs**:
   - Go to Supabase → Authentication → URL Configuration
   - Site URL: `https://YOUR-COMPUTER-NAME:3000`
   - Redirect URLs:
     ```
     https://YOUR-COMPUTER-NAME:3000/reset-password
     https://YOUR-COMPUTER-NAME:3000/join
     ```

4. **Strengthen secrets** (generate new ones):
   ```powershell
   # Generate new SESSION_SECRET
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   
   # Generate new INVITE_TOKEN_SECRET
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

5. **Set production email settings**:
   ```
   SEND_ONBOARDING_EMAIL="true"  # Enable for production
   ```

---

## Step 3: Build for Production

```powershell
# Stop the dev server if running
# Then build
npm run build
```

---

## Step 4: Set Up as Windows Service

### Using NSSM (Non-Sucking Service Manager):

1. **Install NSSM**:
   ```powershell
   choco install nssm
   ```

2. **Create the service**:
   ```powershell
   cd C:\Users\Admin\Documents\shelf.nu
   
   # Create service
   nssm install ShelfAssets "C:\Program Files\nodejs\node.exe"
   
   # Configure service parameters
   nssm set ShelfAssets AppDirectory "C:\Users\Admin\Documents\shelf.nu"
   nssm set ShelfAssets AppParameters "./build/server/index.js"
   nssm set ShelfAssets AppEnvironmentExtra "NODE_ENV=production"
   nssm set ShelfAssets DisplayName "Shelf Asset Management"
   nssm set ShelfAssets Description "52Launch Asset Management System"
   nssm set ShelfAssets Start SERVICE_AUTO_START
   
   # Set up logging
   nssm set ShelfAssets AppStdout "C:\Users\Admin\Documents\shelf.nu\logs\service-output.log"
   nssm set ShelfAssets AppStderr "C:\Users\Admin\Documents\shelf.nu\logs\service-error.log"
   
   # Start the service
   nssm start ShelfAssets
   ```

3. **Manage the service**:
   ```powershell
   # Check status
   nssm status ShelfAssets
   
   # Stop
   nssm stop ShelfAssets
   
   # Restart
   nssm restart ShelfAssets
   
   # Remove service (if needed)
   nssm remove ShelfAssets confirm
   ```

### Alternative: Using PM2 (Process Manager)

```powershell
# Install PM2 globally
npm install -g pm2 pm2-windows-startup

# Create ecosystem file for PM2
# (see ecosystem.config.cjs below)

# Start with PM2
pm2 start ecosystem.config.cjs

# Save the process list
pm2 save

# Set up auto-start on boot
pm2-startup install
```

**Create `ecosystem.config.cjs`**:
```javascript
module.exports = {
  apps: [{
    name: 'shelf-assets',
    script: './build/server/index.js',
    cwd: 'C:\\Users\\Admin\\Documents\\shelf.nu',
    env: {
      NODE_ENV: 'production',
    },
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-output.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
  }]
};
```

---

## Step 5: Configure Windows Firewall

```powershell
# Allow inbound on port 3000 (or 443 if using reverse proxy)
New-NetFirewallRule -DisplayName "Shelf Assets" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -Profile Private

# If using HTTPS on standard port:
New-NetFirewallRule -DisplayName "Shelf Assets HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -Profile Private
```

---

## Step 6: Set Up Automated Backups

### Database Backups (Supabase):

1. **Enable Point-in-Time Recovery** in Supabase Dashboard:
   - Project Settings → Database → Backups
   - Enable daily backups (available on paid plans)

2. **Export database weekly** (manual or scheduled):
   ```powershell
   # Create backup script: backup-database.ps1
   $backupDir = "C:\Backups\Shelf"
   $date = Get-Date -Format "yyyy-MM-dd"
   
   New-Item -ItemType Directory -Force -Path $backupDir
   
   # Export via Supabase CLI
   npx supabase db dump -f "$backupDir\shelf-backup-$date.sql"
   
   # Compress
   Compress-Archive -Path "$backupDir\shelf-backup-$date.sql" -DestinationPath "$backupDir\shelf-backup-$date.zip"
   Remove-Item "$backupDir\shelf-backup-$date.sql"
   ```

3. **Schedule with Task Scheduler**:
   - Open Task Scheduler
   - Create Basic Task → Name: "Shelf DB Backup"
   - Trigger: Weekly, Sunday 2:00 AM
   - Action: Start a program
   - Program: `powershell.exe`
   - Arguments: `-File "C:\Users\Admin\Documents\shelf.nu\backup-database.ps1"`

### File Backups (uploaded assets):

Supabase Storage handles this, but verify:
- Project Settings → Storage → Ensure backups enabled
- Consider sync to external backup location

---

## Step 7: Security Hardening

### A. Environment Variables:

✅ **Already secure in your setup**:
- SESSION_SECRET (strong random hex)
- INVITE_TOKEN_SECRET (strong random hex)
- SMTP passwords (app-specific)

❌ **To fix**:
1. Remove or disable unused services:
   ```
   # In .env.production
   DISABLE_SSO="true"  # ✅ Already set
   ENABLE_PREMIUM_FEATURES="false"  # ✅ Already set
   ```

2. Set proper Sentry DSN or disable:
   ```
   SENTRY_DSN=""  # Leave empty to disable error tracking
   ```

### B. Supabase Security:

1. **Enable Row Level Security (RLS)**:
   - Check in Supabase Dashboard → Database → Tables
   - Verify RLS policies are active on all tables

2. **Review API settings**:
   - Project Settings → API
   - Disable unused APIs
   - Set appropriate rate limits

### C. Windows Security:

1. **Run as limited user** (don't run as Administrator)
2. **Keep Windows updated**
3. **Enable Windows Defender**
4. **Restrict file permissions**:
   ```powershell
   # Restrict .env files
   icacls ".env*" /inheritance:r /grant:r "${env:USERNAME}:F"
   ```

---

## Step 8: Monitoring & Maintenance

### A. Health Check Script (`health-check.ps1`):

```powershell
$url = "http://localhost:3000"
try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
        Write-Host "✅ Shelf is running" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "❌ Shelf is DOWN - $_" -ForegroundColor Red
    # Optional: restart service
    # nssm restart ShelfAssets
    exit 1
}
```

### B. Update Procedure:

```powershell
# 1. Stop service
nssm stop ShelfAssets

# 2. Backup current installation
Copy-Item -Path "C:\Users\Admin\Documents\shelf.nu" -Destination "C:\Backups\shelf-backup-$(Get-Date -Format 'yyyy-MM-dd')" -Recurse

# 3. Pull latest code (if using git)
git pull

# 4. Install dependencies
npm install

# 5. Run database migrations
npm run db:deploy-migration

# 6. Rebuild
npm run build

# 7. Restart service
nssm start ShelfAssets

# 8. Verify
.\health-check.ps1
```

---

## Step 9: Access from Other Devices

### On the Same Network:

**Windows/Mac/Linux**:
- Browse to: `https://COMPUTER-NAME:3000` or `https://192.168.25.184:3000`
- Accept the mkcert certificate (trust it once)

**Mobile devices**:
1. Export and install the mkcert root CA:
   ```powershell
   # Find CA location
   mkcert -CAROOT
   
   # Copy rootCA.pem to phone
   # Install via Settings → Security → Install CA certificate
   ```

### From Outside Your Network (Optional):

**Option A: VPN** (Recommended for security):
- Set up WireGuard or OpenVPN
- Access as if on local network

**Option B: Port Forwarding** (Less secure):
- Configure router to forward external port → 192.168.25.184:3000
- Use dynamic DNS service (No-IP, DuckDNS)
- **Strongly recommend using HTTPS only**

**Option C: Cloudflare Tunnel** (Best for external access):
- Free, secure tunnel without port forwarding
- Set up cloudflared on this machine
- Access via custom subdomain

---

## Production Checklist

Before going live, verify:

- [ ] HTTPS configured and working
- [ ] All `.env.production` values are correct and secure
- [ ] Supabase Auth URLs updated to production URLs
- [ ] Production build completes without errors
- [ ] Service starts automatically on boot
- [ ] Firewall rules configured
- [ ] Backups scheduled and tested
- [ ] Restore procedure documented and tested
- [ ] Health monitoring in place
- [ ] All team members can access and log in
- [ ] Email invites working
- [ ] QR codes generating correctly
- [ ] Asset creation/editing working
- [ ] Test from multiple devices

---

## Troubleshooting

### Service won't start:
```powershell
# Check service logs
Get-Content C:\Users\Admin\Documents\shelf.nu\logs\service-error.log -Tail 50

# Check if port is in use
netstat -ano | findstr :3000

# Manually test
cd C:\Users\Admin\Documents\shelf.nu
npm run start
```

### Database connection issues:
- Verify `DATABASE_URL` and `DIRECT_URL` in `.env`
- Check Supabase project status
- Test connection: `npm run db:deploy`

### Session/login problems:
- Clear browser cookies
- Verify SESSION_SECRET is set
- Check that HTTPS is working (secure cookies)
- Review Supabase Auth logs

---

## Support & Resources

- **Shelf.nu Docs**: https://docs.shelf.nu
- **Supabase Docs**: https://supabase.com/docs
- **Company contact**: jd@52launch.com

---

**Last updated**: October 14, 2025
