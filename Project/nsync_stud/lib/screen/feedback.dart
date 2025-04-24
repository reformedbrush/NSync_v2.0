import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart'; // Assuming supabase is initialized here

class AppComplaint extends StatefulWidget {
  const AppComplaint({super.key});

  @override
  State<AppComplaint> createState() => _AppComplaintState();
}

class _AppComplaintState extends State<AppComplaint> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false; // Loading state for form submission
  List<Map<String, dynamic>> _complaints = []; // List to store complaints
  bool _isLoadingComplaints = true; // Loading state for fetching complaints
  String? _errorMessage; // Error message for fetching complaints

  @override
  void initState() {
    super.initState();
    _fetchComplaints(); // Fetch complaints when the widget is initialized
  }

  Future<void> _fetchComplaints() async {
    setState(() {
      _isLoadingComplaints = true;
      _errorMessage = null;
    });

    try {
      if (supabase.auth.currentUser == null) {
        setState(() {
          _errorMessage = "You must be logged in to view complaints";
          _isLoadingComplaints = false;
        });
        return;
      }

      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('student_id', supabase.auth.currentUser!.id);

      setState(() {
        _complaints = List<Map<String, dynamic>>.from(response);
        _isLoadingComplaints = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching complaints: $e";
        _isLoadingComplaints = false;
      });
    }
  }

  Future<void> submitComplaint() async {
    if (_isSubmitting) return; // Prevent multiple submissions

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
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

      if (supabase.auth.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You must be logged in to submit a complaint",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await supabase.from('tbl_complaint').insert({
        'student_id': supabase.auth.currentUser!.id,
        'complaint_title': _titleController.text,
        'complaint_content': _contentController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Complaint Submitted Successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _titleController.clear();
        _contentController.clear();
      });

      // Refresh the complaints list after submission
      await _fetchComplaints();
    } catch (e) {
      print("ERROR SUBMITTING COMPLAINT: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Submit a Complaint",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Banner Image Container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/complaint.jpg'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Complaint Form",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Complaint Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: "Complaint Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : submitComplaint,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            elevation: 0, // Flat design
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                  : const Text(
                                    "Submit Complaint",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Complaints List Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Complaints",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoadingComplaints
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _complaints.isEmpty
                        ? const Center(
                          child: Text(
                            "No complaints submitted yet.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _complaints.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final complaint = _complaints[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      complaint['complaint_title'] ??
                                          'No Title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      complaint['complaint_content'] ??
                                          'No Description',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    // const SizedBox(height: 8),
                                    // Row(
                                    //   children: [
                                    //     const Text(
                                    //       "Status: ",
                                    //       style: TextStyle(
                                    //         fontSize: 14,
                                    //         fontWeight: FontWeight.w500,
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       complaint['complaint_status'] == 0
                                    //           ? 'Open'
                                    //           : 'Closed',
                                    //       style: TextStyle(
                                    //         fontSize: 14,
                                    //         color:
                                    //             complaint['complaint_status'] ==
                                    //                     0
                                    //                 ? Colors.orange
                                    //                 : Colors.green,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          "Reply: ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            complaint['complaint_reply'] !=
                                                        null &&
                                                    complaint['complaint_reply']
                                                        .isNotEmpty
                                                ? complaint['complaint_reply']
                                                : 'Not Replied',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  complaint['complaint_reply'] !=
                                                              null &&
                                                          complaint['complaint_reply']
                                                              .isNotEmpty
                                                      ? Colors.black
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
