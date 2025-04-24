import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nsync_admin/components/form_validation.dart';
import 'package:nsync_admin/main.dart';

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  String? selectedDept;

  // Controllers
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _stEmailController = TextEditingController();
  final TextEditingController _stPasswordController = TextEditingController();
  final TextEditingController _stAdmnoController = TextEditingController();
  final TextEditingController _stContactController = TextEditingController();
  final TextEditingController _stAcdYearController = TextEditingController();

  List<Map<String, dynamic>> StudList = [];
  List<Map<String, dynamic>> DeptList = [];
  PlatformFile? pickedImage;

  @override
  void initState() {
    super.initState();
    fetchDept();
    fetchStudent();
  }

  @override
  void dispose() {
    _studentController.dispose();
    _stEmailController.dispose();
    _stPasswordController.dispose();
    _stAdmnoController.dispose();
    _stContactController.dispose();
    _stAcdYearController.dispose();
    super.dispose();
  }

  // Register
  Future<void> Register() async {
    try {
      final auth = await supabase.auth.signUp(
        password: _stPasswordController.text,
        email: _stEmailController.text,
      );
      final uid = auth.user!.id;
      if (uid.isNotEmpty) {
        await studentInsert(uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Insert
  Future<void> studentInsert(final id) async {
    try {
      String name = _studentController.text;
      String admissionNo = _stAdmnoController.text;
      String email = _stEmailController.text;
      String password = _stPasswordController.text;
      String phone = _stContactController.text;
      String academicYear = _stAcdYearController.text;
      String? url = await photoUpload(id);

      if (selectedDept == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a department"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await supabase.from('tbl_student').insert({
        'student_id': id,
        'student_name': name,
        'student_admno': admissionNo,
        'student_email': email,
        'student_password': password,
        'student_contact': phone,
        'department_id': selectedDept,
        'academic_year': academicYear,
        'student_photo': url,
        'student_status': 1, // Default status for new students
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student data inserted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      await fetchStudent();

      _studentController.clear();
      _stAdmnoController.clear();
      _stEmailController.clear();
      _stPasswordController.clear();
      _stContactController.clear();
      _stAcdYearController.clear();
      setState(() {
        selectedDept = null;
        pickedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inserting student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Select
  Future<void> fetchDept() async {
    try {
      final response = await supabase.from('tbl_department').select();
      setState(() {
        DeptList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching departments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchStudent() async {
    try {
      final response = await supabase
          .from('tbl_student')
          .select('*, tbl_department(department_name)');
      setState(() {
        StudList = List<Map<String, dynamic>>.from(response);
        print("Fetched ${StudList.length} students"); // Debug
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching students: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        StudList = [];
      });
    }
  }

  // Delete
  Future<void> deltStudent(String did) async {
    try {
      await supabase.from('tbl_student').delete().eq('student_id', did);
      await fetchStudent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Block
  Future<void> blockStudent(String did, String name) async {
    try {
      await supabase
          .from('tbl_student')
          .update({'student_status': 0})
          .eq('student_id', did);
      await fetchStudent();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name blocked successfully"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error blocking student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Unblock
  Future<void> unblockStudent(String did, String name) async {
    try {
      await supabase
          .from('tbl_student')
          .update({'student_status': 1})
          .eq('student_id', did);
      await fetchStudent();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name unblocked successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unblocking student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // File upload
  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    try {
      if (pickedImage == null) return null;

      final bucketName = 'Student';
      final filePath = "$uid-${pickedImage!.name}";
      await supabase.storage
          .from(bucketName)
          .uploadBinary(filePath, pickedImage!.bytes!);
      final publicUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height: 2000,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF161616),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 18,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isFormVisible = !_isFormVisible;
                        });
                      },
                      label: Text(
                        _isFormVisible ? "Cancel" : "Add Student",
                        style: const TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        _isFormVisible ? Icons.cancel : Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: _animationDuration,
                curve: Curves.easeInOut,
                child:
                    _isFormVisible
                        ? Form(
                          child: SizedBox(
                            width: 700,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: 120,
                                      child:
                                          pickedImage == null
                                              ? GestureDetector(
                                                onTap: handleImagePick,
                                                child: const Icon(
                                                  Icons.add_a_photo,
                                                  color: Colors.blue,
                                                  size: 50,
                                                ),
                                              )
                                              : GestureDetector(
                                                onTap: handleImagePick,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                  child:
                                                      pickedImage!.bytes != null
                                                          ? Image.memory(
                                                            Uint8List.fromList(
                                                              pickedImage!
                                                                  .bytes!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                          : Image.file(
                                                            File(
                                                              pickedImage!
                                                                  .path!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          controller: _studentController,
                                          validator:
                                              (value) =>
                                                  FormValidation.validateName(
                                                    value,
                                                  ),
                                          decoration: const InputDecoration(
                                            hintText: "Name",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          controller: _stAdmnoController,
                                          decoration: const InputDecoration(
                                            hintText: "Admission No",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          controller: _stEmailController,
                                          validator:
                                              (value) =>
                                                  FormValidation.validateEmail(
                                                    value,
                                                  ),
                                          decoration: const InputDecoration(
                                            hintText: "Email",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          controller: _stPasswordController,
                                          validator:
                                              (value) =>
                                                  FormValidation.validatePassword(
                                                    value,
                                                  ),
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            hintText: "Password",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          validator:
                                              (value) =>
                                                  FormValidation.validateContact(
                                                    value,
                                                  ),
                                          controller: _stContactController,
                                          decoration: const InputDecoration(
                                            hintText: "Phone",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          controller: _stAcdYearController,
                                          decoration: const InputDecoration(
                                            hintText: "Academic Year",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: DropdownButtonFormField<String>(
                                          validator:
                                              (value) =>
                                                  FormValidation.validateDropdown(
                                                    value,
                                                  ),
                                          value: selectedDept,
                                          hint: const Text("Select Department"),
                                          items:
                                              DeptList.map((department) {
                                                return DropdownMenuItem(
                                                  value:
                                                      department['department_id']
                                                          .toString(),
                                                  child: Text(
                                                    department['department_name'],
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedDept = newValue;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
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
                                  onPressed: Register,
                                  child: const Text(
                                    "Insert",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        )
                        : Container(),
              ),
              const Center(
                child: Text(
                  "Students Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              StudList.isEmpty
                  ? const Center(child: Text("No students found"))
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text("SL.No")),
                        DataColumn(label: Text("Photo")),
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Adm No.")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Contact No.")),
                        DataColumn(label: Text("Department")),
                        DataColumn(label: Text("Academic Year")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows:
                          StudList.asMap().entries.map((entry) {
                            final student = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text((entry.key + 1000).toString())),
                                DataCell(
                                  Container(
                                    width: 40,
                                    height: 40,
                                    child:
                                        student['student_photo'] != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                student['student_photo'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  print("Image Error: $error");
                                                  return CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.grey[600],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                            : CircleAvatar(
                                              backgroundColor: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 150,
                                    ),
                                    child: Text(
                                      student['student_name'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 100,
                                    ),
                                    child: Text(
                                      student['student_admno']?.toString() ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      student['student_email'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 120,
                                    ),
                                    child: Text(
                                      student['student_contact']?.toString() ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 150,
                                    ),
                                    child: Text(
                                      student['tbl_department']?['department_name'] ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 100,
                                    ),
                                    child: Text(
                                      student['academic_year'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student['student_status'] == 0
                                        ? 'Blocked'
                                        : 'Active',
                                    style: TextStyle(
                                      color:
                                          student['student_status'] == 0
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          student['student_status'] == -1
                                              ? Icons.lock_open
                                              : Icons.block,
                                          color:
                                              student['student_status'] == -1
                                                  ? Colors.green
                                                  : Colors.orange,
                                        ),
                                        tooltip:
                                            student['student_status'] == -1
                                                ? 'Unblock'
                                                : 'Block',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: Text(
                                                    student['student_status'] ==
                                                            -1
                                                        ? "Unblock Student"
                                                        : "Block Student",
                                                  ),
                                                  content: Text(
                                                    "Are you sure you want to ${student['student_status'] == -1 ? 'unblock' : 'block'} ${student['student_name']}?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        if (student['student_status'] ==
                                                            0) {
                                                          unblockStudent(
                                                            student['student_id']
                                                                .toString(),
                                                            student['student_name'],
                                                          );
                                                        } else {
                                                          blockStudent(
                                                            student['student_id']
                                                                .toString(),
                                                            student['student_name'],
                                                          );
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        student['student_status'] ==
                                                                0
                                                            ? "Unblock"
                                                            : "Block",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Delete',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    "Delete Student",
                                                  ),
                                                  content: Text(
                                                    "Are you sure you want to delete ${student['student_name']}?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deltStudent(
                                                          student['student_id']
                                                              .toString(),
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Delete",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
