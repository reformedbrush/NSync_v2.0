import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nsync_admin/components/insert_form.dart';
import 'package:nsync_admin/main.dart';
import 'package:intl/intl.dart';
import 'package:nsync_admin/screen/requested_events.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  // Controllers
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _evDetailController = TextEditingController();
  final TextEditingController _evVenueController = TextEditingController();
  final TextEditingController _evForDateController = TextEditingController();
  final TextEditingController _evLastDateController = TextEditingController();
  final TextEditingController _evParticipantsController =
      TextEditingController();

  // List to store table data
  List<Map<String, dynamic>> EventList = [];

  // Insert
  Future<void> eventInsert() async {
    try {
      if (_eventController.text.isEmpty ||
          _evDetailController.text.isEmpty ||
          _evVenueController.text.isEmpty ||
          _evForDateController.text.isEmpty ||
          _evLastDateController.text.isEmpty ||
          _evParticipantsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please fill all fields",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? url = await photoUpload();
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to upload poster",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await supabase.from('tbl_events').insert({
        'event_name': _eventController.text,
        'event_details': _evDetailController.text,
        'event_venue': _evVenueController.text,
        'event_fordate': _evForDateController.text,
        'event_lastdate': _evLastDateController.text,
        'event_status': 1,
        'event_participants': _evParticipantsController.text,
        'event_poster': url,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Event Details Inserted Successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _eventController.clear();
        _evDetailController.clear();
        _evVenueController.clear();
        _evForDateController.clear();
        _evLastDateController.clear();
        _evParticipantsController.clear();
        pickedImage = null;
        _isFormVisible = false;
      });

      fetchEvents();
    } catch (e) {
      print("ERROR INSERTING DATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Select
  Future<void> fetchEvents() async {
    try {
      final response = await supabase
          .from('tbl_events')
          .select()
          .eq('event_status', 1);
      print("Response type: ${response.runtimeType}");
      print("Response data: $response");
      setState(() {
        EventList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("ERROR FETCHING DATA: $e");
    }
  }

  // Edit
  int eid = 0;

  Future<void> editEvent() async {
    try {
      if (_eventController.text.isEmpty ||
          _evDetailController.text.isEmpty ||
          _evVenueController.text.isEmpty ||
          _evForDateController.text.isEmpty ||
          _evLastDateController.text.isEmpty ||
          _evParticipantsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please fill all fields",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await supabase
          .from('tbl_events')
          .update({
            'event_name': _eventController.text,
            'event_venue': _evVenueController.text,
            'event_details': _evDetailController.text,
            'event_fordate': _evForDateController.text,
            'event_lastdate': _evLastDateController.text,
            'event_participants': _evParticipantsController.text,
          })
          .eq('event_id', eid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Event Updated Successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _eventController.clear();
        _evDetailController.clear();
        _evVenueController.clear();
        _evForDateController.clear();
        _evLastDateController.clear();
        _evParticipantsController.clear();
        eid = 0;
        _isFormVisible = false;
      });

      fetchEvents();
    } catch (e) {
      print("ERROR UPDATING DATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete
  Future<void> DelEvent(String did) async {
    try {
      await supabase.from("tbl_events").delete().eq("event_id", did);
      fetchEvents();
    } catch (e) {
      print("ERROR: $e");
    }
  }

  // Select date
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // File upload
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

  Future<String?> photoUpload() async {
    try {
      final bucketName = 'Post';
      final filePath =
          "Event-${DateTime.now().millisecondsSinceEpoch}-${pickedImage!.name}";
      await supabase.storage
          .from(bucketName)
          .uploadBinary(filePath, pickedImage!.bytes!);
      final publicUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("ERROR PHOTO UPLOAD: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestedEvents(),
                      ),
                    );
                  },
                  label: Text(
                    "Event Requests",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF161616),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  ),
                  icon: Icon(Icons.new_label, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF161616),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  ),
                  onPressed: () {
                    setState(() {
                      _isFormVisible = !_isFormVisible;
                    });
                  },
                  label: Text(
                    _isFormVisible ? "Cancel" : "Add Events",
                    style: TextStyle(color: Colors.white),
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
                                              child:
                                                  pickedImage!.bytes != null
                                                      ? Image.memory(
                                                        Uint8List.fromList(
                                                          pickedImage!.bytes!,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                      : Image.file(
                                                        File(
                                                          pickedImage!.path!,
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFieldStyle(
                                      inputController: _eventController,
                                      label: "Event Name",
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFieldStyle(
                                      label: "Venue",
                                      inputController: _evVenueController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFieldStyle(
                                      label: "Event Details",
                                      inputController: _evDetailController,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFieldStyle(
                                      label: "Participants",
                                      inputController:
                                          _evParticipantsController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFormField(
                                      controller: _evForDateController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        labelText: "For_Date",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap:
                                          () => _selectDate(
                                            context,
                                            _evForDateController,
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFormField(
                                      controller: _evLastDateController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        labelText: "Last_date",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap:
                                          () => _selectDate(
                                            context,
                                            _evLastDateController,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                  vertical: 22,
                                  horizontal: 70,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                if (eid == 0) {
                                  eventInsert();
                                } else {
                                  editEvent();
                                }
                              },
                              child: Text(
                                eid == 0 ? "Insert" : "Update",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Container(),
          ),
          SizedBox(height: 50),
          Container(
            child: Center(
              child: Text(
                "Events Table",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Sl No")),
                  DataColumn(label: Text("Event")),
                  DataColumn(label: Text("Venue")),
                  DataColumn(label: Text("Details")),
                  DataColumn(label: Text("For Date")),
                  DataColumn(label: Text("Last Date")),
                  DataColumn(label: Text("Participants")),
                  DataColumn(label: Text("Edit")),
                  DataColumn(label: Text("Delete")),
                ],
                rows:
                    EventList.asMap().entries.map((entry) {
                      final event = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text((entry.key + 1).toString())),
                          DataCell(Text(event['event_name']?.toString() ?? '')),
                          DataCell(
                            Text(event['event_venue']?.toString() ?? ''),
                          ),
                          DataCell(
                            Text(event['event_details']?.toString() ?? ''),
                          ),
                          DataCell(
                            Text(event['event_fordate']?.toString() ?? ''),
                          ),
                          DataCell(
                            Text(event['event_lastdate']?.toString() ?? ''),
                          ),
                          DataCell(
                            Text(event['event_participants']?.toString() ?? ''),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  _evForDateController.text =
                                      event['event_fordate']?.toString() ?? '';
                                  _evLastDateController.text =
                                      event['event_lastdate']?.toString() ?? '';
                                  _eventController.text =
                                      event['event_name']?.toString() ?? '';
                                  _evDetailController.text =
                                      event['event_details']?.toString() ?? '';
                                  _evVenueController.text =
                                      event['event_venue']?.toString() ?? '';
                                  _evParticipantsController.text =
                                      event['event_participants']?.toString() ??
                                      '';
                                  eid = event['event_id'] ?? 0;
                                  _isFormVisible = true;
                                });
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                DelEvent(event['event_id'].toString());
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
