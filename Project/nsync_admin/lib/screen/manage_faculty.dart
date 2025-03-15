import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nsync_admin/components/form_validation.dart';
import 'package:nsync_admin/components/insert_form.dart';
import 'package:nsync_admin/main.dart';

class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false; // To manage form visibility
  String? selectedDept;

  List<Map<String, dynamic>> facultyList = [];
  List<Map<String, dynamic>> DeptList = [];

  final Duration _animationDuration = const Duration(milliseconds: 300);

  //Controllers
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _facContactController = TextEditingController();
  final TextEditingController _facEmailController = TextEditingController();
  final TextEditingController _facPasswordController = TextEditingController();
  final TextEditingController _facDesignationController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();
  // insert

  Future<void> register() async {
    try {
      final auth = await supabase.auth.signUp(
          password: _facPasswordController.text,
          email: _facEmailController.text);
      final uid = auth.user!.id;
      if (uid.isNotEmpty || uid != "") {
        insFaculty(uid);
      }
    } catch (e) {
      print("AUTH ERROR: $e");
    }
  }

  Future<void> insFaculty(final id) async {
    try {
      String Name = _facultyController.text;
      String Email = _facEmailController.text;
      String Password = _facPasswordController.text;
      String Contact = _facContactController.text;
      String Designation = _facDesignationController.text;
      String? url = await photoUpload(id);
      if (selectedDept == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a Department"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await supabase.from('tbl_faculty').insert({
        'faculty_id': id,
        'faculty_name': Name,
        'faculty_email': Email,
        'faculty_password': Password,
        'faculty_contact': Contact,
        'faculty_designation': Designation,
        'department_id': selectedDept,
        'faculty_photo': url
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Faculty Data Inserted Sucessfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _facultyController.clear();
      _facDesignationController.clear();
      _facEmailController.clear();
      _facPasswordController.clear();
      _facContactController.clear(); // reset inserted value after insertion
      setState(() {
        selectedDept = null; //reset selection
      });
      fetchFaculty();
    } catch (e) {
      print("ERROR INSERTING DATA: $e");
    }
  }

  void reset() {
    setState(() {
      eid = 0;
      selectedDept = null;
      _facultyController.clear();
      _facDesignationController.clear();
      _facEmailController.clear();
      _facPasswordController.clear();
      _facContactController.clear();
      _isFormVisible = false;
    });
  }

  //select

  Future<void> fetchDept() async {
    try {
      final response = await supabase.from('tbl_department').select();
      if (response.isNotEmpty) {
        setState(() {
          DeptList = response;
        });
      }
    } catch (e) {
      print("ERROR FETCHING DEPARTMENT: $e");
    }
  }

  Future<void> fetchFaculty() async {
    try {
      final response =
          await supabase.from('tbl_faculty').select('*,tbl_department(*)');
      setState(() {
        facultyList = response;
      });
    } catch (e) {
      print("ERROR FETCHING FACULTY DATA: $e");
    }
  }

  //edit

  int eid = 0;

  Future<void> editFaculty() async {
    try {
      await supabase.from('tbl_faculty').update({
        'faculty_name': _facultyController.text,
        'faculty_designation': _facDesignationController.text,
        'faculty_email': _facEmailController.text,
        'faculty_password': _facPasswordController.text,
        'faculty_contact': _facContactController.text
      }).eq('faculty_id', eid);
      fetchFaculty();
      _facContactController.clear();
      _facDesignationController.clear();
      _facEmailController.clear();
      _facPasswordController.clear();
      _facContactController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Data Edited Sucessfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("ERROR EDITING DATA: $e");
    }
  }

  // delete

  Future<void> delFaculty(String did) async {
    try {
      await supabase.from('tbl_faculty').delete().eq('faculty_id', did);
      fetchFaculty();
    } catch (e) {
      print("ERROR DELETING DATA: $e");
    }
  }

  // file upload

  PlatformFile? pickedImage;

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    try {
      final bucketName = 'Faculty';
      final filePath = "$uid-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("ERROR PHOTO UPLOAD: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDept();
    fetchFaculty();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF161616),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
                  onPressed: () {
                    setState(() {
                      _isFormVisible =
                          !_isFormVisible; // Toggle form visibility
                    });
                  },
                  label: Text(
                    _isFormVisible ? "Cancel" : "Add Faculty",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(
                    _isFormVisible ? Icons.cancel : Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Form(
                    key: formKey,
                    child: SizedBox(
                      width: 700,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: pickedImage == null
                                      ? GestureDetector(
                                          onTap: handleImagePick,
                                          child: Icon(
                                            Icons.add_a_photo,
                                            color: Colors.blue,
                                            size: 50,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: handleImagePick,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: pickedImage!.bytes != null
                                                ? Image.memory(
                                                    Uint8List.fromList(
                                                        pickedImage!.bytes!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(pickedImage!.path!),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _facultyController,
                                  validator: (value) =>
                                      FormValidation.validateName(value),
                                  decoration: InputDecoration(
                                      hintText: "Name",
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                  255, 2, 55, 98)))),
                                ),
                              )),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8),
                                child: TextFormField(
                                  controller: _facDesignationController,
                                  decoration: InputDecoration(
                                      hintText: "Designation",
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 2, 55, 98)))),
                                ),
                              )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8),
                                child: TextFieldStyle(
                                    label: "Email",
                                    inputController: _facEmailController),
                              )),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8),
                                child: TextFieldStyle(
                                    label: "Password",
                                    inputController: _facPasswordController),
                              ))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8),
                                child: TextFieldStyle(
                                    label: 'Contact',
                                    inputController: _facContactController),
                              )),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(8),
                                child: DropdownButtonFormField<String>(
                                    value: selectedDept,
                                    hint: const Text("Select Department"),
                                    items: DeptList.map((department) {
                                      return DropdownMenuItem(
                                          value: department['department_id']
                                              .toString(),
                                          child: Text(
                                              department['department_name']));
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDept = newValue;
                                      });
                                    }),
                              ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 22, horizontal: 70),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  onPressed: () {
                                    if (eid == 0) {
                                      register();
                                    } else {
                                      editFaculty();
                                    }
                                  },
                                  child: Text(
                                    eid == 0 ? "Insert" : "Edit",
                                    style: TextStyle(color: Colors.white),
                                  )),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    ))
                : Container(),
          ),
          Container(
            child: Center(
              child: Text("Faculty Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            ),
          ),
          Container(
              child: Padding(
            padding: EdgeInsets.all(8),
            child: DataTable(
              columns: [
                DataColumn(label: Text("Sl.No")),
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Designation")),
                DataColumn(label: Text("Department")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Password")),
                DataColumn(label: Text("Contact No.")),
                DataColumn(label: Text("Edit")),
                DataColumn(label: Text("Delete"))
              ],
              rows: facultyList.asMap().entries.map((entry) {
                print(entry.value);
                return DataRow(cells: [
                  DataCell(Text((entry.key + 1000).toString())),
                  DataCell(Text(entry.value['faculty_name'])),
                  DataCell(Text(entry.value['faculty_designation'])),
                  DataCell(
                      Text(entry.value['tbl_department']['department_name'])),
                  DataCell(Text(entry.value['faculty_email'])),
                  DataCell(Text(entry.value['faculty_password'])),
                  DataCell(Text(entry.value['faculty_contact'])),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        _facultyController.text = entry.value['faculty_name'];
                        _facDesignationController.text =
                            entry.value['faculty_designation'];
                        _facEmailController.text = entry.value['faculty_email'];
                        _facPasswordController.text =
                            entry.value['faculty_password'];
                        _facContactController.text =
                            entry.value['faculty_contact'];
                        eid = entry.value['faculty_id'];
                        _isFormVisible = true;
                        selectedDept =
                            (entry.value['department_id']).toString();
                      });
                    },
                  )),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      //delete function
                      delFaculty(entry.value['faculty_id'].toString());
                    },
                  ))
                ]);
              }).toList(),
            ),
          ))
        ],
      ),
    );
  }
}
