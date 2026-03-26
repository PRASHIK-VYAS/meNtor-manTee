import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/semester_model.dart';
import '../models/leaderboard_member.dart';
import '../models/internship_model.dart';
import '../models/certification_model.dart';
import '../models/activity_model.dart';
import '../models/task_model.dart';
import '../models/meeting_model.dart';
import '../models/broadcast_model.dart';
import '../models/document_request_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class StudentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;
  String? _lastLoadedUserId;
  final Set<String> _dismissedNotifications = {};

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.userId != null && _authProvider?.userRole == 'student') {
      final userId = _authProvider!.userId!;
      // Avoid reloading if already loaded for this user
      if (_lastLoadedUserId != userId) {
        _lastLoadedUserId = userId;
        // Schedule after the current build frame to avoid setState-during-build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadStudentData(userId);
        });
      }
    }
  }

  StudentModel? _currentStudent;
  List<SemesterModel> _semesters = [];
  List<InternshipModel> _internships = [];
  List<CertificationModel> _certifications = [];
  List<ActivityModel> _activities = [];
  List<TaskModel> _tasks = [];
  List<MeetingModel> _meetings = [];
  List<DocumentRequestModel> _documentRequests = [];
  List<BroadcastModel> _broadcasts = [];
  bool _isLoading = false;

  StudentModel? get currentStudent => _currentStudent;
  List<SemesterModel> get semesters => _semesters;
  List<InternshipModel> get internships => _internships;
  List<CertificationModel> get certifications => _certifications;
  List<ActivityModel> get activities => _activities;
  List<TaskModel> get tasks => _tasks;
  List<MeetingModel> get meetings => _meetings;
  List<BroadcastModel> get broadcasts => _broadcasts;
  List<DocumentRequestModel> get documentRequests => _documentRequests;
  int get pendingRequestsCount =>
      _documentRequests.where((r) => r.status == 'Pending').length;
  bool get isLoading => _isLoading;

  // Load student data
  Future<void> loadStudentData(String studentId) async {
    try {
      print('DEBUG: loadStudentData called for Student ID: $studentId');
      _isLoading = true;
      _dismissedNotifications.clear(); // Reset on fresh load
      notifyListeners();

      print('DEBUG: Calling Student profile endpoint...');
      final studentResult = await _apiService.get('/students/$studentId');
      _currentStudent = StudentModel.fromMap(studentResult);
      print('DEBUG: Student profile loaded: ${_currentStudent?.fullName}');
      
      final mentorId = _currentStudent?.mentorId;

      print('DEBUG: Calling remaining Student endpoints...');
      final results = await Future.wait([
        _apiService.get('/semesters/student/$studentId'),
        _apiService.get('/tasks/student/$studentId'),
        _apiService.get('/certifications/student/$studentId'),
        _apiService.get('/internships/student/$studentId'),
        mentorId != null ? _apiService.get('/broadcasts/mentor/$mentorId') : Future.value([]),
        _apiService.get('/meetings/student/$studentId'),
        _apiService.get('/documents'),
        _apiService.get('/activities/student/$studentId'),
      ]);
      print('DEBUG: All student data calls completed.');

      _semesters = (results[0] as List)
          .map((data) => SemesterModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_semesters.length} semesters');

      _tasks =
          (results[1] as List).map((data) => TaskModel.fromMap(data)).toList();
      print('DEBUG: Loaded ${_tasks.length} tasks');

      _certifications = (results[2] as List)
          .map((data) => CertificationModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_certifications.length} certifications');

      _internships = (results[3] as List)
          .map((data) => InternshipModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_internships.length} internships');

      _broadcasts = (results[4] as List)
          .map((data) => BroadcastModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_broadcasts.length} broadcasts');

      _meetings = (results[5] as List)
          .map((data) => MeetingModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_meetings.length} meetings');

      _documentRequests = (results[6] as List)
          .map((data) => DocumentRequestModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_documentRequests.length} documents');

      _activities = (results[7] as List)
          .map((data) => ActivityModel.fromMap(data))
          .toList();
      print('DEBUG: Loaded ${_activities.length} activities');

      _calculateStudentMetrics();
      print('DEBUG: Metrics calculated.');
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      _isLoading = false;
      notifyListeners();
      print('DEBUG ERROR: loadStudentData failed: $e');
      print('DEBUG STACK: $stack');
    }
  }

  void _calculateStudentMetrics() {
    if (_currentStudent == null) return;

    // 1. Calculate CGPA from Semesters
    if (_semesters.isNotEmpty) {
      // Use the CGPA of the latest available semester as current CGPA
      final sortedSems = List<SemesterModel>.from(_semesters)
        ..sort((a, b) => b.semesterNumber.compareTo(a.semesterNumber));
      final latestSem = sortedSems.first;

      _currentStudent = _currentStudent!.copyWith(
        currentCGPA: latestSem.cgpa > 0 ? latestSem.cgpa : latestSem.sgpa,
      );
    }

    // 2. Sync Pending Tasks
    int pendingCount = _tasks.where((t) => t.status != 'Completed').length;

    // 2b. Sync Upcoming Meetings
    int meetingCount = _meetings.where((m) => m.status == 'Scheduled').length;

    // 2c. Calculate Document Completion based on Submitted/Verified Base Documents
    double docProgress = 0.0;

    // Total standard documents in StudentDocumentsScreen (Resume, ID, 10th, 12th, Internship)
    const int totalRequiredDocuments = 5;

    if (_currentStudent != null &&
        _currentStudent!.documentStatuses.isNotEmpty) {
      // Calculate how many documents have status 'Uploaded', 'Verified', 'Approved' or 'Pending Approval'
      int filledDocs = _currentStudent!.documentStatuses.values
          .where((status) =>
              status == 'Uploaded' ||
              status == 'Verified' ||
              status == 'Approved' ||
              status == 'Pending Approval' ||
              status == 'Submitted')
          .length;

      docProgress = (filledDocs / totalRequiredDocuments) * 100;
      if (docProgress > 100) docProgress = 100.0; // clamp
    }

    // 2d. Calculate Unread Broadcasts (stub for now, usually handled by backend)
    int unreadCount = _currentStudent?.unreadBroadcasts ?? 0;

    // 3. Calculate Credit Score (Aligned with Backend getLeaderboard)
    double cgpaScore = (_currentStudent!.currentCGPA / 10.0) * 50;

    // Sum points of verified certifications capped at 10
    final verifiedCerts = _certifications.where((c) => c.isVerified).toList();
    int totalCertPoints =
        verifiedCerts.fold<int>(0, (sum, c) => sum + (c.points));
    int certScore = totalCertPoints > 10 ? 10 : totalCertPoints;

    int internshipScore = (_internships.length * 10).clamp(0, 20);

    final completedTasksCount =
        _tasks.where((t) => t.status == 'Completed').length;
    int taskScore = (completedTasksCount * 2).clamp(0, 20);

    final attendedMeetingsCount = _meetings
        .where((m) => m.status == 'Completed' || m.status == 'Attended')
        .length;
    int meetingScore = (attendedMeetingsCount * 2).clamp(0, 10);

    double totalCreditScore = (cgpaScore +
            certScore +
            internshipScore +
            taskScore +
            meetingScore)
        .toDouble();

    // 3b. Subtract dismissed notifications from counts for UI consistency
    if (_dismissedNotifications.contains('tasks')) pendingCount = 0;
    if (_dismissedNotifications.contains('meetings')) meetingCount = 0;
    if (_dismissedNotifications.contains('broadcasts')) unreadCount = 0;
    if (_dismissedNotifications.contains('documents')) docProgress = 100.0;

    _currentStudent = _currentStudent!.copyWith(
      pendingTasks: pendingCount,
      upcomingMeetings: meetingCount,
      documentCompletion: docProgress,
      unreadBroadcasts: unreadCount,
      creditScore: totalCreditScore,
      totalInternships: _internships.length,
      certificationPoints: certScore, // Use capped points for consistency
    );

    // If it's dismissed, we might need a way to flag it in the model or just filter in UI.
    // For simplicity, we'll keep the model as is and filter the notification screen.
  }

  void dismissNotification(String type) {
    _dismissedNotifications.add(type);
    _calculateStudentMetrics();
    notifyListeners();
  }

  void clearAllNotifications() {
    _dismissedNotifications
        .addAll(['broadcasts', 'meetings', 'tasks', 'documents']);
    _calculateStudentMetrics();
    notifyListeners();
  }

  // Add semester
  Future<void> addSemester(SemesterModel semester) async {
    try {
      await _apiService.post('/semesters', semester.toMap());
      await loadStudentData(semester.studentId);
    } catch (e) {
      print('Error adding semester: $e');
      rethrow;
    }
  }

  // Add internship
  Future<void> addInternship(InternshipModel internship) async {
    try {
      await _apiService.post('/internships', internship.toMap());
      await loadStudentData(internship.studentId);
    } catch (e) {
      print('Error adding internship: $e');
      rethrow;
    }
  }

  // Add certification
  Future<void> addCertification(CertificationModel certification) async {
    try {
      await _apiService.post('/certifications', certification.toMap());
      await loadStudentData(certification.studentId);
    } catch (e) {
      print('Error adding certification: $e');
      rethrow;
    }
  }

  // Update task status
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _apiService.patch('/tasks/$taskId', {'status': status});
      if (_currentStudent != null) {
        await loadStudentData(_currentStudent!.id);
      }
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }

  // Submit task with file
  Future<void> submitTaskWithFile(String taskId, String fileName) async {
    try {
      await _apiService.patch('/tasks/$taskId', {
        'status': 'Submitted',
        'submission_url': fileName,
      });
      if (_currentStudent != null) {
        await loadStudentData(_currentStudent!.id);
      }
    } catch (e) {
      print('Error submitting task with file: $e');
      rethrow;
    }
  }

  // Join a batch via mentor code
  Future<bool> joinBatch(String code) async {
    try {
      // In Supabase version, we just update the student's mentor_id if found
      // This would require a specialized endpoint or updating student directly
      // For now, we'll assume a PATCH /students/profile with mentorCode
      await _apiService.patch('/auth/profile', {'mentorCode': code});
      if (_currentStudent != null) {
        await loadStudentData(_currentStudent!.id);
      }
      return true;
    } catch (e) {
      print('Error joining batch: $e');
      return false;
    }
  }

  Future<void> refreshBroadcasts() async {
    try {
      final mentorId = _currentStudent?.mentorId;
      final results = mentorId != null
          ? await _apiService.get('/broadcasts/mentor/$mentorId')
          : [];
      _broadcasts = (results as List)
          .map((data) => BroadcastModel.fromMap(data))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error refreshing broadcasts: $e');
    }
  }

  Future<void> refreshMeetings() async {
    try {
      if (_currentStudent != null) {
        final results =
            await _apiService.get('/meetings/student/${_currentStudent!.id}');
        _meetings = (results as List)
            .map((data) => MeetingModel.fromMap(data))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing meetings: $e');
    }
  }

  // Document Request Methods
  Future<void> uploadDocumentForRequest(
      String requestId, String filePath) async {
    try {
      await _apiService.patch('/documents/$requestId',
          {'status': 'Uploaded', 'filePath': filePath});
      if (_currentStudent != null) {
        await loadStudentData(_currentStudent!.id);
      }
    } catch (e) {
      print('Error uploading document for request: $e');
      rethrow;
    }
  }

  // Update semester
  Future<dynamic> updateSemester(SemesterModel semester) async {
    try {
      dynamic semId;
      if (semester.id == null || semester.id == '' || semester.id == '0') {
        try {
          final result = await _apiService.post('/semesters', semester.toMap());
          semId = result['id'];
        } catch (createErr) {
          // If the semester already exists on the server (409 / unique constraint),
          // fetch the list of semesters for this student and find the matching one.
          if (createErr.toString().contains('already exists')) {
            final existing = await _apiService
                .get('/semesters/student/${semester.studentId}');
            final list = existing as List;
            final found = list.firstWhere(
              (s) => s['semester_number'] == semester.semesterNumber,
              orElse: () => null,
            );
            if (found != null) {
              semId = found['id'];
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      } else {
        await _apiService.patch('/semesters/${semester.id}', semester.toMap());
        semId = semester.id;
      }
      await loadStudentData(semester.studentId.toString());
      return semId;
    } catch (e) {
      print('Error updating semester: $e');
      rethrow;
    }
  }

  // Add subject mark to a semester
  Future<void> addSubjectMark(String semesterId, SubjectMark mark) async {
    try {
      await _apiService.post(
          '/semesters/$semesterId/subject-marks', mark.toMap());
      if (_currentStudent != null) {
        await loadStudentData(_currentStudent!.id);
      }
    } catch (e) {
      print('Error adding subject mark: $e');
      rethrow;
    }
  }

  // Update internship
  Future<void> updateInternship(InternshipModel internship) async {
    try {
      if (internship.id == '' || internship.id == '0') {
        await _apiService.post('/internships', internship.toMap());
      } else {
        await _apiService.patch(
            '/internships/${internship.id}', internship.toMap());
      }
      await loadStudentData(internship.studentId);
    } catch (e) {
      print('Error updating internship: $e');
      rethrow;
    }
  }

  // Update certification
  Future<void> updateCertification(CertificationModel certification) async {
    try {
      if (certification.id == '' || certification.id == '0') {
        await _apiService.post('/certifications', certification.toMap());
      } else {
        await _apiService.patch(
            '/certifications/${certification.id}', certification.toMap());
      }
      await loadStudentData(certification.studentId);
    } catch (e) {
      print('Error updating certification: $e');
      rethrow;
    }
  }

  // Submit task
  Future<void> submitTask(TaskModel task) async {
    try {
      // Logic to submit usually means updating status or adding a new task?
      // "submitTask" in original code did upsert.
      // we have createTask and updateTaskStatus.
      if (task.id.isEmpty) {
        await _apiService.post('/tasks/${task.studentId}', task.toMap());
      } else {
        await _apiService.patch('/tasks/${task.id}', {'status': task.status});
      }
      await loadStudentData(task.studentId);
    } catch (e) {
      print('Error submitting task: $e');
      rethrow;
    }
  }

  // Update Activity
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      if (activity.id.isEmpty) {
        // Create new
        await _apiService.post('/activities', activity.toMap());
      } else {
        // Update existing (useful for editing)
        await _apiService.put('/activities/${activity.id}', activity.toMap());
      }

      if (_currentStudent != null) {
        await loadStudentData(_currentStudent!.id);
      }
    } catch (e) {
      print('Error updating activity: $e');
      rethrow;
    }
  }

  // Update document status
  Future<void> updateDocumentStatus(String docTitle, String status,
      {String? filePath}) async {
    try {
      // This was for local usage "documentStatuses" map in student model.
      // Backend has "document_requests" table now.
      // But maybe the student model still has "documentStatuses" for the basic docs?
      // Yes, StudentModel has 'documentStatuses'.
      // We need a way to update student profile's document statuses.
      // We can use updateProfile in authController.
      // But we need to handle the map update there.
      // For now, let's stub or try profile update.
      if (_currentStudent != null) {
        final updatedDocs =
            Map<String, String>.from(_currentStudent!.documentStatuses);
        updatedDocs[docTitle] = status;

        final updatedPaths =
            Map<String, String>.from(_currentStudent!.documentFilePaths);
        if (filePath != null) {
          updatedPaths[docTitle] = filePath;
        }

        await _apiService.patch('/auth/profile', {
          'documentStatuses': updatedDocs,
          'documentFilePaths': updatedPaths,
        });

        if (status == 'Pending Approval') {
          await _apiService.post('/documents', {
            'student_id': _currentStudent!.id,
            'mentor_id': _currentStudent!.mentorId,
            'type': 'Document',
            'title': docTitle,
            'description': 'Verification required for $docTitle',
            'file_path': filePath ?? '',
            'status': 'Pending',
          });
        }

        await loadStudentData(_currentStudent!.id);
      }
    } catch (e) {
      print('Error updating document status: $e');
      rethrow;
    }
  }

  // Get leaderboard
  Future<List<LeaderboardMember>> getLeaderboard() async {
    try {
      final response = await _apiService.get('/students/leaderboard');
      final List<dynamic> data = response;
      return data.map((json) => LeaderboardMember.fromMap(json)).toList();
    } catch (e) {
      print('Error loading leaderboard: $e');
      return [];
    }
  }
}
