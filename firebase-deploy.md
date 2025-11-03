# Firebase Hosting Setup Guide

## Initial Setup (One-time)

1. **Login to Firebase:**
   ```bash
   firebase login
   ```
   This will open a browser for authentication.

2. **Initialize Firebase Project:**
   ```bash
   firebase init hosting
   ```
   Select or create a Firebase project when prompted.

   - What do you want to use as your public directory? → `build/web`
   - Configure as a single-page app? → Yes
   - Set up automatic builds and deploys with GitHub? → No (or Yes if you want CI/CD)

3. **Build Flutter Web:**
   ```bash
   flutter build web --release
   ```

4. **Deploy to Firebase:**
   ```bash
   firebase deploy --only hosting
   ```

## Quick Deploy Script

For future deployments, you can use:

```bash
flutter build web --release && firebase deploy --only hosting
```

## Firebase Configuration

- Configuration files created:
  - `firebase.json` - Hosting configuration with SPA rewrites
  - `.firebaserc` - Firebase project settings (will be populated after init)

## Notes

- All routes (`/view`, `/edit`, etc.) will work correctly with the SPA rewrite rules
- Static assets are cached for 1 year
- HTML/JSON files are not cached for dynamic content
- The build output directory is `build/web`

