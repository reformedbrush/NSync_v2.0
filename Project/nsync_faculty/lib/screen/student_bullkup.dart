import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:nsync_faculty/main.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
          content: Text(
            'Error fetching department: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        SnackBar(
          content: Text(
            "Failed to load department. Please try again.",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select an Excel file",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: errors.isEmpty ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (successCount > 0) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error processing Excel file: $e",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Upload Student Data',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Department',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          departmentName ?? 'Loading department...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color:
                                departmentName != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excel File Upload',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: handleFilePick,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 0, 0, 0),
                                  Color.fromARGB(255, 34, 34, 34),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    44,
                                    44,
                                    44,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pickedFile == null
                                      ? 'Choose Excel File'
                                      : 'Change File',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (pickedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pickedFile!.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    const templateUrl =
                        'https://gxomwkpwoxmhdtdsxjph.supabase.co/storage/v1/object/public/template//template.xlsx';
                    if (await canLaunchUrl(Uri.parse(templateUrl))) {
                      await launchUrl(Uri.parse(templateUrl));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Failed to open template URL",
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          'Download Template',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 61, 61, 61),
                        ),
                      ),
                    )
                    : GestureDetector(
                      onTap: uploadAndProcessExcel,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 0, 0, 0),
                              Color.fromARGB(255, 36, 36, 36),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                49,
                                49,
                                49,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Upload and Insert',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
