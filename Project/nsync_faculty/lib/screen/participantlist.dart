import 'package:flutter/material.dart';
import 'package:nsync_faculty/main.dart'; // Assuming supabase is initialized here
import 'package:intl/intl.dart';

class EventParticipants extends StatefulWidget {
  final int eventId;

  const EventParticipants({super.key, required this.eventId});

  @override
  State<EventParticipants> createState() => _EventParticipantsState();
}

class _EventParticipantsState extends State<EventParticipants> {
  List<Map<String, dynamic>> participants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase
          .from('tbl_participants')
          .select(
            'participant_id, created_at, participant_status, event_id, tbl_student!inner(student_name)',
          )
          .eq('event_id', widget.eventId);

      setState(() {
        participants = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching participants: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Participants'),
        backgroundColor: const Color(0xFF161616),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants List',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    participants.isEmpty
                        ? const Center(
                          child: Text(
                            'No participants registered yet.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: participants.length,
                          itemBuilder: (context, index) {
                            final participant = participants[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(
                                  participant['tbl_student']?['student_name'] ??
                                      'Unknown Student',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Registered: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(participant['created_at']))}',
                                    ),
                                    // Text(
                                    //   'Status: ${participant['participant_status'] == 0 ? 'Pending' : 'Confirmed'}',
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
    );
  }
}
