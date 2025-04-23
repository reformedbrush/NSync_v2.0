import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:nsync_faculty/main.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class ExcelUploadPage extends StatefulWidget {
  const ExcelUploadPage({super.key});

  @override
  State<ExcelUploadPage> createState() => _ExcelUploadPageState();
}

class _ExcelUploadPageState extends State<ExcelUploadPage> {
  String? departmentId;
  String? departmentName;
  PlatformFile? pickedFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFacultyDepartment();
  }

  Future<void> fetchFacultyDepartment() async {
    try {
      final faculty =
          await supabase
              .from('tbl_faculty')
              .select('*, tbl_department(department_name)')
              .eq('faculty_id', supabase.auth.currentUser!.id)
              .single();

      setState(() {
        departmentId = faculty['department_id'].toString();
        departmentName = faculty['tbl_department']['department_name'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching faculty department: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> handleFilePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> uploadAndProcessExcel() async {
    if (departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load department. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an Excel file"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final bytes = pickedFile!.bytes;
      if (bytes == null) throw Exception("Failed to read file bytes");
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) throw Exception("No valid sheet found in Excel file");

      const expectedHeaders = [
        'student_name',
        'student_email',
        'student_password',
        'student_admno',
        'student_contact',
        'academic_year',
      ];

      final headers =
          sheet.rows.first
              .map((cell) => cell?.value?.toString().toLowerCase().trim())
              .toList();
      for (var header in expectedHeaders) {
        if (!headers.contains(header)) {
          throw Exception("Missing required column: $header");
        }
      }

      int successCount = 0;
      final errors = <String>[];
      const uuid = Uuid();

      for (var row in sheet.rows.skip(1)) {
        try {
          final rowData = Map.fromIterables(
            headers,
            row.map((cell) => cell?.value?.toString() ?? ''),
          );
          final email = rowData['student_email'];
          final password = rowData['student_password'];

          if (email == null ||
              email.isEmpty ||
              password == null ||
              password.isEmpty) {
            errors.add(
              "Row ${sheet.rows.indexOf(row) + 1}: Missing email or password",
            );
            continue;
          }

          final auth = await supabase.auth.signUp(
            email: email,
            password: password,
          );
          final studentId = auth.user?.id;
          if (studentId == null || studentId.isEmpty) {
            errors.add(
              "Row ${sheet.rows.indexOf(row) + 1}: Failed to register user for $email",
            );
            continue;
          }

          await supabase.from('tbl_student').insert({
            'student_id': studentId,
            'student_name': rowData['student_name'] ?? '',
            'student_email': email,
            'student_password': password,
            'student_admno': rowData['student_admno'] ?? '',
            'student_contact': rowData['student_contact'] ?? '',
            'department_id': departmentId,
            'academic_year': rowData['academic_year'] ?? '',
          });

          successCount++;
        } catch (e) {
          errors.add("Row ${sheet.rows.indexOf(row) + 1}: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Uploaded $successCount students successfully${errors.isNotEmpty ? '. Errors: ${errors.join('; ')}' : ''}",
          ),
          backgroundColor: errors.isEmpty ? Colors.green : Colors.orange,
        ),
      );

      if (successCount > 0) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing Excel file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
        pickedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Student Data'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Department',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              departmentName ?? 'Loading department...',
              style: TextStyle(
                fontSize: 16,
                color: departmentName != null ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                const templateUrl =
                    'https://your-supabase-url/storage/v1/object/public/templates/students_template.xlsx';
                if (await canLaunchUrl(Uri.parse(templateUrl))) {
                  await launchUrl(Uri.parse(templateUrl));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to open template URL"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text("Download Template"),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Excel File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: handleFilePick,
              icon: const Icon(Icons.upload_file),
              label: const Text("Choose Excel File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            if (pickedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Selected: ${pickedFile!.name}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: uploadAndProcessExcel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF017AFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "Upload and Insert",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
