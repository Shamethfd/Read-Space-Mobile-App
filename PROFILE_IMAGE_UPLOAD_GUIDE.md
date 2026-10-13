# Profile Picture and Book Cover Image Upload - Implementation Guide

## Overview
Added profile picture upload functionality for both members and librarians, and book cover image upload for librarians. All images are stored in Firebase Storage and URLs are saved to Firestore.

## Features Implemented

### 1. Member Profile Picture Upload (`edit_profile_page.dart`)

**Features:**
- Upload profile picture from gallery
- Take photo with camera
- Remove existing profile picture
- Image preview before saving
- Automatic upload to Firebase Storage
- URL saved to Firestore user document

**Image Path:** `profile_pictures/{userId}/profile_{userId}_{timestamp}.jpg`

**How it works:**
1. Tap on profile picture avatar
2. Choose from gallery or take photo
3. Preview selected image
4. Save profile - image uploads to Firebase Storage
5. URL saved to Firestore user document

### 2. Librarian Profile Picture Upload (`librarian_profile_screen.dart`)

**Features:**
- Upload profile picture from gallery
- Take photo with camera
- Image preview
- Automatic upload to Firebase Storage
- URL saved to Firestore user document
- Display phone number and email from Firestore

**Image Path:** `profile_pictures/{userId}/profile_{userId}_{timestamp}.jpg`

**How it works:**
1. Tap on profile picture avatar with camera icon
2. Choose from gallery or take photo
3. Image uploads automatically
4. URL saved to Firestore
5. Profile updates with new picture

### 3. Book Cover Image Upload (`librarian_add_book_screen.dart`)

**Features:**
- Upload book cover from gallery
- Image preview with remove option
- Automatic upload to Firebase Storage
- URL saved to Firestore book document
- Optional field (book can be added without cover)

**Image Path:** `book_covers/book_cover_{timestamp}.jpg`

**How it works:**
1. Tap on book cover placeholder
2. Select image from gallery
3. Preview image with remove button
4. Add book - image uploads to Firebase Storage
5. URL saved to Firestore book document as `coverImageUrl`

## Technical Details

### Dependencies Used
- `image_picker` - For picking images from gallery/camera
- `firebase_storage` - For storing images
- `cloud_firestore` - For saving image URLs
- `dart:io` - For file handling

### Storage Service (`storage_service.dart`)
The existing `StorageService` class provides:
- `uploadImage()` - Upload file to Firebase Storage
- `uploadFromGallery()` - Pick and upload from gallery
- `uploadFromCamera()` - Capture and upload from camera
- `deleteFile()` - Delete file from storage
- `getDownloadURL()` - Get download URL

### Image Settings
- **Quality:** 80-85% (compressed for faster upload)
- **Max Dimensions:**
  - Profile pictures: 400x400px
  - Book covers: 800x1200px
- **Format:** JPEG
- **File Naming:** Timestamp-based to avoid conflicts

## Usage Examples

### Member Uploading Profile Picture
```dart
// User taps profile picture in Edit Profile
// Dialog shows options: Gallery, Camera, Remove
// User selects image from gallery
// Image preview shown
// User clicks Save
// Image uploads to: profile_pictures/{userId}/profile_{userId}_{timestamp}.jpg
// URL saved to Firestore: users/{userId}.profileImageUrl
```

### Librarian Uploading Profile Picture
```dart
// Librarian taps profile picture with camera icon
// Dialog shows options: Gallery, Camera
// Librarian selects image
// Image uploads immediately
// URL saved to Firestore: users/{userId}.profileImageUrl
// Profile screen refreshes with new picture
```

### Librarian Adding Book with Cover
```dart
// Librarian taps book cover placeholder
// Selects image from gallery
// Image preview shown with remove button
// Fills other book details
// Clicks Add Book
// Image uploads to: book_covers/book_cover_{timestamp}.jpg
// URL saved to Firestore: books/{bookId}.coverImageUrl
```

## Error Handling

All upload operations include:
- Try-catch blocks for error handling
- Loading states during upload
- User-friendly error messages via SnackBar
- Proper state management

## UI Changes

### Edit Profile Page
- Profile avatar now has camera icon overlay
- Tap to open image picker dialog
- Image preview updates immediately when image selected
- Remove option shown if image exists

### Librarian Profile Screen
- Profile avatar has camera icon overlay
- Tap to open image picker dialog
- Displays phone number and email from Firestore
- Immediate upload and update

### Add Book Screen
- Book cover placeholder changed to interactive widget
- Image preview with remove button
- Larger image size (120x160) for better preview
- Optional field - can add book without cover

## Storage Structure

```
Firebase Storage/
├── profile_pictures/
│   ├── {userId}/
│   │   ├── profile_{userId}_{timestamp1}.jpg
│   │   └── profile_{userId}_{timestamp2}.jpg
└── book_covers/
    ├── book_cover_{timestamp1}.jpg
    └── book_cover_{timestamp2}.jpg
```

## Firestore Schema Updates

### Users Collection
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "+1234567890",
  "profileImageUrl": "https://storage.googleapis.com/...",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Books Collection
```json
{
  "title": "Book Title",
  "author": "Author Name",
  "coverImageUrl": "https://storage.googleapis.com/...",
  "isbn": "1234567890",
  ...
}
```

## Benefits

✅ **Professional Appearance** - Users can personalize their profiles
✅ **Better Book Presentation** - Book covers make the catalog more attractive
✅ **Easy to Use** - Simple tap-to-upload interface
✅ **Flexible** - Gallery and camera options
✅ **Optional** - Can add books without covers
✅ **Optimized** - Compressed images for faster uploads
✅ **Organized** - Clear storage structure with user-specific paths

## Testing Checklist

- [ ] Member can upload profile picture from gallery
- [ ] Member can take photo with camera
- [ ] Member can remove profile picture
- [ ] Profile picture saves to Firestore
- [ ] Profile picture displays correctly
- [ ] Librarian can upload profile picture
- [ ] Librarian profile displays phone and email
- [ ] Librarian can add book with cover image
- [ ] Librarian can add book without cover image
- [ ] Book cover image displays in book details
- [ ] Error handling works for failed uploads
- [ ] Loading states show during upload

## Notes

- Profile pictures are stored per-user for better organization
- Book covers are stored in a shared folder
- Images are compressed to save storage space
- Timestamp-based naming prevents conflicts
- All uploads use the existing StorageService for consistency
