import '../models/activity_model.dart';
import '../models/certification_model.dart';
import '../models/internship_model.dart';
import '../models/meeting_log_model.dart';
import '../models/mentor_model.dart';
import '../models/semester_model.dart';
import '../models/student_model.dart';
import '../models/task_model.dart';
import '../models/meeting_model.dart';
import '../models/broadcast_model.dart';
import '../models/document_request_model.dart';

/// In-memory "database" for demo/offline mode.
///
/// Simple words: app band karoge toh data reset ho jayega.
class InMemoryDb {
  InMemoryDb._();

  static final InMemoryDb instance = InMemoryDb._();

  final List<StudentModel> _students = [];
  final List<MentorModel> _mentors = [];
  final List<SemesterModel> _semesters = [];
  final List<InternshipModel> _internships = [];
  final List<CertificationModel> _certifications = [];
  final List<ActivityModel> _activities = [];
  final List<TaskModel> _tasks = [];
  final List<MeetingLogModel> _meetingLogs = [];
  final List<MeetingModel> _meetings = [];
  final List<BroadcastModel> _broadcasts = [];
  final List<DocumentRequestModel> _documentRequests = [];

  bool _initialized = false;

  void ensureMockData() {
    if (_initialized) return;
    _initialized = true;

    // 2 mentors
    final mentor1 = MentorModel(
      id: 'm1',
      email: 'mentor@pvppcoe.ac.in',
      password: '1234', // 👈 ADD THIS
      fullName: 'Prof. Priya Sharma',
      department: 'CSE',
      mentorCode: 'MTR-CSE-101',
      activeBatch: '2021-2025',
      assignedStudentIds: const ['s1', 's2'],
      totalStudentsAssigned: 2,
      studentsWithPendingTasks: 1,
      studentsWithLowCGPA: 1,
      totalDocumentApprovals: 15,
    );

    // ... (rest of mentors) ...
    // Note: I will use a separate replacement for the large ensureMockData body to avoid context errors if I can't match it perfectly.
    // actually, let's just add the field here and methods later.
    final mentor2 = MentorModel(
      id: 'm2',
      email: 'khanna@pvppcoe.ac.in',
      password: '1234', // 👈 ADD THIS LINE
      fullName: 'Dr. Rajesh Khanna',
      department: 'CSE',
      mentorCode: 'MTR-CSE-102',
      activeBatch: '2022-2026',
      assignedStudentIds: const [],
      totalStudentsAssigned: 0,
      studentsWithPendingTasks: 0,
      studentsWithLowCGPA: 0,
      totalDocumentApprovals: 0,
    );

    _mentors.addAll([mentor1, mentor2]);

    // 2 students
    final s1 = StudentModel(
      id: 's1',
      email: 'student1@pvppcoe.ac.in',
      fullName: 'Amit Patel',
      studentId: 'CSE21-101',
      department: 'CSE',
      admissionType: 'Regular',
      dateOfBirth: DateTime(2004, 5, 12),
      dateOfJoining: DateTime(2021, 8, 1),
      mentorId: mentor1.id,
      mentorName: mentor1.fullName,
      mentorCode: mentor1.mentorCode,
      groupLeaderName: 'Rohit Verma',
      currentCGPA: 7.25,
      totalInternships: 1,
      certificationPoints: 6, // 6/10
      pendingTasks: 1,
      upcomingMeetings: 1,
      unreadBroadcasts: 1,
      documentCompletion: 45.0, // Should trigger alert (<50)
      documentStatuses: const {
        '10th Marksheet': 'Approved',
        '12th Marksheet / Diploma': 'Pending Approval',
        'ID Proof': 'Missing',
      },
    );
    final s2 = StudentModel(
      id: 's2',
      email: 'student2@pvppcoe.ac.in',
      fullName: 'Sneha Reddy',
      studentId: 'CSE21-118',
      department: 'CSE',
      admissionType: 'DSE',
      dateOfBirth: DateTime(2003, 11, 2),
      dateOfJoining: DateTime(2022, 8, 1),
      mentorId: mentor1.id,
      mentorName: mentor1.fullName,
      mentorCode: mentor1.mentorCode,
      groupLeaderName: 'Ananya Singh',
      currentCGPA: 6.40, // low CGPA
      totalInternships: 0,
      certificationPoints: 2,
      pendingTasks: 0,
      upcomingMeetings: 0,
      unreadBroadcasts: 0,
      documentCompletion: 80.0,
      documentStatuses: const {
        '10th Marksheet': 'Approved',
        'ID Proof': 'Approved',
        'Resume': 'Pending Approval',
      },
    );
    _students.addAll([s1, s2]);

    // Semesters (sample)
    _semesters.addAll([
      SemesterModel(
        id: 'sem_s1_1',
        studentId: 's1',
        semesterNumber: 1,
        sgpa: 7.2,
        cgpa: 7.2,
        resultStatus: 'Pass',
        subjects: [
          SubjectMark(
              subjectName: 'Programming in C', internal: 25, external: 60),
          SubjectMark(
              subjectName: 'Discrete Mathematics', internal: 22, external: 58),
        ],
      ),
      SemesterModel(
        id: 'sem_s1_2',
        studentId: 's1',
        semesterNumber: 2,
        sgpa: 7.3,
        cgpa: 7.25,
        resultStatus: 'Pass',
        subjects: [
          SubjectMark(
              subjectName: 'Data Structures', internal: 28, external: 62),
          SubjectMark(subjectName: 'Logic Design', internal: 24, external: 55),
        ],
      ),
      SemesterModel(
        id: 'sem_s2_3',
        studentId: 's2',
        semesterNumber: 3,
        sgpa: 6.2,
        cgpa: 6.2,
        resultStatus: 'Pass',
        subjects: [
          SubjectMark(subjectName: 'OS', internal: 20, external: 50),
          SubjectMark(subjectName: 'DBMS', internal: 18, external: 48),
        ],
      ),
    ]);

    // Internships (sample)
    _internships.add(
      InternshipModel(
        id: 'int1',
        studentId: 's1',
        companyName: 'Acme Tech',
        role: 'Flutter Intern',
        duration: '2 months',
        mode: 'Vacation',
        description: 'Worked on UI screens and state management.',
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 7, 31),
        isVerified: true,
      ),
    );

