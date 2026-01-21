# Fixing Email Confirmation Issue

## The Problem
When you sign up, Supabase sends a confirmation email with a link. That link tries to redirect to a URL that doesn't exist yet, causing an error.

## Quick Fix: Disable Email Confirmation (For Development)

1. Go to your Supabase dashboard
2. Navigate to **Authentication** → **Providers** → **Email**
3. Find **"Confirm email"** toggle
4. **Turn it OFF** (disable it)
5. Click **Save**

Now users can sign up and log in immediately without email confirmation!

## Alternative: Configure Redirect URL (For Production)

If you want to keep email confirmation enabled:

1. Go to **Authentication** → **URL Configuration**
2. Set **Site URL** to: `io.supabase.ping://login-callback/`
3. Add **Redirect URLs**:
   - `io.supabase.ping://login-callback/`
   - `http://localhost:3000` (for web testing)
4. Click **Save**

## For Now: Disable It

For development and testing, I recommend **disabling email confirmation**. You can re-enable it later when you're ready to deploy.

---

## Testing After Fix

1. Disable email confirmation in Supabase dashboard
2. Hot restart the app (`R` in terminal)
3. Try signing up again
4. Should work immediately without email verification!

---

## Next: Cloud Sync

Once email is working, I'll implement:
- ✅ Reminders sync to Supabase
- ✅ Real-time updates across devices
- ✅ Offline support
- ✅ Profile screen with sign out

Ready to continue?
