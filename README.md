# Patient Management App

A Flutter application designed for medical professionals to track patient data and progress across various stages of care, with structured evaluations and assessments.

## Key Features
- **Patient Management**: Add, edit, and view detailed patient records.
- **Stage Tracking**: Monitor patient progress through:
  - Stage 1: Pre-Surgery
  - Stage 2: Post-Surgery
  - Stage 3: Quality of Life Assessment
  - Stage 4: Completed
- **Score Calculation**:
  - **Anxiety Score**: Automatically calculated based on questionnaire responses (pre- and post-surgery).
  - **Quality of Life Score**: Stored as a single final value, fetched directly from the form.
- **Surgery Date Filter**: Quickly filter patients based on their scheduled surgery date,sex and stage.
- **Search and Ordering**:
  - Alphabetical sorting of patients.
  - searching is added.
- **Stage-Aware Forms**: Automatically fetch current stage from Firestore (no longer passed from navigation).

## Technologies Used
- Flutter & Dart
- Firebase 

## Addtional features
- made dart program for exporting and importing userdata

## Upcoming Features
- Secure authentication

## License
This project is licensed under the MIT License.
