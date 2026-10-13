# Firebase Storage Setup Guide

## Error: `[firebase_storage/object-not-found] No object exists at the desired reference`

This error occurs when Firebase Storage is not properly configured or the storage bucket doesn't exist.

## Solution Steps

### 1. Check Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `readspace-b5faf`
3. Navigate to **Storage** from the left menu
4. If you see a "Get Started" button, click it to enable Storage
5. If Storage is already enabled, check the bucket name matches your config

### 2. Verify Storage Bucket Configuration

Your Firebase configuration shows:
```
storageBucket: 'readspace-b5faf.firebasestorage.app'
```

This should match the bucket name in Firebase Console.

### 3. Check Storage Rules

In Firebase Console → Storage → Rules, ensure your rules allow uploads:

**For Development (Open Access):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

**For Production (User Authenticated):**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /book_covers/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 4. Test Upload

After configuring Storage, try uploading a book cover again. The app now includes:

- ✅ Detailed error logging
- ✅ Progress tracking
- ✅ Graceful fallback (book added without cover if upload fails)
- ✅ User-friendly error messages

### 5. Check Firebase Project Status

Ensure:
- ✅ Project is not in "Spark" plan (limited features)
- ✅ Storage is enabled in the project
- ✅ Authentication is working (for auth-based rules)

## Current Configuration

Your `firebase_options.dart` has:
- Project ID: `readspace-b5faf`
- Storage Bucket: `readspace-b5faf.firebasestorage.app`
- This is correctly configured across all platforms

## If Issue Persists

1. **Re-create Storage Bucket:**
   - Delete existing bucket in Firebase Console
   - Create new bucket with default settings
   - Update `storageBucket` in `firebase_options.dart` if needed

2. **Check Firebase Status:**
   - Visit [Firebase Status Dashboard](https://status.firebase.google.com/)
   - Check if Firebase Storage is experiencing outages

3. **Verify Dependencies:**
   ```bash
   flutter pub get
   flutter clean
   flutter pub run
   ```

4. **Test with Simple Upload:**
   Create a simple test to verify Storage works:
   ```dart
   final storage = FirebaseStorage.instance;
   final ref = storage.ref().child('test.txt');
   await ref.putString('Hello World');
   ```

## Storage Paths Used by App

- **Profile Pictures:** `profile_pictures/{userId}/profile_{userId}_{timestamp}.jpg`
- **Book Covers:** `book_covers/book_cover_{timestamp}.jpg`
- **Fine Appeals:** `fineAppeals/{userId}/{appealId}/proof/{timestamp}.jpg`

## Debug Information

The app now logs detailed information:
- ✅ Storage initialization status
- ✅ File existence and size
- ✅ Upload progress percentage
- ✅ Download URL after upload
- ✅ Specific error codes and messages

Check your console output for these logs when testing.

## Temporary Workaround

If Firebase Storage cannot be configured immediately, the app will:
- Continue adding books without cover images
- Show a warning message about failed upload
- Allow profile picture upload attempts with fallback

Book functionality will work normally without cover images.
