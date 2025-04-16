import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    eventFetch();
  }

  Future<void> eventFetch() async {
    try {
      final response = await supabase
          .from('tbl_participants')
          .select('participant_id, participant_status, tbl_events(*)')
          .eq('student_id', supabase.auth.currentUser!.id);
      setState(() {
        events = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching events: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                events.isEmpty
                    ? const Center(child: Text('No events registered'))
                    : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index]['tbl_events'];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            title: Text(
                              event['event_name'] ?? 'Unnamed Event',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['event_fordate'] ?? 'No date'),
                                Text(
                                  'Status: ${events[index]['participant_status']}',
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.event),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tapped on ${event['event_name']}',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
