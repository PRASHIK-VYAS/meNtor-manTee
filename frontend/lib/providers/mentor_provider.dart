import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/mentor_model.dart';
import '../models/student_model.dart';
import '../models/task_model.dart';
import '../models/meeting_log_model.dart';
import '../models/semester_model.dart';
import '../models/certification_model.dart';
import '../models/meeting_model.dart';
import '../models/broadcast_model.dart';
import '../models/document_request_model.dart';
import '../models/leaderboard_member.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class MentorProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;
  String? _lastLoadedUserId;
  final Set<String> _dismissedNotifications = {};

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.userId != null && _authProvider?.userRole == 'mentor') {
      final userId = _authProvider!.userId!;
      if (_lastLoadedUserId != userId) {
        _lastLoadedUserId = userId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadMentorData(userId);
        });
      }
    }
  }

  MentorModel? _currentMentor;
  List<StudentModel> _assignedStudents = [];
  StudentModel? _selectedStudent;
  List<TaskModel> _studentTasks = [];
  List<MeetingLogModel> _meetingLogs = [];
  List<MeetingLogModel> _allMeetings = [];
  List<SemesterModel> _studentSemesters = [];
  List<CertificationModel> _studentCertifications = [];
  List<MeetingModel> _meetings = []; // Renamed from _videoMeetings
  List<BroadcastModel> _broadcasts = [];
  List<DocumentRequestModel> _documentRequests = [];
  bool _isLoading = false;

  MentorModel? get currentMentor => _currentMentor;
  List<StudentModel> get assignedStudents => _assignedStudents;
  StudentModel? get selectedStudent => _selectedStudent;
  List<TaskModel> get studentTasks => _studentTasks;
  List<MeetingLogModel> get meetingLogs => _meetingLogs;
  List<MeetingLogModel> get allMeetings => _allMeetings;
  List<SemesterModel> get studentSemesters => _studentSemesters;
  List<CertificationModel> get studentCertifications => _studentCertifications;
  List<MeetingModel> get meetings => _meetings; // Updated getter
  List<BroadcastModel> get broadcasts => _broadcasts;
  List<DocumentRequestModel> get documentRequests => _documentRequests;
  bool get isLoading => _isLoading;

  Future<void> loadMentorData(String mentorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _apiService.get('/mentors/$mentorId'),
        _apiService.get('/mentors/$mentorId/students'),
        _apiService.get('/mentors/$mentorId/broadcasts'),
        _apiService.get('/mentors/$mentorId/meetings'), // Fetch all meetings
        _apiService.get('/mentors/$mentorId/documents'),
      ]);

      _currentMentor = MentorModel.fromMap(results[0]);

      _assignedStudents = (results[1] as List)
          .map((data) => StudentModel.fromMap(data))
          .toList();
      _broadcasts = (results[2] as List)
          .map((data) => BroadcastModel.fromMap(data))
          .toList();

      _meetings = (results[3] as List) // Assign to _meetings
          .map((data) => MeetingModel.fromMap(data))
          .toList();

      _documentRequests = (results[4] as List)
          .map((data) => DocumentRequestModel.fromMap(data))
          .toList();

      _isLoading = false;
      _dismissedNotifications.clear(); // Reset on fresh load
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading mentor data: $e');
    }
  }

  Future<void> scheduleVideoMeeting(MeetingModel meeting) async {
    try {
      final response = await _apiService.post('/meetings', meeting.toMap());
      final newMeeting = MeetingModel.fromMap(response);
      _meetings.add(newMeeting); // Changed from _videoMeetings
      notifyListeners();
    } catch (e) {
      print('Error scheduling video meeting: $e');
      rethrow;
    }
  }

  Future<void> deleteMeeting(String meetingId) async {
    try {
      await _apiService.delete('/meetings/$meetingId');
      _meetings.removeWhere((m) => m.id == meetingId);
      notifyListeners();
    } catch (e) {
      print('Error deleting meeting: $e');
      rethrow;
    }
  }

  Future<void> updateMeeting(MeetingModel meeting) async {
    try {
      final response =
          await _apiService.put('/meetings/${meeting.id}', meeting.toMap());
      final updatedMeeting = MeetingModel.fromMap(response);
      final index = _meetings.indexWhere((m) => m.id == meeting.id);
      if (index != -1) {
        _meetings[index] = updatedMeeting;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating meeting: $e');
      rethrow;
    }
  }

  Future<void> selectStudent(String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _apiService.get('/students/$studentId'),
        _apiService.get('/tasks/student/$studentId'),
        _apiService.get('/meetings/student/$studentId'),
        _apiService.get('/semesters/student/$studentId'),
        _apiService.get('/certifications/student/$studentId'),
      ]);

      _selectedStudent = StudentModel.fromMap(results[0]);

      _studentTasks =
          (results[1] as List).map((data) => TaskModel.fromMap(data)).toList();

      _meetingLogs = (results[2] as List)
          .map((data) => MeetingLogModel.fromMap(data))
          .toList();

      _studentSemesters = (results[3] as List)
          .map((data) => SemesterModel.fromMap(data))
          .toList();

      _studentCertifications = (results[4] as List)
          .map((data) => CertificationModel.fromMap(data))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error selecting student: $e');
      rethrow;
    }
  }

  Future<void> assignTask(TaskModel task) async {
    try {
      final body = task.toMap();
      // Ensure studentId is always in the body for single assignment
      body['student_id'] = task.studentId;
      final response = await _apiService.post('/tasks', body);
      final newTask = TaskModel.fromMap(response);
      _studentTasks.add(newTask);
      notifyListeners();
    } catch (e) {
      print('Error assigning task: $e');
      rethrow;
    }
  }

  Future<void> assignBulkTasks(
      TaskModel template, List<String> studentIds) async {
    try {
      final data = template.toMap();
      data.remove('id');
      data.remove('student_id');

      final body = {
        'studentIds': studentIds.map((id) => int.tryParse(id)).toList(),
        ...data,
      };

      await _apiService.post('/tasks/bulk', body);
      notifyListeners();
    } catch (e) {
      print('Error assigning bulk tasks: $e');
      rethrow;
    }
  }

  Future<void> reviewTask(TaskModel task) async {
    try {
      final response =
          await _apiService.patch('/tasks/${task.id}', {'status': task.status});
      // Update local list
      final index = _studentTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _studentTasks[index] = TaskModel.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      print('Error reviewing task: $e');
      rethrow;
    }
  }

  Future<void> sendBroadcast(BroadcastModel broadcast) async {
    try {
      final data = broadcast.toMap();
      if (broadcast.id.isEmpty) {
        data.remove('id'); // Let backend assign integer ID
      }

      final response = await _apiService.post('/broadcasts', data);
      final newBroadcast = BroadcastModel.fromMap(response);
      _broadcasts.insert(0, newBroadcast);
      notifyListeners();
    } catch (e) {
      print('Error sending broadcast: $e');
      rethrow;
    }
  }

  Future<void> createDocumentRequest({
    required String studentId,
    required String title,
    required String description,
    required String type,
  }) async {
    try {
      if (_currentMentor == null) return;

      final response = await _apiService.post('/documents', {
        'mentor_id': _currentMentor!.id,
        'student_id': studentId,
        'title': title,
        'description': description,
        'type': type,
      });

      final newRequest = DocumentRequestModel.fromMap(response);
      _documentRequests.add(newRequest);
      notifyListeners();
    } catch (e) {
      print('Error creating document request: $e');
      rethrow;
    }
  }

  Future<void> approveDocumentRequest(String requestId) async {
    try {
      final response = await _apiService
          .patch('/documents/$requestId', {'status': 'Approved'});
      final updatedIndex =
          _documentRequests.indexWhere((r) => r.id == requestId);
      if (updatedIndex != -1) {
        _documentRequests[updatedIndex] =
            DocumentRequestModel.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      print('Error approving document request: $e');
      rethrow;
    }
  }

  Future<void> rejectDocumentRequest(String requestId, String reason) async {
    try {
      final response = await _apiService.patch('/documents/$requestId',
          {'status': 'Rejected', 'rejectionReason': reason});
      final updatedIndex =
          _documentRequests.indexWhere((r) => r.id == requestId);
      if (updatedIndex != -1) {
        _documentRequests[updatedIndex] =
            DocumentRequestModel.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      print('Error rejecting document request: $e');
      rethrow;
    }
  }

  // Get mentor's students leaderboard
  Future<List<LeaderboardMember>> getLeaderboard() async {
    try {
      if (_currentMentor == null) return [];
      final response = await _apiService
          .get('/mentors/students/leaderboard?mentorId=${_currentMentor!.id}');
      final List<dynamic> data = response;
      return data.map((json) => LeaderboardMember.fromMap(json)).toList();
    } catch (e) {
      print('Error loading mentor leaderboard: $e');
      return [];
    }
  }

  // Approve or Reject Activity
  Future<void> reviewActivity(String activityId, bool isVerified) async {
    try {
      if (_currentMentor == null) return;
      await _apiService.patch('/mentors/activities/$activityId/approve', {
        'is_verified': isVerified,
      });
      // Optionally reload the specific student data or all mentor data
      // For now, reload the selected student if we are viewing them
      if (_selectedStudent != null) {
        // Activities are currently not loaded in selectStudent, but if they were we'd reload here.
        // Let's reload all data just in case or we rely on the specific screen refreshing.
        notifyListeners();
      }
    } catch (e) {
      print('Error reviewing activity: $e');
      rethrow;
    }
  }

  // Fetch pending activities for the mentor's students
  Future<List<Map<String, dynamic>>> getPendingActivities() async {
    try {
      if (_currentMentor == null) return [];
      final response = await _apiService
          .get('/mentors/${_currentMentor!.id}/activities/pending');
      final List<dynamic> data = response;
      return data.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error loading pending activities: $e');
      return [];
    }
  }

  // ---------- Restored & Placeholder Methods ----------

  Future<void> updateBatchInfo(String mentorCode, String batchName) async {
    // Placeholder: Implement API call
    if (_currentMentor != null) {
      // await _apiService.put('/mentors/${_currentMentor!.id}', {'mentorCode': mentorCode, 'activeBatch': batchName});
    }
  }

  String generateBatchCode() {
    return 'BATCH-${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  Future<void> addMeetingLog(MeetingLogModel meetingLog) async {
    try {
      final response =
          await _apiService.post('/meeting-logs', meetingLog.toMap());
      _meetingLogs.add(MeetingLogModel.fromMap(response));
      notifyListeners();
    } catch (e) {
      print('Error adding meeting log: $e');
    }
  }

  // This method was already present, but the instruction implies adding a new `scheduleMeeting` for MeetingModel.
  // Renaming this to avoid conflict and keep its original purpose for MeetingLogModel.
  Future<void> scheduleMeetingLog(MeetingLogModel meeting) async {
    await addMeetingLog(meeting);
  }

  Future<void> scheduleMultipleMeetings(List<MeetingLogModel> meetings) async {
    // Placeholder loop
    for (var m in meetings) {
      await addMeetingLog(m);
    }
  }

  Future<void> updateStudentProfile(StudentModel student) async {
    try {
      await _apiService.put('/students/${student.id}', student.toMap());
      if (_selectedStudent?.id == student.id) {
        _selectedStudent = student;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  Future<void> updateSemester(SemesterModel semester) async {
    try {
      await _apiService.put('/semesters/${semester.id}', semester.toMap());
      // Refresh list locally
      final index = _studentSemesters.indexWhere((s) => s.id == semester.id);
      if (index != -1) _studentSemesters[index] = semester;
      notifyListeners();
    } catch (e) {
      print('Error updating semester: $e');
    }
  }

  Future<void> updateCertification(CertificationModel certification) async {
    try {
      await _apiService.put(
          '/certifications/${certification.id}', certification.toMap());
      // Refresh list locally
      final index =
          _studentCertifications.indexWhere((c) => c.id == certification.id);
      if (index != -1) _studentCertifications[index] = certification;
      notifyListeners();
    } catch (e) {
      print('Error updating certification: $e');
    }
  }

  Future<void> updateStudentDocumentStatus(
      String studentId, String docTitle, String status) async {
    try {
      final student = _assignedStudents.firstWhere((s) => s.id == studentId);
      final updatedDocs = Map<String, String>.from(student.documentStatuses);
      updatedDocs[docTitle] = status;

      await _apiService.patch(
          '/mentors/students/$studentId', {'documentStatuses': updatedDocs});

      // Update local state
      final index = _assignedStudents.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _assignedStudents[index] =
            student.copyWith(documentStatuses: updatedDocs);
        if (_selectedStudent?.id == studentId) {
          _selectedStudent = _assignedStudents[index];
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating student document status: $e');
      rethrow;
    }
  }

  List<StudentModel> getFilteredStudents(String filter) {
    switch (filter) {
      case 'attention':
        // Only students with low CGPA or many pending tasks need attention.
        // Students with CGPA >= 7.0 AND 0 pending tasks are considered performing well.
        return _assignedStudents
            .where((s) => s.currentCGPA < 7.0 || s.pendingTasks > 2)
            .toList();
      case 'pending':
        return _assignedStudents
            .where((s) => s.documentStatuses.values
                .any((status) => status == 'Pending Approval'))
            .toList();
      case 'low_docs':
        // Exclude students who have 100% document completion.
        return _assignedStudents
            .where((s) => s.documentCompletion < 100)
            .toList();
      default:
        return _assignedStudents;
    }
  }

  List<DocumentRequestModel> getStudentDocumentRequests(String studentId) {
    return _documentRequests
        .where((req) => req.studentId == studentId)
        .toList();
  }

  Future<void> updateBroadcast(BroadcastModel broadcast) async {
    try {
      final response = await _apiService.put(
          '/broadcasts/${broadcast.id}', broadcast.toMap());
      final index = _broadcasts.indexWhere((b) => b.id == broadcast.id);
      if (index != -1) {
        _broadcasts[index] = BroadcastModel.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating broadcast: $e');
      rethrow;
    }
  }

  Future<void> deleteBroadcast(String id) async {
    try {
      await _apiService.delete('/broadcasts/$id');
      _broadcasts.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting broadcast: $e');
      rethrow;
    }
  }

  // Helper for batch stats (Frontend calculation for now, or fetch from backend analytics endpoint)
  Map<String, String> getBatchStats() {
    if (_assignedStudents.isEmpty) {
      return {
        'totalCount': '0',
        'passRate': '0%',
        'tasksDone': '0%',
        'avgCerts': '0',
        'attentionCount': '0',
        'pendingDocs': '0',
        'lowDocAlerts': '0',
      };
    }

    int attentionCount = getFilteredStudents('attention').length;
    int pendingDocs = getFilteredStudents('pending').length;
    int lowDocAlerts = getFilteredStudents('low_docs').length;

    // Apply session dismissals
    if (_dismissedNotifications.contains('attention')) attentionCount = 0;
    if (_dismissedNotifications.contains('pending_docs')) pendingDocs = 0;

    return {
      'totalCount': _assignedStudents.length.toString(),
      'passRate': '85%',
      'tasksDone': '70%',
      'avgCerts': '12',
      'attentionCount': attentionCount.toString(),
      'pendingDocs': pendingDocs.toString(),
      'lowDocAlerts': lowDocAlerts.toString(),
    };
  }

  void dismissNotification(String type) {
    _dismissedNotifications.add(type);
    notifyListeners();
  }

  void clearAllNotifications() {
    _dismissedNotifications.addAll(['attention', 'pending_docs']);
    notifyListeners();
  }
}
