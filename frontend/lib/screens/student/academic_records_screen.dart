import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/semester_model.dart';

class AcademicRecordsScreen extends StatefulWidget {
  const AcademicRecordsScreen({super.key});

  @override
  State<AcademicRecordsScreen> createState() => _AcademicRecordsScreenState();
}

class _AcademicRecordsScreenState extends State<AcademicRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentId = authProvider.userId ?? '';
    final student = authProvider.student;

    return Scaffold(
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, child) {
          if (studentProvider.isLoading && studentProvider.semesters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final semesters = studentProvider.semesters;

          // Determine which semesters to show
          int startSemester = student?.admissionType == 'DSE' ? 3 : 1;
          int endSemester = 8;

          // Generate semester list
          List<int> semesterNumbers = List.generate(
            endSemester - startSemester + 1,
            (index) => startSemester + index,
          );

          return RefreshIndicator(
            onRefresh: () async {
              if (studentId.isNotEmpty) {
                await studentProvider.loadStudentData(studentId);
              }
            },
            child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          itemCount: semesterNumbers.length,
          itemBuilder: (context, index) {
            final semNum = semesterNumbers[index];
            final semester = semesters.firstWhere(
              (s) => s.semesterNumber == semNum,
              orElse: () => SemesterModel(
                id: '',
                studentId: studentId,
                semesterNumber: semNum,
                sgpa: 0.0,
                cgpa: 0.0,
                resultStatus: 'Pending',
                subjects: [],
              ),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors
                      .transparent, // removes the border when expansion tile expands
                ),
                child: ExpansionTile(
                  iconColor: Colors.black,
                  collapsedIconColor: Colors.black,
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'S$semNum',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    'SEMESTER $semNum',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: semester.resultStatus == 'Pass'
                              ? Colors.green.withOpacity(0.1)
                              : semester.resultStatus == 'Fail'
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          semester.resultStatus.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1,
                            color: semester.resultStatus == 'Pass'
                                ? Colors.green[800]
                                : semester.resultStatus == 'Fail'
                                    ? Colors.red[800]
                                    : Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 24, color: Colors.black),
                    onPressed: () => _editSemesterDetails(context, semester),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                context,
                                'SGPA',
                                semester.sgpa.toStringAsFixed(2),
                                Icons.grade_outlined,
                              ),
                              _buildStatCard(
                                context,
                                'CGPA',
                                semester.cgpa.toStringAsFixed(2),
                                Icons.trending_up,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'SUBJECTS & MARKS',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black45,
                                  letterSpacing: 1.5,
                                  fontSize: 12,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddSubjectDialog(
                                      context, studentId, semester);
                                },
                                icon: const Icon(Icons.add,
                                    size: 16, color: Colors.black),
                                label: const Text(
                                  'ADD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: 1.0,
                                    fontSize: 12,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                        color: Colors.black.withOpacity(0.1)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (semester.subjects.isEmpty)
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.05)),
                              ),
                              child: const Center(
                                child: Text(
                                  'No subjects added yet.',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.05)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2.5),
                                  1: FlexColumnWidth(1.2),
                                  2: FlexColumnWidth(1.2),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9FB),
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(12)),
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black
                                                  .withOpacity(0.05))),
                                    ),
                                    children: [
                                      _buildTableCell('SUBJECT',
                                          isHeader: true),
                                      _buildTableCell('INT', isHeader: true),
                                      _buildTableCell('EXT', isHeader: true),
                                    ],
                                  ),
                                  ...semester.subjects.map((mark) => TableRow(
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.02))),
                                        ),
                                        children: [
                                          _buildTableCell(mark.subjectName),
                                          _buildTableCell(mark.internal
                                              .toStringAsFixed(0)),
                                          _buildTableCell(mark.external
                                              .toStringAsFixed(0)),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  ),
);
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.w900 : FontWeight.w600,
          fontSize: isHeader ? 10 : 13,
          letterSpacing: isHeader ? 1.0 : 0.0,
          color: isHeader ? Colors.black45 : Colors.black87,
        ),
        textAlign:
            isHeader && text != 'SUBJECT' ? TextAlign.center : TextAlign.start,
      ),
    );
  }

  void _editSemesterDetails(BuildContext context, SemesterModel semester) {
    final sgpaController =
        TextEditingController(text: semester.sgpa.toString());
    final cgpaController =
        TextEditingController(text: semester.cgpa.toString());

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Edit Semester ${semester.semesterNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sgpaController,
                decoration: const InputDecoration(labelText: 'SGPA', hintText: 'e.g. 8.5'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isSaving,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cgpaController,
                decoration:
                    const InputDecoration(labelText: 'CGPA (till this sem)', hintText: 'e.g. 8.8'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isSaving,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel')
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setStateDialog(() => isSaving = true);
                try {
                  final String rawSgpa = sgpaController.text.replaceAll(',', '.');
                  final String rawCgpa = cgpaController.text.replaceAll(',', '.');
                  final double parsedSgpa = double.tryParse(rawSgpa) ?? semester.sgpa;
                  final double parsedCgpa = double.tryParse(rawCgpa) ?? semester.cgpa;

                  final newSemester = semester.copyWith(
                    sgpa: parsedSgpa,
                    cgpa: parsedCgpa,
                    resultStatus: parsedSgpa >= 4.0 ? 'Pass' : 'Fail',
                  );
                  
                  await Provider.of<StudentProvider>(context, listen: false)
                      .updateSemester(newSemester);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semester updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  setStateDialog(() => isSaving = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red.shade800,
                      ),
                    );
                  }
                }
              },
              child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectDialog(
      BuildContext context, String studentId, SemesterModel semester) {
    final nameController = TextEditingController();
    final internalController = TextEditingController();
    final externalController = TextEditingController();

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Subject Marks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g. Mathematics-III',
                ),
                enabled: !isSaving,
              ),
              const SizedBox(
                  height: 24), // Vertical spacing between Name and Marks
              const Text(
                'Marks',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: internalController,
                      decoration: const InputDecoration(
                        labelText: 'Internal',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !isSaving,
                    ),
                  ),
                  const SizedBox(width: 24), // Increased horizontal spacing
                  Expanded(
                    child: TextField(
                      controller: externalController,
                      decoration: const InputDecoration(
                        labelText: 'External',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !isSaving,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameController.text.isNotEmpty) {
                  setStateDialog(() => isSaving = true);
                  try {
                    final studentProvider =
                        Provider.of<StudentProvider>(context, listen: false);

                    final mark = SubjectMark(
                      subjectName: nameController.text.trim(),
                      internal: double.tryParse(internalController.text.replaceAll(',', '.')) ?? 0.0,
                      external: double.tryParse(externalController.text.replaceAll(',', '.')) ?? 0.0,
                    );

                    dynamic semId = semester.id;

                    // 1. If semester doesn't exist, create it first
                    if (semId == null || semId == '' || semId == '0') {
                      final initialSem = SemesterModel(
                        id: '',
                        studentId: studentId.toString(),
                        semesterNumber: semester.semesterNumber,
                        sgpa: 0.0,
                        cgpa: 0.0,
                        resultStatus: 'Pending',
                        subjects: [],
                      );
                      semId = await studentProvider.updateSemester(initialSem);
                    }

                    // 2. Add subject mark
                    if (semId != null && semId.toString().isNotEmpty) {
                      await studentProvider.addSubjectMark(
                          semId.toString(), mark);
                    } else {
                        throw Exception("Failed to retrieve semester ID after creating.");
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marks added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    setStateDialog(() => isSaving = false);
                    print("Error adding marks: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to add marks: ${e.toString().replaceAll('Exception: ', '')}'),
                          backgroundColor: Colors.red.shade800,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject name cannot be empty')),
                  );
                }
              },
              child: isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Marks'),
            ),
          ],
        ),
      ),
    );
  }
}
