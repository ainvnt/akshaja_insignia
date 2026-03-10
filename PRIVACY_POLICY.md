# Privacy Policy

Last updated: March 11, 2026

Akshaja Insignia ("we", "our", "us") provides a mobile application for capturing maintenance evidence photos with date, time, and location details, and for managing user sign-in and profile information required to use the app.

This Privacy Policy explains what data the app handles, how it is used, and your choices.

## 1. Data We Collect

The app may collect and process the following information when you use app features:

- Account and profile information you provide during registration or profile updates, such as full name, email address, and mobile number
- Authentication-related identifiers and account metadata, such as user ID, registration/sign-in method, created date, updated date, and last login date
- Photos captured using the in-app camera
- Location data (latitude and longitude) at the time of capture
- Capture date and time
- Technical metadata related to upload status (for example: pending/uploaded)

If you choose Google sign-in, the app may also receive basic account information made available by your Google account for authentication purposes, such as your name and email address.

## 2. How We Use Data

We use this data to:

- Create and manage your account
- Authenticate sign-in and maintain your signed-in session
- Store and update your user profile information
- Support account management features such as profile editing and password changes
- Generate evidence photos with visible watermark details (date, time, latitude, longitude)
- Store photos and metadata on your device for offline operation
- Upload photos to configured cloud storage when you choose upload or when sync runs
- Track upload state so pending images can be retried

## 3. Authentication and Profile Data

- The app uses Firebase Authentication to support sign-in and account access.
- The app currently supports email/password sign-in and Google sign-in.
- User profile records are stored in Cloud Firestore and may include fields such as display name, email, mobile number, user ID, registration method, createdAt, updatedAt, and lastLoginAt.
- If you change your password in the app, that update is processed through the authentication provider and related profile timestamps may be updated.

## 4. Storage and Cloud Upload

- Photos and metadata are first stored locally on your device.
- If upload is triggered, photos are uploaded to cloud storage (Amazon S3 path configured by the app owner).
- Uploaded cloud images may be stored in AVIF format.
- The app may continue to display cloud copies even after local deletion.
- Account authentication data and profile records may be stored with Firebase services used by the app.

## 5. Permissions We Request

The app requests these permissions only to enable core features:

- Camera: to capture photos
- Location: to capture latitude/longitude for watermark and metadata
- Storage/Media: to save and manage local image files
- Internet: to upload images and sync pending records

## 6. Offline Behavior

The app supports offline operation:

- Captured photos are saved locally when internet is unavailable.
- Upload status remains pending until connectivity is available.
- Some account and profile actions may require an internet connection to complete.

## 7. Data Sharing

We do not sell personal data.

Data is shared only with service providers and cloud infrastructure required to operate the app, such as:

- Firebase Authentication for account sign-in and authentication workflows
- Cloud Firestore for storing user profile data and account metadata
- Amazon S3 for storing uploaded images and related media assets

## 8. Data Retention and Deletion

- Local photos remain on device until deleted by the user or app workflow.
- Users can delete local copies after upload to reduce device storage usage.
- Cloud retention follows your organization/cloud bucket policies.
- Account and profile records may remain in backend systems until deleted under your organization's operational or legal retention policies.

## 9. Security and Advertising ID

- We use reasonable measures to protect data in transit and storage. However, no system is completely secure.
- The app is not intended to use advertising ID for advertising purposes.

## 10. Children’s Privacy

This app is not directed to children under 13.

## 11. Changes to This Policy

We may update this Privacy Policy from time to time. Updated versions will be posted at the same public URL.

## 12. Contact

For privacy questions or requests, contact:

- Email: ainvnt@outlook.com
