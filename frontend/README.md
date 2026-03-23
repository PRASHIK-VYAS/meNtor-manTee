# MentorTrack - College Mentorship & Student Performance Tracking App

A comprehensive Flutter mobile application for managing mentorship relationships and tracking student performance in college.

## Features

### Student Features
- **Dashboard**: Overview of CGPA, internships, certifications, and pending tasks
- **Profile**: View personal information (read-only, editable by mentor)
- **Academic Records**: View semester-wise SGPA/CGPA (Sem 1-8 for Regular, Sem 3-8 for DSE)
- **Internships**: Add and view internship records with certificate upload
- **Certifications**: Manage certifications by category (Technical, Non-Technical, Curriculum, Extra-Curricular, Participation)
- **Activities**: Track co/extra-curricular activities with proof upload
- **Mentor Tasks**: View assigned tasks, submit work, and see mentor remarks

### Mentor Features
- **Dashboard**: Overview of assigned students, pending tasks, and low CGPA alerts
- **Student List**: View all assigned students with search functionality
- **Student Detail View**: Comprehensive student information with tabs:
  - Profile (editable)
  - Academics (edit SGPA, result status)
  - Internships (verify)
  - Certifications (assign points)
  - Activities
  - Tasks (assign new tasks)
- **Assign Task**: Create and assign tasks to students
- **Meeting Log**: Record meeting notes, issues, suggestions, and action items

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Provider
- **Backend**: Firebase
  - Authentication (Firebase Auth)
  - Database (Cloud Firestore)
  - Storage (Firebase Storage)
- **Design**: Material 3

## Project Structure

```
lib/
├── models/              # Data models
│   ├── student_model.dart
│   ├── mentor_model.dart
│   ├── semester_model.dart
│   ├── internship_model.dart
│   ├── certification_model.dart
│   ├── activity_model.dart
│   ├── task_model.dart
│   └── meeting_log_model.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── student_provider.dart
│   └── mentor_provider.dart
├── services/           # Firebase services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── screens/
│   ├── auth/           # Authentication screens
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── student/        # Student screens
│   │   ├── student_main_screen.dart
│   │   ├── student_dashboard_screen.dart
│   │   ├── student_profile_screen.dart
│   │   ├── academic_records_screen.dart
│   │   ├── internships_screen.dart
│   │   ├── add_internship_screen.dart
│   │   ├── certifications_screen.dart
│   │   ├── activities_screen.dart
│   │   └── mentor_tasks_screen.dart
│   └── mentor/         # Mentor screens
│       ├── mentor_main_screen.dart
│       ├── mentor_dashboard_screen.dart
│       ├── student_list_screen.dart
│       ├── student_detail_view.dart
│       ├── assign_task_screen.dart
│       ├── meeting_log_screen.dart
│       └── tabs/        # Student detail tabs
│           ├── profile_tab.dart
│           ├── academics_tab.dart
│           ├── internships_tab.dart
│           ├── certifications_tab.dart
│           ├── activities_tab.dart
│           └── tasks_tab.dart
├── widgets/            # Reusable widgets
└── main.dart          # App entry point
```

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Firebase account

### 2. Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Enable Storage

2. **Android Configuration**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/` directory

3. **iOS Configuration** (if developing for iOS)
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/` directory

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## Firestore Collections Structure

The app uses the following Firestore collections:

- `students` - Student profiles
- `mentors` - Mentor profiles
- `semesters` - Academic semester records
- `internships` - Internship records
- `certifications` - Certification records
- `activities` - Activity records
- `tasks` - Task assignments
- `meetingLogs` - Meeting log entries

## Firebase Storage Structure

- `certificates/{studentId}/{type}/{itemId}` - Certificate files
- `proofs/{studentId}/{activityId}` - Activity proof files
- `task_submissions/{studentId}/{taskId}` - Task submission files
- `task_resources/{mentorId}/{taskId}` - Task resource files

## Important Notes

1. **Firebase Configuration Required**: The app will not run until Firebase is properly configured with the required files.

2. **Mock Data**: Currently, the app uses Firebase for data storage. For testing without Firebase, you can modify the providers to use local mock data.

3. **File Uploads**: Certificate and file upload functionality requires Firebase Storage to be properly configured.

4. **Security Rules**: Make sure to set up proper Firestore security rules before deploying to production.

## Future Enhancements

- Push notifications
- Offline support
- Data export functionality
- Advanced analytics and reporting
- Multi-language support

## License

This project is created for educational purposes.
