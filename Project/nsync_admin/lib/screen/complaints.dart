import 'package:flutter/material.dart';
import 'package:nsync_admin/main.dart'; // Assuming supabase is initialized here
import 'package:intl/intl.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  List<Map<String, dynamic>> complaintList = [];
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('*,tbl_student("*")');
      setState(() {
        complaintList = response;
      });
    } catch (e) {
      print("ERROR FETCHING COMPLAINTS: $e");
    }
  }

  Future<void> submitReply(int complaintId, String currentReply) async {
    try {
      await supabase
          .from('tbl_complaint')
          .update({
            'complaint_reply':
                _replyController.text.isNotEmpty
                    ? _replyController.text
                    : currentReply,
            'complaint_status': 1,
          })
          .eq('id', complaintId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Reply Submitted Successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _replyController.clear();
      fetchComplaints(); // Refresh the list
    } catch (e) {
      print("ERROR SUBMITTING REPLY: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReplyDialog(int complaintId, String currentReply) {
    _replyController.text = currentReply; // Pre-fill with existing reply if any
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Reply'),
            content: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: "Type your reply here",
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_replyController.text.isNotEmpty) {
                    submitReply(complaintId, currentReply);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Manage Complaints"),
              Padding(
                padding: const EdgeInsets.all(10),
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
                  onPressed: () {},
                  label: const Text(
                    "New Action",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Complaints List",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          complaintList.isEmpty
              ? const Center(
                child: Text(
                  "No complaints available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(8),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Sl.No")),
                    DataColumn(label: Text("Title")),
                    DataColumn(label: Text("Content")),
                    DataColumn(label: Text("Student ")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Reply")),
                  ],
                  rows:
                      complaintList.asMap().entries.map((entry) {
                        return DataRow(
                          cells: [
                            DataCell(Text((entry.key + 1).toString())),
                            DataCell(
                              Text(
                                entry.value['complaint_title'] ?? 'No Title',
                              ),
                            ),
                            DataCell(
                              Text(
                                entry.value['complaint_content'] ??
                                    'No Content',
                              ),
                            ),
                            DataCell(
                              Text(
                                entry.value['tbl_student']['student_name'] ??
                                    'N/A',
                              ),
                            ),
                            DataCell(
                              Text(
                                entry.value['complaint_status'] == 0
                                    ? 'Not Replied'
                                    : 'Replied',
                                style: TextStyle(
                                  color:
                                      entry.value['complaint_status'] == 0
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.reply,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showReplyDialog(
                                    entry.value['id'],
                                    entry.value['complaint_reply'] ?? '',
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
        ],
      ),
    );
  }
}