    // Certifications (sample)
    _certifications.addAll([
      CertificationModel(
        id: 'cert1',
        studentId: 's1',
        title: 'Flutter Basics',
        issuer: 'Google',
        date: DateTime(2025, 4, 15),
        points: 4,
        category: 'External',
        type: 'Technical',
        level: 'National',
      ),
      CertificationModel(
        id: 'cert2',
        studentId: 's2',
        title: 'Communication Skills',
        issuer: 'Coursera',
        date: DateTime(2025, 3, 20),
        points: 2,
        category: 'External',
        type: 'Social',
        level: 'International',
      ),
    ]);

    // Activities (sample)
    _activities.add(
      ActivityModel(
        id: 'act1',
        studentId: 's1',
        eventName: 'Hackathon 2025',
        level: 'College',
        role: 'Participant',
        date: DateTime(2025, 9, 12),
      ),
    );

    // Tasks (sample)
    _tasks.add(
      TaskModel(
        id: 't1',
        studentId: 's1',
        mentorId: 'm1',
        title: 'Resume Update',
        description: 'Update resume with latest internship and projects.',
        deadline: DateTime.now().add(const Duration(days: 7)),
        status: 'Pending',
      ),
    );

    // Initial Broadcasts
    _broadcasts.addAll([
      BroadcastModel(
        id: 'b1',
        mentorId: 'm1',
        title: 'Welcome Batch 2021',
        message:
            'Welcome to the mentor-mentee program! Please schedule your first meeting soon.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        isUrgent: false,
      ),
      BroadcastModel(
        id: 'b2',
        mentorId: 'm1',
        title: 'Internal Assessment Reminder',
        message: 'Ensure all your internal marks are verified by this week.',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        isUrgent: true,
      ),
    ]);
  }

  // ---------- Auth helpers ----------
  StudentModel? findStudentByEmail(String email) {
    return _students
        .where((s) => s.email.toLowerCase() == email.toLowerCase())
        .firstOrNull;
  }

  MentorModel? findMentorByEmail(String email) {
    return _mentors
        .where((m) => m.email.toLowerCase() == email.toLowerCase())
        .firstOrNull;
  }

  MentorModel? findMentorByCode(String code) {
    return _mentors
        .where((m) => m.mentorCode.toUpperCase() == code.toUpperCase())
        .firstOrNull;
  }

  // ---------- Student ----------
  StudentModel? getStudent(String id) {
    return _students.where((s) => s.id == id).firstOrNull;
  }

  void upsertStudent(StudentModel student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index == -1) {
      _students.add(student);
    } else {
      _students[index] = student;
    }
  }

  // ---------- Mentor ----------
  MentorModel? getMentor(String id) {
    return _mentors.where((m) => m.id == id).firstOrNull;
  }

  void upsertMentor(MentorModel mentor) {
    final index = _mentors.indexWhere((m) => m.id == mentor.id);
    if (index == -1) {
      _mentors.add(mentor);
    } else {
      _mentors[index] = mentor;
    }
  }

  List<StudentModel> getStudentsByMentor(String mentorId) {
    return _students.where((s) => s.mentorId == mentorId).toList();
  }

  // ---------- Semesters ----------
  List<SemesterModel> getSemestersByStudent(String studentId) {
    final list = _semesters.where((s) => s.studentId == studentId).toList();
    list.sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));
    return list;
  }

  void upsertSemester(SemesterModel semester) {
    final index = _semesters.indexWhere((s) => s.id == semester.id);
    if (index == -1) {
      _semesters.add(semester);
    } else {
      _semesters[index] = semester;
    }
  }

  // ---------- Internships ----------
  List<InternshipModel> getInternshipsByStudent(String studentId) {
    return _internships.where((i) => i.studentId == studentId).toList();
  }

  void addInternship(InternshipModel internship) {
    _internships.add(internship);
  }

  void upsertInternship(InternshipModel internship) {
    final index = _internships.indexWhere((i) => i.id == internship.id);
    if (index == -1) {
      _internships.add(internship);
    } else {
      _internships[index] = internship;
    }
  }

  // ---------- Certifications ----------
  List<CertificationModel> getCertificationsByStudent(String studentId) {
    return _certifications.where((c) => c.studentId == studentId).toList();
  }

  void addCertification(CertificationModel certification) {
    _certifications.add(certification);
  }

  void upsertCertification(CertificationModel certification) {
    final index = _certifications.indexWhere((c) => c.id == certification.id);
    if (index == -1) {
      _certifications.add(certification);
    } else {
      _certifications[index] = certification;
    }
  }

  // ---------- Activities ----------
  List<ActivityModel> getActivitiesByStudent(String studentId) {
    return _activities.where((a) => a.studentId == studentId).toList();
  }

  void addActivity(ActivityModel activity) {
    _activities.add(activity);
  }

  // ---------- Tasks ----------
  List<TaskModel> getTasksByStudent(String studentId) {
    final list = _tasks.where((t) => t.studentId == studentId).toList();
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list;
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
  }

  void upsertTask(TaskModel task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      _tasks.add(task);
    } else {
      _tasks[index] = task;
    }
  }

  // ---------- Meeting Logs ----------
  List<MeetingLogModel> getMeetingLogsByStudent(String studentId) {
    final list = _meetingLogs.where((m) => m.studentId == studentId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<MeetingLogModel> getMeetingLogsByMentor(String mentorId) {
    final list = _meetingLogs.where((m) => m.mentorId == mentorId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addMeetingLog(MeetingLogModel log) {
    _meetingLogs.add(log);
  }

  // ---------- Meetings ----------
  List<MeetingModel> getMeetingsByMentor(String mentorId) {
    final list = _meetings.where((m) => m.mentorId == mentorId).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<MeetingModel> getMeetingsByStudent(String studentId, {String? batchId}) {
    return _meetings.where((m) {
      if (m.studentId == studentId) return true; // 1-on-1
      if (batchId != null && m.batchId == batchId) return true; // Batch meeting
      return false;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void addMeeting(MeetingModel meeting) {
    _meetings.add(meeting);
  }

  void upsertMeeting(MeetingModel meeting) {
    final index = _meetings.indexWhere((m) => m.id == meeting.id);
    if (index == -1) {
      _meetings.add(meeting);
    } else {
      _meetings[index] = meeting;
    }
  }

  // ---------- Broadcasts ----------
  List<BroadcastModel> getBroadcastsByMentor(String mentorId) {
    final list = _broadcasts.where((b) => b.mentorId == mentorId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addBroadcast(BroadcastModel broadcast) {
    _broadcasts.add(broadcast);
  }

  void upsertBroadcast(BroadcastModel broadcast) {
    final index = _broadcasts.indexWhere((b) => b.id == broadcast.id);
    if (index == -1) {
      _broadcasts.add(broadcast);
    } else {
      _broadcasts[index] = broadcast;
    }
  }

  void deleteBroadcast(String id) {
    _broadcasts.removeWhere((b) => b.id == id);
  }

  // ---------- Document Requests ----------
  List<DocumentRequestModel> getDocumentRequestsByMentor(String mentorId) {
    final list =
        _documentRequests.where((r) => r.mentorId == mentorId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<DocumentRequestModel> getDocumentRequestsByStudent(String studentId) {
    final list =
        _documentRequests.where((r) => r.studentId == studentId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<DocumentRequestModel> getPendingRequestsByStudent(String studentId) {
    return _documentRequests
        .where((r) => r.studentId == studentId && r.status == 'Pending')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addDocumentRequest(DocumentRequestModel request) {
    _documentRequests.add(request);
  }

  void updateDocumentRequest(DocumentRequestModel request) {
    final index = _documentRequests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      _documentRequests[index] = request;
    }
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
