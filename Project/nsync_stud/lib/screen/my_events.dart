import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';
import 'package:intl/intl.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  List<Map<String, dynamic>> currentEvents = [];
  List<Map<String, dynamic>> pastEvents = [];

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

      final currentDate = DateTime.now();
      final currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      List<Map<String, dynamic>> tempCurrentEvents = [];
      List<Map<String, dynamic>> tempPastEvents = [];

      for (var event in response) {
        final eventLastDate = event['tbl_events']['event_lastdate'];
        if (eventLastDate == null) continue; // Skip events with null last date

        DateTime lastDate;
        try {
          lastDate = DateTime.parse(eventLastDate);
          lastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
        } catch (e) {
          print(
            'Invalid event_lastdate for event ${event['tbl_events']['event_id']}: $e',
          );
          continue; // Skip events with invalid dates
        }

        if (lastDate.isBefore(currentDateOnly)) {
          tempPastEvents.add(event);
        } else {
          tempCurrentEvents.add(event);
        }
      }

      setState(() {
        currentEvents = tempCurrentEvents;
        pastEvents = tempPastEvents;
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Events Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Current Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            currentEvents.isEmpty
                ? const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'No current events registered',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: currentEvents.length,
                  itemBuilder: (context, index) {
                    final event = currentEvents[index]['tbl_events'];
                    return _buildEventCard(context, currentEvents[index]);
                  },
                ),

            // Past Events Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Past Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            pastEvents.isEmpty
                ? const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'No past events registered',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: pastEvents.length,
                  itemBuilder: (context, index) {
                    final event = pastEvents[index]['tbl_events'];
                    return _buildEventCard(context, pastEvents[index]);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> eventData) {
    final event = eventData['tbl_events'];
    final participantStatus =
        eventData['participant_status']?.toString() ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          event['event_name'] ?? 'Unnamed Event',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['event_fordate'] != null
                  ? DateFormat(
                    'dd-MM-yyyy',
                  ).format(DateTime.parse(event['event_fordate']))
                  : 'No date',
            ),
            Text('Status: $participantStatus'),
            if (event['event_lastdate'] != null)
              Text(
                'Last Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(event['event_lastdate']))}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: const Icon(Icons.event),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${event['event_name']}')),
          );
        },
      ),
    );
  }
}
