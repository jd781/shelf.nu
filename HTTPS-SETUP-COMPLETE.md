# HTTPS Production Setup - Completed!

## What We Just Did:

✅ Generated SSL certificates for your network:
- Computer hostname: desktop-2r1gsn5
- IP address: 192.168.25.184  
- Certificates located in: `./cert/desktop-2r1gsn5+3.pem` and `./cert/desktop-2r1gsn5+3-key.pem`
- Expires: January 15, 2028

✅ Updated `vite.config.ts` to use HTTPS with new certificates

✅ Updated `.env` file:
- Changed all URLs from http:// to https://
- Removed NODE_ENV=development (production mode enabled)

✅ Built for production with HTTPS support

✅ Server is now running on: **https://192.168.25.184:3000**

---

## IMPORTANT: Update Supabase Auth URLs

Before testing login, you MUST update your Supabase redirect URLs:

1. Go to: https://supabase.com/dashboard/project/jvdnbkrzvtfsqfxvdqgj

2. Navigate to: **Authentication** → **URL Configuration**

3. Update **Site URL** to:
   ```
   https://192.168.25.184:3000
   ```

4. Update **Redirect URLs** to include:
   ```
   https://192.168.25.184:3000/**
   https://192.168.25.184:3000/reset-password
   https://192.168.25.184:3000/join
   ```

5. Click **Save**

---

## Testing Instructions

### On This Computer:

1. Open browser and go to: **https://192.168.25.184:3000**
2. You may see a certificate warning - click "Advanced" and "Proceed" (mkcert is trusted)
3. Try logging in
4. Navigate to /assets page and verify it loads

### On Other Devices (Phone, Laptop, etc.):

**First time setup:**

1. On this computer, find your mkcert root CA:
   ```powershell
   mkcert -CAROOT
   ```
   The path will be something like: `C:\Users\Admin\AppData\Local\mkcert`

2. Copy the `rootCA.pem` file from that directory to your phone/device

3. Install the certificate:
   - **Android**: Settings → Security → Install from storage → Select rootCA.pem
   - **iOS**: Email rootCA.pem to yourself → Open → Install → Settings → General → About → Certificate Trust Settings → Enable
   - **Mac/Windows**: Double-click rootCA.pem and follow prompts

4. Once installed, browse to: **https://192.168.25.184:3000**

---

## Verification Checklist

- [ ] Supabase Auth URLs updated to HTTPS
- [ ] Can access https://192.168.25.184:3000 in browser
- [ ] Login works without redirecting back to login
- [ ] /assets page loads correctly (no "Cannot read properties of undefined" error)
- [ ] Session persists after page refresh
- [ ] Can create/edit assets
- [ ] Email invites work

---

## Current Status

**Server Running:** YES (https://192.168.25.184:3000)  
**HTTPS Enabled:** YES  
**Production Mode:** YES  
**Supabase URLs Updated:** ⚠️ **YOU NEED TO DO THIS NOW**

---

## Next Steps After Testing

Once everything works:

1. **Set up Windows Service** for auto-start (see PRODUCTION_SETUP.md Step 4)
2. **Configure Windows Firewall** to allow port 3000 (see PRODUCTION_SETUP.md Step 5)
3. **Set up automated backups** (see PRODUCTION_SETUP.md Step 6)

---

## Troubleshooting

### "Your connection is not private" warning:
- Click "Advanced" → "Proceed to 192.168.25.184 (unsafe)"
- OR install mkcert root CA certificate on your device (recommended)

### Still getting redirected to /login after logging in:
- Verify Supabase Auth URLs are updated to https://
- Clear browser cookies for 192.168.25.184
- Check browser console for errors (F12)

### Can't access from phone:
- Make sure phone is on same WiFi network (192.168.25.x)
- Install mkcert root CA on phone first
- Firewall may be blocking - run: `New-NetFirewallRule -DisplayName "Shelf Assets" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -Profile Private`

---

**Created:** October 15, 2025
**Server:** https://192.168.25.184:3000
**Computer:** DESKTOP-2R1GSN5
