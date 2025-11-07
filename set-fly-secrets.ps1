# Set Fly.io secrets for Shelf.nu deployment
# Run this script before deploying: .\set-fly-secrets.ps1

$APP_NAME = "shelf-webapp-52l"

Write-Host "Setting secrets for Fly.io app: $APP_NAME" -ForegroundColor Green

# Get your app's Fly.io URL (you'll need to update SERVER_URL after first deploy)
$FLY_URL = "https://$APP_NAME.fly.dev"

# Set all secrets at once
& "$env:USERPROFILE\.fly\bin\fly.exe" secrets set `
  --app $APP_NAME `
  DATABASE_URL="postgresql://postgres.jvdnbkrzvtfsqfxvdqgj:5asvqAuQ`$#48+VY@aws-1-us-east-1.pooler.supabase.com:6543/postgres?pgbouncer=true" `
  DIRECT_URL="postgresql://postgres.jvdnbkrzvtfsqfxvdqgj:5asvqAuQ`$#48+VY@aws-1-us-east-1.pooler.supabase.com:5432/postgres" `
  SESSION_SECRET="F6AA5CCAB9DB8DF82A4875C0641D22D0732FD2E84F52762DC492C85CE53127E2" `
  SUPABASE_URL="https://jvdnbkrzvtfsqfxvdqgj.supabase.co" `
  SUPABASE_ANON_PUBLIC="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2ZG5ia3J6dnRmc3FmeHZkcWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzNDY5ODYsImV4cCI6MjA3NTkyMjk4Nn0.kSObu7KfgdfuZnLfxqYZugTc50CrT2T7ofcvu4fO2cM" `
  SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2ZG5ia3J6dnRmc3FmeHZkcWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzNDY5ODYsImV4cCI6MjA3NTkyMjk4Nn0.kSObu7KfgdfuZnLfxqYZugTc50CrT2T7ofcvu4fO2cM" `
  SUPABASE_SERVICE_ROLE="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2ZG5ia3J6dnRmc3FmeHZkcWdqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDM0Njk4NiwiZXhwIjoyMDc1OTIyOTg2fQ.l4Cod2jJUammekJi8G6z1emLpD9GSYxpISmGby798mg" `
  SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2ZG5ia3J6dnRmc3FmeHZkcWdqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDM0Njk4NiwiZXhwIjoyMDc1OTIyOTg2fQ.l4Cod2jJUammekJi8G6z1emLpD9GSYxpISmGby798mg" `
  SERVER_URL="$FLY_URL" `
  APP_URL="$FLY_URL" `
  BASE_URL="$FLY_URL" `
  SMTP_PWD="pade rdgm mety pdaq" `
  SMTP_HOST="smtp.gmail.com" `
  SMTP_PORT="587" `
  SMTP_USER="jd@52launch.com" `
  SMTP_FROM='"52L Assets" <jd@52launch.com>' `
  INVITE_TOKEN_SECRET="27DE6D0B5CB0D4AF8E56B83B872DEDDC3C42196B959ECBECAC0D47F0BD4E5C0F" `
  ADMIN_EMAIL="jd@52launch.com" `
  MAPTILER_TOKEN="laQYieTYkS17VKf7Klu8" `
  GEOCODING_USER_AGENT="52Launch Shelf (production) contact: jd@52launch.com" `
  DISABLE_SIGNUP="true" `
  ENABLE_PREMIUM_FEATURES="false" `
  SEND_ONBOARDING_EMAIL="false" `
  DISABLE_SSO="true" `
  FINGERPRINT="A387E3F3E2D65A360FAA22372ADD885D55C9CE599F9C774D61AAC9ADF2ACE1D8" `
  APP_NAME="Shelf"

Write-Host "`nSecrets set successfully!" -ForegroundColor Green
Write-Host "Now deploy with: fly deploy" -ForegroundColor Yellow
