import 'package:flutter/material.dart';
import 'package:nsync_stud/main.dart';
import 'package:nsync_stud/screen/join_clubs.dart';
import 'package:intl/intl.dart';
import 'package:nsync_stud/screen/event_details.dart';

class StudentClub extends StatefulWidget {
  const StudentClub({super.key});

  @override
  State<StudentClub> createState() => _StudentClubState();
}

class _StudentClubState extends State<StudentClub> {
  List<Map<String, dynamic>> clubList = [];
  Map<String, List<Map<String, dynamic>>> clubEvents = {};

  Future<void> fetchClubs() async {
    try {
      final response = await supabase
          .from('tbl_members')
          .select('*, tbl_club(*)')
          .eq('student_id', supabase.auth.currentUser!.id);

      setState(() {
        clubList = List<Map<String, dynamic>>.from(response);
      });

      // Fetch events for each club
      await fetchClubEvents();
    } catch (e) {
      print("ERROR FETCHING CLUBS: $e");
    }
  }

  Future<void> fetchClubEvents() async {
    try {
      // Get current date for filtering active events
      final currentDate = DateTime.now();
      final currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      final formattedCurrentDate =
          currentDateOnly.toIso8601String().split('T')[0];

      // Create a map to store events for each club
      Map<String, List<Map<String, dynamic>>> tempClubEvents = {};

      // Fetch events for each club
      for (var club in clubList) {
        final clubId =
            club['tbl_club']['club_id'].toString(); // Convert to string
        final response = await supabase
            .from('tbl_events')
            .select(
              'event_id, event_name, event_venue, event_fordate, event_lastdate, created_at',
            )
            .eq('club_id', clubId)
            .gte('event_lastdate', formattedCurrentDate) // Only active events
            .eq('event_status', 1)
            .order('event_fordate', ascending: true);

        tempClubEvents[clubId] =
            List<Map<String, dynamic>>.from(response).map((event) {
              return {
                'event_id':
                    event['event_id']?.toString() ?? '', // Ensure string
                'event_name': event['event_name'] ?? '',
                'event_venue': event['event_venue'] ?? '',
                'event_fordate': event['event_fordate'] ?? '',
                'event_lastdate': event['event_lastdate'] ?? '',
                'created_at': event['created_at'] ?? '',
              };
            }).toList();
      }

      setState(() {
        clubEvents = tempClubEvents;
      });
    } catch (e) {
      print("ERROR FETCHING CLUB EVENTS: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClubs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            clubList.isEmpty
                ? const Center(child: Text("You have not joined any clubs"))
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      const Center(
                        child: Text(
                          "My Clubs",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: clubList.length,
                          itemBuilder: (context, index) {
                            final club = clubList[index];
                            final clubId =
                                club['tbl_club']['club_id']
                                    .toString(); // Convert to string
                            final events = clubEvents[clubId] ?? [];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    242,
                                    242,
                                    242,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        club['tbl_club']['club_name'] ??
                                            'Unnamed Club',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Upcoming Events',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    events.isEmpty
                                        ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            'No upcoming events for this club',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: events.length,
                                          itemBuilder: (context, eventIndex) {
                                            final event = events[eventIndex];
                                            return _buildEventCard(
                                              context,
                                              event,
                                            );
                                          },
                                        ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JoinClubs()),
          );
          if (result == true) {
            await fetchClubs(); // Refresh clubs and events after joining
          }
        },
        label: const Row(children: [Text("Join Club"), Icon(Icons.add)]),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['event_name'] ?? 'Unnamed Event',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  event['event_venue'] ?? 'No venue',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  event['event_fordate'] != null
                      ? DateFormat(
                        'dd-MM-yyyy',
                      ).format(DateTime.parse(event['event_fordate']))
                      : 'No date',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          _buildEventButtonOrStatus(context, event),
        ],
      ),
    );
  }

  Widget _buildEventButtonOrStatus(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    final currentDate = DateTime.now();
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    DateTime eventDate;
    try {
      eventDate = DateTime.parse(event['event_fordate']);
      eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
    } catch (e) {
      return const Text(
        'Invalid event date',
        style: TextStyle(color: Colors.red, fontSize: 12),
      );
    }

    final isEventToday = currentDateOnly == eventDate;

    if (isEventToday) {
      return const Text(
        'Online Registration Closed\nSpot Registration Open',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetails(id: event['event_id']),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('View More'),
      );
    }
  }
}
